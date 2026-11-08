"""Trace format, run endings, command line and the instruction table."""

import subprocess

import pytest

import refmodel
from emuhelp import EMU, ISA_CSV, STEPPER, assemble, parse_trace, run_asm, run_emu, run_raw

# ---- Exact trace text, written by hand ----

PROG = """
        IMF A, 0x5C     ; 00 ILA c, 01 IHA 5
        SST A, 3        ; 02
        CALL f          ; 03 ALO 8, 04 AHI 0, 05 CALL
f:      HALT            ; 06 ALO 8, 07 AHI 0, 08 JMP
"""


def test_writes_trace_exact(tmp_path):
    hexp = assemble(tmp_path, PROG)
    r = run_raw(hexp)
    assert r.returncode == 0 and r.stderr == ""
    assert r.stdout == (
        "R xx xx 00 xx xx xx x 0 00 00 00 00 0 xx xx\n"
        "S 00 0c 01 xc xx xx x 0 00 00 00 00 0 xx xx\n"
        "S 01 15 02 5c xx xx x 0 00 00 00 00 0 xx xx\n"
        "S 02 e3 03 5c xx xx x 0 00 00 00 00 1 03 5c\n"
        "S 03 46 04 5c xx x6 x 0 00 00 00 00 0 xx xx\n"
        "S 04 50 05 5c xx 06 x 0 00 00 00 00 0 xx xx\n"
        "S 05 9a 06 5c xx 06 x 1 06 00 00 00 0 xx xx\n"
        "S 06 48 07 5c xx 08 x 1 06 00 00 00 0 xx xx\n"
        "S 07 50 08 5c xx 08 x 1 06 00 00 00 0 xx xx\n"
        "S 08 98 08 5c xx 08 x 1 06 00 00 00 0 xx xx\n"
        "END HALT\n")


def test_full_trace_exact(tmp_path):
    hexp = assemble(tmp_path, PROG)
    r = run_raw(hexp, "-m", "full")
    lines = r.stdout.splitlines()
    assert lines[0] == "R xx xx 00 xx xx xx x 0 00 00 00 00 001 100 xx"
    assert lines[2] == "S 01 15 02 5c xx xx x 0 00 00 00 00 001 100 xx"
    assert lines[3] == ("S 02 e3 03 5c xx xx x 0 00 00 00 00 "
                        "003 003 xx 001 5c 0fc xx")
    assert lines[9] == ("S 08 98 08 5c xx 08 x 1 06 00 00 00 "
                        "003 003 xx 001 5c 0fc xx")
    assert lines[10] == "END HALT"


def test_full_memory_runs(tmp_path):
    # Fill 00 and ff and a run of equal values: runs merge across equal bytes.
    t = run_asm(tmp_path, """
        IMF A, 7
        SST A, 0
        SST A, 1
        SST A, 2
        IMF AR, 0xFF
        ST A
        IMF AR, 0xFE
        IMF A, 8
        ST A
        HALT
    """, mode="full")
    last = t.lines[-2]
    assert last.endswith(" 004 003 07 0fb xx 001 08 001 07")


def test_trace_to_file_matches_stdout(tmp_path):
    hexp = assemble(tmp_path, PROG)
    out = tmp_path / "trace.txt"
    r = run_raw(hexp, "-o", out)
    assert r.returncode == 0 and r.stdout == ""
    assert out.read_text() == run_raw(hexp).stdout
    r = run_raw("--trace=" + str(out), "--mem=full", hexp)
    assert out.read_text() == run_raw(hexp, "-m", "full").stdout


# ---- How runs end ----

def test_halt_on_jf_to_itself(tmp_path):
    t = run_asm(tmp_path, "STF\nIMF AR, 3\nJF\n")
    assert t.end == "HALT" and t.last["pc"] == "03"
    assert len(t.steps) == 4


def test_jf_not_taken_does_not_halt(tmp_path):
    t = run_asm(tmp_path, "CLF\nIMF AR, 3\nJF\nHALT\n")
    assert t.steps[3].state["pc"] == "04"
    assert len(t.steps) == 7


def test_call_to_itself_halts(tmp_path):
    # PC unchanged is the halt rule, even though the stack moved.
    t = run_asm(tmp_path, "IMF AR, 2\nCALL\n")
    assert t.end == "HALT"
    assert (t.last["pc"], t.last["d"], t.last["s0"]) == ("02", "1", "03")


def test_ret_to_itself_halts(tmp_path):
    # CALL at 02 pushes 03; RET at 03 returns to 03.
    t = run_asm(tmp_path, "IMF AR, 3\nCALL\nRET\n")
    assert t.end == "HALT"
    assert [(r.epc, r.op) for r in t.steps[-2:]] == [("02", "9a"), ("03", "9b")]


def test_step_limit(tmp_path):
    hexp = assemble(tmp_path, "loop: CLF\nJMP loop\n")
    t, r = run_emu(hexp, "-n", "10")
    assert r.returncode == 2 and t.end == "LIMIT"
    assert len(t.steps) == 10
    assert "10" in r.stderr
    # The limit counts instructions: one halting exactly at the limit halts.
    t, _ = run_emu(assemble(tmp_path, "HALT\n", "h"), "-n", "3")
    assert t.end == "HALT"
    t, _ = run_emu(assemble(tmp_path, "HALT\n", "h"), "-n", "2")
    assert t.end == "LIMIT"
    t, _ = run_emu(hexp, "--max-steps", "0")
    assert t.end == "LIMIT" and t.steps == []


def test_default_step_limit(tmp_path):
    t, _ = run_emu(assemble(tmp_path, "loop: JMP next\nnext: JMP loop\n"))
    assert t.end == "LIMIT" and len(t.steps) == 100000


# ---- Command line ----

@pytest.mark.parametrize("args,message", [
    ([], "no program given"),
    (["a.hex", "b.hex"], "more than one program"),
    (["-m", "all", "p.hex"], "memory mode must be writes or full"),
    (["-n", "-3", "p.hex"], "bad step limit"),
    (["-n", "10k", "p.hex"], "bad step limit"),
    (["-x", "p.hex"], "unknown option -x"),
    (["p.hex", "-o"], "option -o needs a value"),
])
def test_usage_errors(args, message):
    r = run_raw(*args)
    assert r.returncode == 3
    assert message in r.stderr and "usage:" in r.stderr
    assert r.stdout == ""


def test_help():
    r = run_raw("--help")
    assert r.returncode == 0 and "usage: emu" in r.stdout
    assert str(ISA_CSV) in r.stdout


def test_unwritable_trace(tmp_path):
    hexp = assemble(tmp_path, "HALT\n")
    r = run_raw(hexp, "-o", tmp_path / "no" / "dir" / "t.txt")
    assert r.returncode == 3


def test_runs_from_any_directory(tmp_path):
    # The default instruction table is the repo copy, wherever emu runs from.
    hexp = assemble(tmp_path, "HALT\n")
    r = subprocess.run([str(EMU), str(hexp)],
                       cwd=tmp_path, capture_output=True, text=True)
    assert r.returncode == 0


# ---- Decoding comes from the instruction table ----

def csv_rows():
    return ISA_CSV.read_text().splitlines()


def write_csv(tmp_path, lines, name="isa.csv"):
    p = tmp_path / name
    p.write_text("\n".join(lines) + "\n")
    return p


def recode(lines, name, bits):
    """Changes the b7..b0 cells of instruction `name` to `bits`."""
    out = []
    for line in lines:
        if line.startswith(name + ","):
            cells = line.split(",")
            cells[2:10] = list(bits)
            line = ",".join(cells)
        out.append(line)
    return out


def test_isa_flag_changes_decoding(tmp_path):
    # Move TAR from d8 to d0: d0 now does TAR, d8 becomes a NOP.
    isa = write_csv(tmp_path, recode(csv_rows(), "TAR", "11010000"))
    hexp = tmp_path / "p.hex"
    hexp.write_text("05 d8 d0 4e 5f 98\n")  # ILA 5 (A = x5)...
    r = run_raw(hexp, "--isa", isa)
    t = parse_trace(r.stdout)
    # A is x5, so the real TAR (now at d0) fails, the old code doesn't.
    assert [x.op for x in t.steps] == ["05", "d8"]
    assert t.error == ("02", "d0", "reads unknown A")
    # With the repo table it's the other way round.
    t = parse_trace(run_raw(hexp).stdout)
    assert t.error == ("01", "d8", "reads unknown A")


def test_isa_swapped_add_sub_seen_by_stepper(tmp_path):
    lines = recode(recode(csv_rows(), "ADD", "10000011"), "SUB", "10000010")
    isa = write_csv(tmp_path, lines)
    st = {"pc": 0, "a": "09", "b": "04", "ar": "00", "f": "0", "d": 0,
          "s": [0, 0, 0, 0], "seed": 0}
    inp = "82 00 09 04 00 0 0 00 00 00 00 00\n83 00 09 04 00 0 0 00 00 00 00 00\n"
    out = subprocess.run([str(STEPPER), str(isa)], input=inp,
                         capture_output=True, text=True).stdout.splitlines()
    assert out == [refmodel.run(0x83, st), refmodel.run(0x82, st)]


def test_isa_crlf_and_quoted_fields(tmp_path):
    p = tmp_path / "crlf.csv"
    p.write_bytes("\r\n".join(csv_rows()).encode() + b"\r\n")
    hexp = assemble(tmp_path, PROG)
    assert run_raw(hexp, "-i", p).stdout == run_raw(hexp).stdout


@pytest.mark.parametrize("edit,message", [
    (lambda l: recode(l, "TAR", "10011000"), "TAR overlaps JMP"),
    (lambda l: [x for x in l if not x.startswith("RET,")], "no row for RET"),
    (lambda l: l + ["HALT,,1,0,1,0,0,0,0,0,,,,"], "unknown instruction 'HALT'"),
    (lambda l: l + [l[1]], "ILA already defined on line 2"),
    (lambda l: recode(l, "ADD", "1000001z"), "bad b0 cell 'z'"),
    (lambda l: l + ["FOO,x,1,0"], "too few fields"),
    (lambda l: [l[0].replace("b3", "bit3")] + l[1:], "no b3 column"),
    (lambda l: [l[0].replace("Name", "Mnemonic")] + l[1:], "no Name column"),
    (lambda l: l[:1] + ['ADD,"unterminated'], "malformed CSV record"),
])
def test_bad_isa_tables(tmp_path, edit, message):
    isa = write_csv(tmp_path, edit(csv_rows()))
    hexp = assemble(tmp_path, "HALT\n")
    r = run_raw(hexp, "--isa", isa)
    assert r.returncode == 3 and r.stdout == ""
    assert message in r.stderr, r.stderr


def test_operand_width_checked(tmp_path):
    lines = csv_rows()
    lines = [x.replace("JMP,PC = AR,1,0,0,1,1,0,0,0",
                       "JMP,PC = AR,1,0,0,1,1,0,0,imm4") for x in lines]
    r = run_raw(assemble(tmp_path, "HALT\n"), "--isa", write_csv(tmp_path, lines))
    assert r.returncode == 3 and "JMP has a 1-bit operand" in r.stderr


def test_missing_isa_file(tmp_path):
    r = run_raw(assemble(tmp_path, "HALT\n"), "--isa", tmp_path / "none.csv")
    assert r.returncode == 3 and "cannot read" in r.stderr

"""Strict reads: an instruction that reads a value that isn't fully known
stops the run, with no record for that instruction."""

import pytest

from emuhelp import run_asm

# (setup, instruction, message) — the instruction runs right after setup.
ERRORS = [
    ("", "ADD", "reads unknown A"),
    ("IMF A, 1", "ADD", "reads unknown B"),
    ("IMF B, 1", "SUB", "reads unknown A"),
    ("", "INV A", "reads unknown A"),
    ("", "INV B", "reads unknown B"),
    ("", "INC", "reads unknown A"),
    ("IMF A, 1", "MUL", "reads unknown B"),
    ("IMF B, 0", "DIV", "reads unknown A"),       # even by zero, A is read
    ("IMF A, 1", "SWAP", "reads unknown B"),      # a plain move still reads
    ("IMF B, 1", "SWAP", "reads unknown A"),
    ("IMF A, 1", "SHL", "reads unknown B"),
    ("IMF A, 1", "EQ", "reads unknown B"),
    ("IMF B, 1", "LTE", "reads unknown A"),
    ("", "TAR", "reads unknown A"),
    ("ILA 5", "TAR", "reads unknown A"),          # half known is unknown
    ("IHA 5", "INC", "reads unknown A"),
    ("ILB 5", "INV B", "reads unknown B"),
    ("IMF AR, 3", "ST A", "reads unknown A"),
    ("IMF A, 1", "ST A", "reads unknown AR (address)"),
    ("IMF A, 1", "ST B", "reads unknown AR (address)"),
    ("IMF AR, 3", "ST B", "reads unknown B"),
    ("IMF A, 1\nALO 3", "ST A", "reads unknown AR (address)"),
    ("", "SST A, 2", "reads unknown A"),
    ("", "SST B, 2", "reads unknown B"),
    ("", "LD A", "reads unknown AR (address)"),
    ("IMF AR, 0x40", "LD A", "reads unknown M[0x40]"),
    ("IMF AR, 0x41", "LD B", "reads unknown M[0x41]"),
    ("", "SLD A, 9", "reads unknown M[0x09]"),
    ("IMF B, 7\nSST B, 3", "SLD B, 4", "reads unknown M[0x04]"),
    ("", "JMP", "reads unknown AR (jump target)"),
    ("", "CALL", "reads unknown AR (jump target)"),
    ("AHI 0", "JMP", "reads unknown AR (jump target)"),
    ("", "JF", "reads unknown F"),
    ("IMF AR, 0", "JF", "reads unknown F"),
    ("STF", "JF", "reads unknown AR (jump target)"),
]


@pytest.mark.parametrize("setup,instr,message", ERRORS,
                         ids=[f"{s.replace(chr(10), '; ')}|{i}"
                              for s, i, _ in ERRORS])
def test_unknown_read_stops_the_run(tmp_path, setup, instr, message):
    t = run_asm(tmp_path, f"{setup}\n{instr}\nHALT\n")
    assert t.end == "ERROR"
    pc, op, msg = t.error
    assert msg == message
    # The failing instruction has no record; the last record is the state
    # before it, whose PC is where the error happened.
    assert t.last["pc"] == pc
    assert len(t.steps) == int(pc, 16)


def test_error_line_names_the_instruction_word(tmp_path):
    t = run_asm(tmp_path, "IMF A, 1\nIMF AR, 7\nST B\nHALT\n")
    assert t.lines[-1] == "END ERROR 04 df reads unknown B"


def test_error_leaves_state_unchanged(tmp_path):
    # STB with B unknown must not write memory or touch anything else.
    t = run_asm(tmp_path, "IMF A, 9\nIMF AR, 1\nSTA\nSTB\nHALT\n", mode="full")
    assert t.end == "ERROR"
    assert t.records[-1].mem[1] == "09"
    assert t.records[-1].mem.count("xx") == 255


OK = [
    ("", "ILA 3", {"a": "x3"}),
    ("", "IHB 3", {"b": "3x"}),
    ("", "ALO 3", {"ar": "x3"}),
    ("", "CLF", {"f": "0"}),
    ("", "STF", {"f": "1"}),
    ("", "RET", {"pc": "01"}),                     # empty stack: NOP
    ("", ".byte 0xA0", {"pc": "01"}),              # undefined: NOP
    ("IMF B, 3", "INV B", {"b": "fc", "a": "xx"}),  # A not read
    ("IMF A, 3", "INV A", {"a": "fc", "b": "xx"}),
    ("IMF A, 3", "INC", {"a": "04", "f": "0"}),     # F written, not read
    ("IMF A, 3\nIMF B, 4", "ADD", {"a": "07", "f": "0"}),
    ("IMF A, 3", "TAR", {"ar": "03"}),
    ("IMF A, 3\nSST A, 1", "SLD B, 1", {"b": "03"}),
    ("CLF", "JF", {"pc": "02", "ar": "xx"}),       # F = 0: AR isn't a target
]


@pytest.mark.parametrize("setup,instr,want", OK,
                         ids=[f"{s.replace(chr(10), '; ')}|{i}"
                              for s, i, _ in OK])
def test_reads_only_what_it_uses(tmp_path, setup, instr, want):
    t = run_asm(tmp_path, f"{setup}\n{instr}\nIMF AR, 0xFE\nJMP\n.org 0xFE\nJMP\n",
                "-n", "100")
    assert t.end == "HALT", t.lines[-1]
    # The instruction under test is the step just before IMF AR, 0xFE.
    i = next(i for i, r in enumerate(t.steps) if r.op == "4e")
    s = t.steps[i - 1].state
    for k, v in want.items():
        assert s[k] == v, (k, s)


def test_unknown_instruction_word_past_program_end(tmp_path):
    t = run_asm(tmp_path, "IMF A, 1\n")
    assert t.end == "ERROR"
    assert t.error == ("02", "xx", "executes unknown instruction word")
    assert len(t.steps) == 2


def test_unknown_instruction_word_in_org_gap(tmp_path):
    t = run_asm(tmp_path, "CLF\n.org 0x10\nSTF\n")
    assert t.error == ("01", "xx", "executes unknown instruction word")

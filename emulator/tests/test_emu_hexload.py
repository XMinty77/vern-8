"""The $readmemh-style loader, with hand-written hex files."""

import pytest

from emuhelp import run_emu, run_raw


def hexfile(tmp_path, text, name="prog.hex"):
    p = tmp_path / name
    p.write_text(text)
    return p


def ops(t):
    return [(r.epc, r.op) for r in t.steps]


def test_comments_markers_and_digit_forms(tmp_path):
    t, _ = run_emu(hexfile(tmp_path, """\
// line comment
0A /* ILA 0xA */ 1f   // 00 ILA a, 01 IHA f (lowercase): A = fa
/* block
   comment over lines */
4_8                   // 02 ALO 8, with a separator
@0_0_03               // separators and leading zeros in a marker
5F                    // 03 AHI f: AR = f8
98                    // 04 JMP f8
@F8 c 4e 5F 98        // f8 ILA c (one digit), f9 ALO e, fa AHI f, fb JMP fe
@fe 98//no space      // fe JMP fe: halt
"""))
    assert ops(t) == [("00", "0a"), ("01", "1f"), ("02", "48"), ("03", "5f"),
                      ("04", "98"), ("f8", "0c"), ("f9", "4e"), ("fa", "5f"),
                      ("fb", "98"), ("fe", "98")]
    assert t.end == "HALT"
    assert (t.last["a"], t.last["pc"]) == ("fc", "fe")


def test_two_digit_words_and_overwrite(tmp_path):
    # Later words at the same address win, as with $readmemh.
    t, _ = run_emu(hexfile(tmp_path, "00 00 00\n@1 97 4e 5f\n@0 96\n@4 98\n"))
    # 00 CLF (overwritten), 01 STF, 02 ALO e, 03 AHI f, 04 JMP fe -> unknown
    assert ops(t) == [("00", "96"), ("01", "97"), ("02", "4e"), ("03", "5f"),
                      ("04", "98")]
    assert t.error == ("fe", "xx", "executes unknown instruction word")


def test_single_digit_word_is_zero_extended(tmp_path):
    t, _ = run_emu(hexfile(tmp_path, "5 1 98\n"))  # ILA 5, ILA 1, JMP (AR unknown)
    assert ops(t) == [("00", "05"), ("01", "01")]
    assert t.error[2] == "reads unknown AR (jump target)"


@pytest.mark.parametrize("word,op", [("x", "xx"), ("xx", "xx"), ("X5", "x5"),
                                     ("5x", "5x"), ("z", "xx"), ("Zz", "xx"),
                                     ("0x", "0x"), ("000x", "0x"), ("x_x", "xx")])
def test_unknown_words(tmp_path, word, op):
    t, _ = run_emu(hexfile(tmp_path, f"96 {word}\n"))
    assert ops(t) == [("00", "96")]
    assert t.error == ("01", op, "executes unknown instruction word")


def test_crlf_and_no_final_newline(tmp_path):
    p = tmp_path / "crlf.hex"
    p.write_bytes(b"96\r\n4e\r\n50\r\n98")  # CLF; AR = 0e; JMP 0e (unknown)
    t, _ = run_emu(p)
    assert t.error == ("0e", "xx", "executes unknown instruction word")


def test_empty_file_is_all_unknown(tmp_path):
    t, _ = run_emu(hexfile(tmp_path, "// nothing\n"))
    assert t.records[0].state["pc"] == "00"
    assert t.error == ("00", "xx", "executes unknown instruction word")


def test_last_address_ff(tmp_path):
    t, _ = run_emu(hexfile(tmp_path, "@0 4f 5f 98\n@ff 98\n"))  # AR = ff; JMP
    assert ops(t)[-2:] == [("02", "98"), ("ff", "98")]
    assert t.end == "HALT" and t.last["pc"] == "ff"


@pytest.mark.parametrize("text,message", [
    ("@100 00\n", "address @100 is past 0xFF"),
    ("@ff 00 00\n", "word 00 is past address 0xFF"),
    ("123\n", "word 123 is wider than 8 bits"),
    ("x12\n", "word x12 is wider than 8 bits"),
    ("0g\n", "unexpected character 'g'"),
    ("12 ; comment\n", "unexpected character ';'"),
    ("@\n", "malformed address"),
    ("@x0\n", "unknown digit in address @x0"),
    ("_12\n", "malformed word"),
    ("12\n/* open\n", "unterminated block comment"),
])
def test_malformed_files(tmp_path, text, message):
    r = run_raw(hexfile(tmp_path, text))
    assert r.returncode == 3
    assert r.stdout == ""
    assert message in r.stderr, r.stderr
    assert "prog.hex:" in r.stderr


def test_error_reports_line(tmp_path):
    r = run_raw(hexfile(tmp_path, "00\n// c\n/* a\nb */\n0q\n"))
    assert "prog.hex:5: unexpected character 'q'" in r.stderr


def test_missing_file(tmp_path):
    r = run_raw(tmp_path / "nope.hex")
    assert r.returncode == 3 and "cannot read" in r.stderr


def test_whole_memory(tmp_path):
    # 256 words: 255 NOPs (undefined 0xA0), then JMP at ff after AR = ff.
    words = ["4f", "5f"] + ["a0"] * 253 + ["98"]
    t, _ = run_emu(hexfile(tmp_path, "\n".join(words) + "\n"), "-n", "1000")
    assert t.end == "HALT"
    assert len(t.steps) == 256
    assert t.last["pc"] == "ff"

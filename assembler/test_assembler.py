"""Tests for the assembler: python3 -m pytest assembler

Expected bytes are written by hand from the encoding map in docs/isa.md. They
must never come from the CSV: the assembler reads the CSV, so that would prove
nothing.
"""

import shutil
import subprocess
import sys
from pathlib import Path

import pytest

from assemble import assemble, format_hex
from isa import read_instructions

ASSEMBLER_DIR = Path(__file__).resolve().parent
ASM = ASSEMBLER_DIR / "asm.py"
CSV = ASSEMBLER_DIR.parent / "docs" / "instructions.csv"

# ================ Helpers ================


def run(source):
    return assemble(source, read_instructions())


def assembled(source):
    """The (address, byte) pairs of a source that must assemble cleanly."""
    words, errors = run(source)
    assert errors == []
    return [(w.address, w.byte) for w in words]


def code(source):
    """The bytes of a source that must assemble cleanly and leave no gaps."""
    pairs = assembled(source)
    assert [a for a, _ in pairs] == list(range(len(pairs)))
    return [b for _, b in pairs]


def error_lines(source):
    """The line of every error in a source."""
    _, errors = run(source)
    return [line for line, _ in errors]


def cli(*args, cwd=None):
    return subprocess.run(
        [sys.executable, str(ASM), *map(str, args)], capture_output=True, text=True, cwd=cwd
    )


# ================ Physical instructions ================

# imm4 instructions: opcode with n = 0. From the encoding map.
PHYSICAL_IMM4 = {
    "ILA": 0x00,
    "IHA": 0x10,
    "ILB": 0x20,
    "IHB": 0x30,
    "ALO": 0x40,
    "AHI": 0x50,
    "SLDA": 0x60,
    "SLDB": 0x70,
    "SSTA": 0xE0,
    "SSTB": 0xF0,
}

# The others. From the encoding map, in the order it lists them.
PHYSICAL_BARE = {
    "INVA": 0x80,
    "INVB": 0x81,
    "ADD": 0x82,
    "SUB": 0x83,
    "MUL": 0x84,
    "DIV": 0x85,
    "SWAP": 0x86,
    "INC": 0x87,
    "AND": 0x88,
    "NAND": 0x89,
    "OR": 0x8A,
    "NOR": 0x8B,
    "XOR": 0x8C,
    "XNOR": 0x8D,
    "SHL": 0x8E,
    "SHR": 0x8F,
    "EQ": 0x90,
    "NEQ": 0x91,
    "LT": 0x92,
    "GTE": 0x93,
    "GT": 0x94,
    "LTE": 0x95,
    "CLF": 0x96,
    "STF": 0x97,
    "JMP": 0x98,
    "JF": 0x99,
    "CALL": 0x9A,
    "RET": 0x9B,
    "TAR": 0xD8,
    "LDA": 0xDC,
    "LDB": 0xDD,
    "STA": 0xDE,
    "STB": 0xDF,
}


def test_the_hand_table_covers_the_whole_csv():
    assert len(PHYSICAL_IMM4) == 10
    assert len(PHYSICAL_BARE) == 33
    names = set(read_instructions()) - {"NOP"}
    assert names == set(PHYSICAL_IMM4) | set(PHYSICAL_BARE)


@pytest.mark.parametrize("name, opcode", PHYSICAL_IMM4.items())
def test_physical_imm4_every_value(name, opcode):
    for n in range(16):
        assert code(f"{name} {n}") == [opcode + n]


@pytest.mark.parametrize("name, opcode", PHYSICAL_BARE.items())
def test_physical_bare(name, opcode):
    assert code(name) == [opcode]


@pytest.mark.parametrize("name", PHYSICAL_IMM4)
def test_physical_imm4_needs_exactly_one_operand(name):
    assert error_lines(name) == [1]
    assert error_lines(f"{name} 1, 2") == [1]
    assert error_lines(f"{name} 16") == [1]


@pytest.mark.parametrize("name", set(PHYSICAL_BARE) - {"JMP", "JF", "CALL"})
def test_physical_bare_takes_no_operand(name):
    assert error_lines(f"{name} 3") == [1]


# ================ Register forms ================


@pytest.mark.parametrize(
    "source, byte",
    [
        ("IML A, 5", 0x05),
        ("IML B, 5", 0x25),
        ("IML AR, 5", 0x45),
        ("IMH A, 5", 0x15),
        ("IMH B, 5", 0x35),
        ("IMH AR, 5", 0x55),
        ("INV A", 0x80),
        ("INV B", 0x81),
        ("SLD A, 5", 0x65),
        ("SLD B, 5", 0x75),
        ("SST A, 5", 0xE5),
        ("SST B, 5", 0xF5),
        ("LD A", 0xDC),
        ("LD B", 0xDD),
        ("ST A", 0xDE),
        ("ST B", 0xDF),
    ],
)
def test_register_forms(source, byte):
    assert code(source) == [byte]


@pytest.mark.parametrize(
    "source",
    ["INV AR", "SLD AR, 1", "SST AR, 1", "LD AR", "ST AR", "IML A", "IML 1", "IML 1, A", "INV"],
)
def test_register_forms_reject(source):
    assert error_lines(source) == [1]


# ================ Emulated instructions ================


@pytest.mark.parametrize(
    "source, expected",
    [
        ("IMF A, 0xAF", [0x0F, 0x1A]),
        ("IMF B, 0xAF", [0x2F, 0x3A]),
        ("IMF AR, 0xAF", [0x4F, 0x5A]),
        ("IMF A, 0", [0x00, 0x10]),  # No redundant nibble dropped
        ("JMP 0xAF", [0x4F, 0x5A, 0x98]),
        ("JF 0xAF", [0x4F, 0x5A, 0x99]),
        ("CALL 0xAF", [0x4F, 0x5A, 0x9A]),
        ("JMP AR", [0x98]),
        ("JF AR", [0x99]),
        ("CALL AR", [0x9A]),
        ("JMP A", [0xD8, 0x98]),
        ("JF A", [0xD8, 0x99]),
        ("CALL A", [0xD8, 0x9A]),
        ("JMP B", [0x86, 0xD8, 0x86, 0x98]),
        ("JF B", [0x86, 0xD8, 0x86, 0x99]),
        ("CALL B", [0x86, 0xD8, 0x86, 0x9A]),
        ("LD A, 255", [0x4F, 0x5F, 0xDC]),  # The last address is in range
        ("ST A, 255", [0x4F, 0x5F, 0xDE]),
        ("LD A, 0x3C", [0x4C, 0x53, 0xDC]),
        ("LD B, 0x3C", [0x4C, 0x53, 0xDD]),
        ("LD A, 5", [0x45, 0x50, 0xDC]),  # Never turned into SLD
        ("LD A, AR", [0xDC]),
        ("LD B, AR", [0xDD]),
        ("LD A, A", [0xD8, 0xDC]),
        ("LD B, A", [0xD8, 0xDD]),
        ("LD A, B", [0x86, 0xD8, 0x86, 0xDC]),
        ("LD B, B", [0x86, 0xD8, 0x86, 0xDD]),
        ("ST A, 0x3C", [0x4C, 0x53, 0xDE]),
        ("ST B, 0x3C", [0x4C, 0x53, 0xDF]),
        ("ST A, 5", [0x45, 0x50, 0xDE]),  # Never turned into SST
        ("ST A, AR", [0xDE]),
        ("ST B, AR", [0xDF]),
        ("ST A, A", [0xD8, 0xDE]),
        ("ST B, A", [0xD8, 0xDF]),
        ("ST A, B", [0x86, 0xD8, 0x86, 0xDE]),
        ("ST B, B", [0x86, 0xD8, 0x86, 0xDF]),
        ("JFE 0x12, 0x34", [0x42, 0x51, 0x99, 0x44, 0x53, 0x98]),
        ("JFE 0x12, 0xAF", [0x42, 0x51, 0x99, 0x4F, 0x5A, 0x98]),  # All of y's low nibble
    ],
)
def test_emulated_expansions(source, expected):
    assert code(source) == expected


@pytest.mark.parametrize(
    "mnemonic, compare",
    [
        ("JEQ", 0x90),
        ("JNEQ", 0x91),
        ("JLT", 0x92),
        ("JGTE", 0x93),
        ("JGT", 0x94),
        ("JLTE", 0x95),
    ],
)
def test_compare_and_jump(mnemonic, compare):
    assert code(f"{mnemonic} 0xAF") == [compare, 0x4F, 0x5A, 0x99]
    assert code(f"{mnemonic} AR") == [compare, 0x99]
    assert code(f"{mnemonic} A") == [compare, 0xD8, 0x99]
    assert code(f"{mnemonic} B") == [compare, 0x86, 0xD8, 0x86, 0x99]
    assert error_lines(mnemonic) == [1]  # Bare is an error
    assert error_lines(f"{mnemonic} 1, 2") == [1]


@pytest.mark.parametrize(
    "source",
    [
        "IMF A",
        "IMF A, B",
        "IMF 5",
        "JMP 1, 2",
        "JFE A, B",
        "JFE AR, 1",
        "JFE 1",
        "JFE 1, 2, 3",
        "LD 5",
        "LD 5, A",
        "ST 5, A",  # The register always comes first
        "LD AR, 5",
    ],
)
def test_emulated_forms_reject(source):
    assert error_lines(source) == [1]


def test_halt_jumps_to_its_own_jmp():
    assert code("HALT") == [0x42, 0x50, 0x98]
    assert assembled(".org 0x10\nHALT") == [(0x10, 0x42), (0x11, 0x51), (0x12, 0x98)]
    assert assembled(".org 0xFD\nHALT") == [(0xFD, 0x4F), (0xFE, 0x5F), (0xFF, 0x98)]
    assert error_lines("HALT 5") == [1]


def test_nop_is_0xa0_and_takes_no_operand():
    assert code("NOP") == [0xA0]
    assert error_lines("NOP 1") == [1]


def test_byte_emits_one_raw_word():
    assert code(".byte 0xC7") == [0xC7]
    assert code(".byte 0") == [0x00]
    assert code(".byte 255") == [0xFF]
    assert code(".equ c, 9\n.byte c") == [0x09]
    assert error_lines(".byte 256") == [1]
    assert error_lines(".byte") == [1]
    assert error_lines(".byte 1, 2") == [1]
    assert error_lines(".byte A") == [1]


# ================ Labels and constants ================


def test_labels_forward_and_backward():
    source = """
    start: JMP end      ; 00-02
           NOP          ; 03
    end:   JMP start    ; 04-06
    """
    assert code(source) == [0x44, 0x50, 0x98, 0xA0, 0x40, 0x50, 0x98]


def test_label_only_line_names_the_next_word():
    source = """
    NOP
    here:

    NOP
    JMP here
    """
    assert code(source) == [0xA0, 0xA0, 0x41, 0x50, 0x98]


def test_label_on_byte_names_that_word():
    assert code("NOP\nd: .byte 1\nJMP d") == [0xA0, 0x01, 0x41, 0x50, 0x98]


def test_label_only_line_before_org_names_the_word_after_it():
    assert assembled("x:\n.org 0x10\nJMP x") == [(0x10, 0x40), (0x11, 0x51), (0x12, 0x98)]


def test_label_on_org_names_the_word_after_it():
    assert assembled("x: .org 0x10\nJMP x") == [(0x10, 0x40), (0x11, 0x51), (0x12, 0x98)]
    assert assembled("NOP\nx: .org 0x10\nNOP\nJMP x")[-3:] == [(0x11, 0x40), (0x12, 0x51), (0x13, 0x98)]


def test_label_on_a_bad_org_stays_defined():
    assert error_lines("x: .org 999\nNOP\nJMP x") == [1]


def test_labels_work_in_imf_jcc_and_jfe():
    source = """
    a1: IMF A, a2
    a2: JEQ a1
        JFE a1, a2
    """
    assert code(source) == [0x02, 0x10, 0x90, 0x40, 0x50, 0x99, 0x40, 0x50, 0x99, 0x42, 0x50, 0x98]


def test_equ_forward_and_backward_and_everywhere():
    source = """
    .equ before, 3
    IML A, before
    IML B, after
    LD A, after
    JMP after
    .byte after
    .equ after, 4
    """
    assert code(source) == [0x03, 0x24, 0x44, 0x50, 0xDC, 0x44, 0x50, 0x98, 0x04]


def test_equ_can_set_org():
    assert assembled(".org there\nNOP\n.equ there, 0x10") == [(0x10, 0xA0)]


def test_equ_range_is_checked_at_definition_and_at_use():
    assert error_lines(".equ big, 16\nIML A, big") == [2]
    assert code(".equ big, 15\nIML A, big") == [0x0F]
    assert error_lines(".equ big, 256") == [1]
    assert code(".equ big, 255\nIMF A, big") == [0x0F, 0x1F]


# ================ .org and the memory limit ================


def test_org_moves_forward_and_same_address_is_fine():
    assert assembled("NOP\n.org 5\nNOP") == [(0, 0xA0), (5, 0xA0)]
    assert assembled("NOP\n.org 1\nNOP") == [(0, 0xA0), (1, 0xA0)]
    assert assembled(".org 0\nNOP") == [(0, 0xA0)]


def test_org_rejects():
    assert error_lines("NOP\nNOP\n.org 1") == [3]  # Backward
    assert error_lines(".org 256") == [1]
    assert error_lines(".org") == [1]
    assert error_lines(".org 1, 2") == [1]
    assert error_lines(".org A") == [1]
    assert error_lines(".org x\nx: NOP") == [1]  # A label is an error
    assert error_lines(".org nothing") == [1]


def test_a_bad_org_leaves_the_address_where_it_was():
    for bad in (".org 999", ".org nothing", ".org 1, 2"):
        words, errors = run(f"NOP\n{bad}\nNOP")
        assert [line for line, _ in errors] == [2]
        assert [w.address for w in words] == [0, 1]
    words, errors = run(".org 0x10\n.org 1\nNOP")  # Backward
    assert [line for line, _ in errors] == [2]
    assert [w.address for w in words] == [0x10]


def test_the_last_word_is_0xff():
    assert assembled(".org 0xFF\nNOP") == [(0xFF, 0xA0)]
    assert code("\n".join(["NOP"] * 256)) == [0xA0] * 256


def test_past_the_last_word():
    assert error_lines("\n".join(["NOP"] * 257)) == [257]
    assert error_lines(".org 0xFF\nNOP\nNOP") == [3]


def test_an_overrun_is_reported_once_at_its_first_statement():
    assert error_lines("\n".join(["NOP"] * 1000)) == [257]
    assert error_lines(".org 0xFE\nHALT\nHALT\nNOP") == [2]  # HALT is the first to go past
    assert error_lines(".org 0xFF\nNOP\nNOP\np:\nNOP\nq: NOP") == [3]  # Labels further out too


def test_an_overrun_does_not_hide_other_errors():
    assert error_lines("\n".join(["NOP"] * 258 + ["FOO", "IML A, 16"])) == [257, 259, 260]


@pytest.mark.parametrize("source", ["IMF A, 1", "JMP 1", "HALT", "JFE 1, 2", "LD A, B"])
def test_no_wrapping_part_way_through_an_emulated_instruction(source):
    assert error_lines(f".org 0xFF\n{source}") == [2]


def test_halt_at_the_boundary():
    assert error_lines(".org 0xFE\nHALT") == [2]
    assert error_lines(".org 0xFD\nHALT") == []


def test_label_at_0xff_is_fine_and_at_0x100_is_not():
    assert assembled(".org 0xFF\nend: JMP AR") == [(0xFF, 0x98)]
    assert error_lines(".org 0xFF\nNOP\nend:") == [3]
    # Even unused and with nothing after it, and with a word on its line
    assert error_lines(".org 0xFF\nNOP\nend: NOP") == [3, 3]


# ================ Syntax ================


@pytest.mark.parametrize("marker", [";", "#", "%", "//"])
def test_comment_markers(marker):
    assert code(f"NOP {marker} ADD") == [0xA0]
    assert code(f"NOP{marker}ADD") == [0xA0]
    assert code(f"{marker} ADD") == []
    assert code(f"  {marker} ADD") == []
    assert code(f"x: {marker} ADD\nJMP x") == [0x40, 0x50, 0x98]


def test_earliest_comment_marker_wins():
    assert code("NOP ; ADD // SUB # MUL % DIV") == [0xA0]
    assert code("NOP // ADD ; SUB") == [0xA0]


def test_a_lone_slash_is_not_a_comment():
    assert error_lines("NOP / ADD") == [1]


@pytest.mark.parametrize("text", ["42", "0x2A", "0X2a", "0b101010", "0B101010", "042"])
def test_number_formats(text):
    assert code(f".byte {text}") == [42]


@pytest.mark.parametrize(
    "text", ["-1", "-0", "0x", "0b", "0b2", "0xG", "1a", "4 2", "+1", "1_000", "2.0", "٣", "9" * 5000]
)
def test_malformed_or_negative_numbers(text):
    assert error_lines(f".byte {text}") == [1]


def test_operand_whitespace_does_not_matter():
    assert code("IML A,5") == [0x05]
    assert code("  IML\tA  ,\t 5  ") == [0x05]


def test_empty_operands_are_errors():
    assert error_lines("IML A,") == [1]
    assert error_lines("IML ,5") == [1]
    assert error_lines("JFE 1,,2") == [1]


def test_mnemonics_directives_and_registers_ignore_case():
    assert code("add\nAdD\nimf a, 1\nIMF ar, 1\njmp Ar\nJmP b") == [
        0x82, 0x82, 0x01, 0x10, 0x41, 0x50, 0x98, 0x86, 0xD8, 0x86, 0x98,
    ]
    assert assembled(".ORG 1\n.BYTE 2\n.EQU c, 3\n.Byte c") == [(1, 2), (2, 3)]


def test_names_are_case_sensitive():
    assert code("Loop: NOP\nloop: NOP\nJMP loop") == [0xA0, 0xA0, 0x41, 0x50, 0x98]
    assert code(".equ c, 1\n.equ C, 2\n.byte c\n.byte C") == [1, 2]
    assert error_lines("Loop: NOP\nJMP loop") == [2]


@pytest.mark.parametrize("word", ["ıla 5", "ſub", "ſt a", "ﬅ a", "ßta"])
def test_non_ascii_lookalikes_are_not_mnemonics(word):
    # Each of these uppercases to a real mnemonic in Python
    assert error_lines(word) == [1]


@pytest.mark.parametrize("line", ["x : NOP", "x\t: NOP", "  x  :  NOP"])
def test_whitespace_around_a_label_does_not_matter(line):
    assert code(f"{line}\nJMP x") == [0xA0, 0x40, 0x50, 0x98]


@pytest.mark.parametrize("name", ["_x", "x1", "_", "A1", "x_y", "LDX"])
def test_good_names(name):
    assert error_lines(f"{name}: NOP") == []
    assert error_lines(f".equ {name}, 1") == []


@pytest.mark.parametrize("name", ["1x", "a-b", "a.b", "", "a b"])
def test_bad_label_names(name):
    assert error_lines(f"{name}: NOP") == [1]


@pytest.mark.parametrize("name", ["1x", "a-b", "a.b", "", ".equ"])
def test_bad_constant_names(name):
    assert error_lines(f".equ {name}, 1") == [1]


@pytest.mark.parametrize(
    "name",
    [
        # Physical, emulated, register and directive names, in any case
        "ADD", "add", "Add", "ila", "jmp", "tar",
        "IML", "imh", "INV", "sld", "SST", "ld", "St", "IMF", "JFE", "jeq", "JNEQ", "jlt", "JGTE",
        "jgt", "JLTE", "HALT", "halt", "NOP", "nop",
        "A", "a", "B", "b", "AR", "ar", "aR",
        "equ", "ORG", "Byte",
    ],
)
def test_reserved_names(name):
    assert error_lines(f"{name}: NOP") == [1]
    assert error_lines(f".equ {name}, 1") == [1]


# ================ Output format ================


def test_hex_format_matches_the_spec_example():
    source = """
    IMF A, 0xFA
    JMP
    .org 0xFE
    NOP
    .byte 0xC7
    """
    assert format_hex(run(source)[0]) == (
        "0A // 00: ILA 0xA\n"
        "1F // 01: IHA 0xF\n"
        "98 // 02: JMP\n"
        "@FE\n"
        "A0 // FE: NOP\n"
        "C7 // FF: .byte 0xC7\n"
    )


def test_marker_only_where_org_leaves_a_gap():
    def text(source):
        return format_hex(run(source)[0])

    assert text(".org 0\nNOP\n.org 1\nNOP") == "A0 // 00: NOP\nA0 // 01: NOP\n"
    assert text(".org 0x0A\nNOP") == "@0A\nA0 // 0A: NOP\n"
    assert text(".org 0x10\n.org 0x20\nNOP") == "@20\nA0 // 20: NOP\n"
    assert text("NOP\n.org 0x20") == "A0 // 00: NOP\n"  # No next word, no marker
    assert text("") == ""


def test_listing_shows_physical_instructions_not_the_source_form():
    assert format_hex(run("LD B, 0xAB\nhere: JEQ here")[0]) == (
        "4B // 00: ALO 0xB\n"
        "5A // 01: AHI 0xA\n"
        "DD // 02: LDB\n"
        "90 // 03: EQ\n"
        "43 // 04: ALO 0x3\n"
        "50 // 05: AHI 0x0\n"
        "99 // 06: JF\n"
    )


# ================ Errors ================


@pytest.mark.parametrize(
    "source, line, fragment",
    [
        ("NOP\nFOO", 2, "unknown mnemonic"),
        (".foo 1", 1, "unknown directive .foo"),  # As written, not uppercased
        ("foo", 1, "unknown mnemonic foo"),
        ("ıla 5", 1, "unknown mnemonic ıla"),
        ("ADD 3", 1, "bad operands"),
        ("LDA 5", 1, "bad operands"),
        ("INV AR", 1, "bad operands"),
        ("JFE A, B", 1, "bad operands"),
        ("loop: NOP\nIML A, loop", 2, "label loop"),
        ("loop: NOP\nLD A, loop", 2, "label loop"),
        ("loop: NOP\nST A, loop", 2, "label loop"),
        ("loop: NOP\n.byte loop", 2, "label loop"),
        ("IML A, loop\nloop: NOP", 1, "label loop"),  # Forward, and an address under 16
        ("IML A, 16", 1, "out of range"),
        ("IMF A, 256", 1, "out of range"),
        ("JMP 256", 1, "out of range"),
        ("LD A, 256", 1, "out of range"),
        ("JFE 1, 256", 1, "out of range"),
        ("IML A, 0xZ", 1, "malformed"),
        ("IML A, -1", 1, "negative"),
        ("JMP -0x10", 1, "negative"),
        ("JMP -x", 1, "malformed"),  # A minus sign alone doesn't make a number
        ("JMP -", 1, "malformed"),
        ("JMP --1", 1, "malformed"),
        ("JMP nowhere", 1, "undefined"),
        ("x: NOP\nx: NOP", 2, "already defined"),
        (".equ x, 1\n.equ x, 2", 2, "already defined"),
        ("x: NOP\n.equ x, 1", 2, "already defined"),
        (".equ x, 1\nx: NOP", 2, "already defined"),
        ("ADD: NOP", 1, "mnemonic, directive or register"),
        (".equ b, 1", 1, "mnemonic, directive or register"),
        ("a1: a2: NOP", 1, "more than one label"),
        ("x: .equ y, 1", 1, "share a line"),
        ("NOP\n.org 0", 2, "backward"),
        ("x: NOP\n.org x", 2, "label x"),  # Not "backward", though x is behind too
        (".org x\nx: NOP", 1, "label x"),
        (".org 0xFF\nNOP\nNOP", 3, "past 0xFF"),
        (".org 0xFF\nNOP\nx:", 3, "past 0xFF"),
        (".equ x, y\n.equ y, 1", 1, "bad .equ value"),
        (".equ x, 256", 1, "out of range"),
        (".equ x, -1", 1, "negative"),
        (".equ x", 1, "name and a number"),
        (".equ x, 1, 2", 1, "name and a number"),
    ],
)
def test_each_error(source, line, fragment):
    _, errors = run(source)
    assert len(errors) == 1
    assert errors[0][0] == line
    assert fragment in errors[0][1]


def test_every_error_is_reported_together_in_line_order():
    source = """NOP
    FOO
    ADD 3
    IML A, 16
    JMP nowhere
    x: NOP
    x: NOP
    IML A, x
    a1: a2: NOP
    y: .org 0x90
    .org 0x10
    .equ big, 300
    JFE gone, missing
    NOP
    """
    lines = error_lines(source)
    assert lines == [2, 3, 4, 5, 7, 8, 9, 11, 12, 13, 13]


def test_one_bad_equ_does_not_also_fail_its_uses():
    assert error_lines(".equ big, 300\nIML A, big\nJMP big") == [1]


def test_a_bad_statement_does_not_stop_later_passes():
    # The unknown mnemonic is found while laying out, the range error while encoding
    assert error_lines("FOO\nIML A, 16") == [1, 2]


# ================ Command line ================


def test_cli_success(tmp_path):
    source = tmp_path / "ok.s"
    source.write_text("NOP\n")
    output = tmp_path / "ok.hex"
    result = cli(source, "-o", output)
    assert (result.returncode, result.stderr) == (0, "")
    assert output.read_text() == "A0 // 00: NOP\n"


def test_cli_reports_all_errors_as_file_line_message_and_writes_nothing(tmp_path):
    source = tmp_path / "bad.s"
    source.write_text("NOP\nFOO\nNOP\nIML A, 16\n")
    output = tmp_path / "bad.hex"
    result = cli(source, "-o", output)
    assert result.returncode != 0
    lines = result.stderr.splitlines()
    assert len(lines) == 2
    assert lines[0].startswith(f"{source}:2: ")
    assert lines[1].startswith(f"{source}:4: ")
    assert not output.exists()


def test_cli_error_leaves_an_existing_output_unchanged(tmp_path):
    source = tmp_path / "bad.s"
    source.write_text("FOO\n")
    output = tmp_path / "old.hex"
    output.write_text("keep me\n")
    assert cli(source, "-o", output).returncode != 0
    assert output.read_text() == "keep me\n"


def test_cli_refuses_to_overwrite_the_source(tmp_path):
    source = tmp_path / "ok.s"
    source.write_text("NOP\n")
    (tmp_path / "link.s").symlink_to(source)
    for output in ("ok.s", "./ok.s", "link.s", tmp_path / "ok.s"):
        result = cli("ok.s", "-o", output, cwd=tmp_path)
        assert result.returncode != 0
        assert "overwrite the source" in result.stderr
        assert source.read_text() == "NOP\n"


def test_cli_accepts_a_bom(tmp_path):
    source = tmp_path / "bom.s"
    source.write_bytes(b"\xef\xbb\xbfNOP\nFOO\n")
    result = cli(source, "-o", tmp_path / "bom.hex")
    assert result.stderr.splitlines() == [f"{source}:2: unknown mnemonic FOO"]  # The NOP is fine


def test_cli_creates_the_output_folder(tmp_path):
    source = tmp_path / "ok.s"
    source.write_text("NOP\n")
    output = tmp_path / "new" / "deeper" / "ok.hex"
    result = cli(source, "-o", output)
    assert (result.returncode, result.stderr) == (0, "")
    assert output.read_text() == "A0 // 00: NOP\n"


def test_cli_error_creates_no_output_folder(tmp_path):
    source = tmp_path / "bad.s"
    source.write_text("FOO\n")
    folder = tmp_path / "new"
    assert cli(source, "-o", folder / "bad.hex").returncode != 0
    assert not folder.exists()


def test_cli_cant_write_the_output(tmp_path):
    source = tmp_path / "ok.s"
    source.write_text("NOP\n")
    not_a_folder = tmp_path / "file"
    not_a_folder.write_text("keep me\n")
    result = cli(source, "-o", not_a_folder / "ok.hex")
    assert result.returncode != 0
    assert "can't write" in result.stderr
    assert "Traceback" not in result.stderr
    assert not_a_folder.read_text() == "keep me\n"


def test_cli_o_is_required(tmp_path):
    source = tmp_path / "ok.s"
    source.write_text("NOP\n")
    result = cli(source)
    assert result.returncode != 0
    assert "-o" in result.stderr
    assert "Traceback" not in result.stderr


def test_cli_missing_source(tmp_path):
    output = tmp_path / "out.hex"
    result = cli(tmp_path / "missing.s", "-o", output)
    assert result.returncode != 0
    assert "Traceback" not in result.stderr
    assert not output.exists()


def test_cli_finds_the_csv_from_any_working_directory(tmp_path):
    source = tmp_path / "ok.s"
    source.write_text("ADD\n")
    output = tmp_path / "ok.hex"
    assert cli(source, "-o", output, cwd=tmp_path).returncode == 0
    assert output.read_text() == "82 // 00: ADD\n"


# ================ The ISA table ================


def csv_with_row(tmp_path, row):
    path = tmp_path / "instructions.csv"
    path.write_text(CSV.read_text() + row + "\n")
    return path


@pytest.mark.parametrize(
    "bits",
    [
        "1,0,1,0,0,0,0,0",  # Exactly 0xA0
        "1,0,1,0,imm4,imm4,imm4,imm4",  # A pattern that includes 0xA0
    ],
)
def test_refuses_to_run_if_the_csv_takes_the_nop_byte(tmp_path, bits):
    path = csv_with_row(tmp_path, f"NEW,,{bits},,,,WU")
    with pytest.raises(SystemExit) as e:
        read_instructions(path)
    assert "0xA0" in str(e.value)


def test_a_csv_row_next_to_the_nop_byte_is_fine(tmp_path):
    path = csv_with_row(tmp_path, "NEW,,1,0,1,0,0,0,0,1,,,,WU")
    assert read_instructions(path)["NEW"] == (0xA1, False)


@pytest.mark.parametrize(
    "row, fragment",
    [
        ("ADD,,1,0,1,0,0,0,0,1,,,,ALU", "duplicate instruction ADD"),
        ("NEW,,1,0,1,0,0,0,0,2,,,,WU", "NEW b0 is '2'"),
        ("NEW,,1,0,1,0,0,0,0,,,,,WU", "NEW b0 is ''"),
        ("NEW,,1,0,1,0,0,0,imm4,imm4,,,,WU", "imm4 somewhere"),  # Only part of b3 to b0
        ("NEW,,imm4,imm4,imm4,imm4,0,0,0,0,,,,WU", "imm4 somewhere"),  # Only the high bits
        ("NEW,,1,0,1,imm4,imm4,imm4,imm4,imm4,,,,WU", "imm4 somewhere"),  # One bit too many
    ],
)
def test_refuses_a_bad_csv_row(tmp_path, row, fragment):
    with pytest.raises(SystemExit) as e:
        read_instructions(csv_with_row(tmp_path, row))
    assert fragment in str(e.value)


@pytest.mark.parametrize(
    "row, fragment",
    [
        ("DUP,,1,0,0,0,0,0,1,0,,,,ALU", "DUP and ADD both use 0x82"),  # The same code
        ("DUP,,0,0,0,0,0,1,0,1,,,,WU", "DUP and ILA both use 0x05"),  # Inside a pattern
        ("DUP,,0,0,0,0,1,1,1,1,,,,WU", "DUP and ILA both use 0x0F"),  # A pattern's last code
        ("DUP,,1,0,0,0,imm4,imm4,imm4,imm4,,,,ALU", "DUP and INVA both use 0x80"),  # Over a code
    ],
)
def test_refuses_two_rows_on_one_code(tmp_path, row, fragment):
    with pytest.raises(SystemExit) as e:
        read_instructions(csv_with_row(tmp_path, row))
    assert fragment in str(e.value)


@pytest.mark.parametrize(
    "name", ["NOP", "JEQ", "JFE", "HALT", "IMF", "IML", "INV", "LD", "A", "B", "AR", "EQU", "ORG", "BYTE"]
)
def test_refuses_a_row_named_like_something_else(tmp_path, name):
    # 0xB0 is free, so the name is the only thing wrong with this row
    path = csv_with_row(tmp_path, f"{name},,1,0,1,1,0,0,0,0,,,,WU")
    with pytest.raises(SystemExit) as e:
        read_instructions(path)
    assert f"{name} can't be an instruction" in str(e.value)


@pytest.mark.parametrize(
    "old, new, column",
    [("Name,", "Mnemonic,", "Name"), (",b7,", ",bit7,", "b7"), (",b0,", ",bit0,", "b0")],
)
def test_refuses_a_csv_missing_a_column(tmp_path, old, new, column):
    path = tmp_path / "instructions.csv"
    path.write_text(CSV.read_text().replace(old, new, 1))
    with pytest.raises(SystemExit) as e:
        read_instructions(path)
    assert f"no column {column}" in str(e.value)


def test_refuses_an_empty_csv(tmp_path):
    path = tmp_path / "instructions.csv"
    path.write_text("")
    with pytest.raises(SystemExit) as e:
        read_instructions(path)
    assert "no column Name" in str(e.value)


def test_refuses_a_missing_csv(tmp_path):
    with pytest.raises(SystemExit) as e:
        read_instructions(tmp_path / "missing.csv")
    assert "can't read" in str(e.value)


def test_the_real_cli_refuses_too(tmp_path):
    # The CSV is found relative to the assembler, so run a copy of the assembler
    copy = tmp_path / "assembler"
    copy.mkdir()
    for path in ASSEMBLER_DIR.glob("*.py"):
        shutil.copy(path, copy)
    (tmp_path / "docs").mkdir()
    (tmp_path / "docs" / "instructions.csv").write_text(
        CSV.read_text() + "NEW,,1,0,1,0,0,0,0,0,,,,WU\n"
    )
    source = tmp_path / "ok.s"
    source.write_text("ADD\n")
    output = tmp_path / "ok.hex"
    result = subprocess.run(
        [sys.executable, str(copy / "asm.py"), str(source), "-o", str(output)],
        capture_output=True,
        text=True,
    )
    assert result.returncode != 0
    assert "0xA0" in result.stderr
    assert not output.exists()

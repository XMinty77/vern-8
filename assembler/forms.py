"""The source language: what each mnemonic accepts and the words it becomes.

A Form is one way of writing a mnemonic:
- operands: each is a register name, which must appear literally, or a kind
  (see KINDS), which stands for a number or a name.
- words: each is "NAME" or "NAME part", where part says what fills the word's
  imm4 (see PARTS).

To add or change a form, edit build_forms.
"""

from collections import namedtuple

Form = namedtuple("Form", "operands words")

REGISTERS = ("A", "B", "AR")

IMM4, VALUE, DATA, RAW, ADDRESS = "imm4", "value", "data address", "raw", "address"

# Operand kind: (largest value, whether a label is allowed)
KINDS = {
    IMM4: (15, False),
    VALUE: (255, True),
    DATA: (255, False),
    RAW: (255, False),
    ADDRESS: (255, False),
}

# What fills a word, given the values of the form's non-register operands
PARTS = {
    "n": lambda values: values[0],
    "lo": lambda values: values[0] & 0xF,
    "hi": lambda values: values[0] >> 4,
    "lo2": lambda values: values[1] & 0xF,
    "hi2": lambda values: values[1] >> 4,
}

JUMPS = ("JMP", "JF", "CALL")  # Physical when bare, emulated with an operand
COMPARE_JUMPS = {"JEQ": "EQ", "JNEQ": "NEQ", "JLT": "LT", "JGTE": "GTE", "JGT": "GT", "JLTE": "LTE"}


def build_forms(instructions):
    """Return {mnemonic: [Form, ...]}, physical instructions first."""
    forms = {}

    def add(mnemonic, operands, *words):
        forms.setdefault(mnemonic, []).append(Form(operands, words))

    def add_through_ar(mnemonic, first, kind, *before, op):
        # Every way of getting a target into AR, then op: the shape shared by
        # the jumps, the memory forms and the compare-and-jumps.
        add(mnemonic, (*first, kind), *before, "ALO lo", "AHI hi", op)
        add(mnemonic, (*first, "AR"), *before, op)
        add(mnemonic, (*first, "A"), *before, "TAR", op)
        add(mnemonic, (*first, "B"), *before, "SWAP", "TAR", "SWAP", op)

    # Physical, from the CSV (and NOP, which isa.py adds to it)
    for name, (_, takes_imm4) in instructions.items():
        if takes_imm4:
            add(name, (IMM4,), f"{name} n")
        else:
            add(name, (), name)

    # Register forms and full immediates
    for r, low, high in (("A", "ILA", "IHA"), ("B", "ILB", "IHB"), ("AR", "ALO", "AHI")):
        add("IML", (r, IMM4), f"{low} n")
        add("IMH", (r, IMM4), f"{high} n")
        add("IMF", (r, VALUE), f"{low} lo", f"{high} hi")

    for r in ("A", "B"):
        add("INV", (r,), f"INV{r}")
        add("SLD", (r, IMM4), f"SLD{r} n")
        add("SST", (r, IMM4), f"SST{r} n")
        add("LD", (r,), f"LD{r}")
        add("ST", (r,), f"ST{r}")
        add_through_ar("LD", (r,), DATA, op=f"LD{r}")
        add_through_ar("ST", (r,), DATA, op=f"ST{r}")

    # Jumps
    for op in JUMPS:
        add_through_ar(op, (), VALUE, op=op)
    for mnemonic, compare in COMPARE_JUMPS.items():
        add_through_ar(mnemonic, (), VALUE, compare, op="JF")
    add("JFE", (VALUE, VALUE), "ALO lo", "AHI hi", "JF", "ALO lo2", "AHI hi2", "JMP")
    add("HALT", (), "ALO lo", "AHI hi", "JMP")  # Its value is its own JMP: see Assembler.encode

    # Directives, except .equ, which is a definition rather than a form
    add(".BYTE", (RAW,), ".byte n")
    add(".ORG", (ADDRESS,))
    return forms


def reserved_names(forms):
    """Names no label or constant can have, in uppercase. Directives count without their dot."""
    return {mnemonic.lstrip(".") for mnemonic in forms} | {"EQU"} | set(REGISTERS)


def taken_names():
    """Names a CSV row can't have: what the source language defines itself, apart from JUMPS."""
    return reserved_names(build_forms({})) - set(JUMPS)


def fits(form, operands):
    """Whether these operands (raw text) have the form's number and shape."""
    if len(form.operands) != len(operands):
        return False
    for expected, operand in zip(form.operands, operands):
        if expected in REGISTERS:
            if operand.upper() != expected:
                return False
        elif operand.upper() in REGISTERS:
            return False
    return True


def describe(mnemonic, form):
    return f"{mnemonic} {', '.join(form.operands)}".strip()

"""Read the instruction table from docs/instructions.csv."""

import csv
import sys
from pathlib import Path

from forms import taken_names

# Next to the assembler, not the working directory.
CSV_PATH = Path(__file__).resolve().parent.parent / "docs" / "instructions.csv"
BITS = [f"b{i}" for i in range(7, -1, -1)]  # CSV columns, MSB first
NOP_BYTE = 0xA0  # An undefined opcode, which the ISA says behaves as a NOP


def fail(msg):
    sys.exit(f"asm: {msg}")


def read_instructions(csv_path=CSV_PATH):
    """Return {name: (opcode, takes_imm4)}, with the imm4 bits of opcode at 0.

    NOP is in there too, though it has no CSV row, once it's sure to be free.
    """
    try:
        with open(csv_path, newline="") as f:
            reader = csv.DictReader(f)
            rows = list(reader)
            columns = reader.fieldnames or []
    except OSError as e:
        fail(f"can't read {csv_path}: {e}")

    for column in ("Name", *BITS):
        if column not in columns:
            fail(f"{csv_path} has no column {column}")

    taken = taken_names() | {"NOP"}
    used = {NOP_BYTE: "NOP"}  # {code: name}. NOP relies on its code being undefined
    instructions = {}
    for row in rows:
        name = row["Name"]
        if name in instructions:
            fail(f"duplicate instruction {name}")
        if name in taken:
            fail(f"{name} can't be an instruction, the assembler already uses that name")

        bits = [row[b] for b in BITS]
        for b, value in zip(BITS, bits):
            if value not in ("0", "1", "imm4"):
                fail(f"{name} {b} is {value!r}, expected 0, 1 or imm4")
        takes_imm4 = "imm4" in bits
        if takes_imm4 and bits[4:] != ["imm4"] * 4 or "imm4" in bits[:4]:
            fail(f"{name} has imm4 somewhere other than b3 to b0")

        opcode = int("".join("0" if bit == "imm4" else bit for bit in bits), 2)
        for code in range(opcode, opcode + 16) if takes_imm4 else (opcode,):
            if code in used:
                fail(f"{name} and {used[code]} both use 0x{code:02X}")
            used[code] = name
        instructions[name] = (opcode, takes_imm4)

    instructions["NOP"] = (NOP_BYTE, False)
    return instructions

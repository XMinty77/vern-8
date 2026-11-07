#!/usr/bin/env python3
"""Assembler for Vernacular 8.

Usage: python3 assembler/asm.py <source> -o <output.hex>

The work is split by job: source.py reads the syntax, forms.py says what each
mnemonic means, assemble.py turns statements into words, and isa.py reads the
opcodes from docs/instructions.csv.
"""

import argparse
import sys
from pathlib import Path

from assemble import assemble, format_hex
from isa import fail, read_instructions


def main():
    parser = argparse.ArgumentParser(description="Assemble a Vernacular 8 program.")
    parser.add_argument("source")
    parser.add_argument("-o", dest="output", required=True, metavar="output.hex")
    args = parser.parse_args()

    if Path(args.output).resolve() == Path(args.source).resolve():
        fail(f"output would overwrite the source, {args.source}")

    try:
        with open(args.source, encoding="utf-8-sig") as f:  # -sig: drops a BOM if there is one
            source = f.read()
    except (OSError, UnicodeError) as e:
        fail(f"can't read {args.source}: {e}")

    words, errors = assemble(source, read_instructions())
    if errors:
        for line, msg in errors:
            print(f"{args.source}:{line}: {msg}", file=sys.stderr)
        sys.exit(1)

    # Written only once everything above succeeded, so an error never leaves
    # or changes an output file.
    try:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(format_hex(words))
    except OSError as e:
        fail(f"can't write {args.output}: {e}")


if __name__ == "__main__":
    main()

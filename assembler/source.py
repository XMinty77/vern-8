"""Split source text into statements.

Syntax only: whether a statement makes sense is for assemble.py to decide, so
nothing here reports an error except a number that can't be read.
"""

import re
from collections import namedtuple

COMMENT = re.compile(r";|#|%|//")
NAME = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
NUMBER = re.compile(r"0[xX][0-9A-Fa-f]+|0[bB][01]+|[0-9]+")

# mnemonic is uppercase, or None on a label-only line. spelling is the same word
# as written, for error messages. Operands are raw text.
Statement = namedtuple("Statement", "line labels mnemonic operands spelling")


def upper_ascii(word):
    """Uppercase, but leave non-ASCII alone: .upper() would turn ı into I and ſ into S."""
    return word.upper() if word.isascii() else word


def parse_line(line, text):
    """Return the line's Statement, or None if it has nothing but a comment."""
    code = COMMENT.split(text, maxsplit=1)[0]
    *labels, code = code.split(":")  # The statement is whatever follows the last colon
    labels = [label.strip() for label in labels]

    parts = code.split(maxsplit=1)
    if not labels and not parts:
        return None
    spelling = parts[0] if parts else None
    mnemonic = upper_ascii(spelling) if parts else None
    operands = [op.strip() for op in parts[1].split(",")] if len(parts) > 1 else []
    return Statement(line, labels, mnemonic, operands, spelling)


def parse(source):
    statements = [parse_line(i, text) for i, text in enumerate(source.split("\n"), start=1)]
    return [s for s in statements if s is not None]


def parse_number(text):
    """Return a number literal's value; raise ValueError with a message if it isn't one."""
    if text.startswith("-") and NUMBER.fullmatch(text[1:]):
        raise ValueError(f"negative number {text}")
    if not NUMBER.fullmatch(text):
        raise ValueError(f"malformed number {text!r}")
    return int(text, {"0x": 16, "0b": 2}.get(text[:2].lower(), 10))

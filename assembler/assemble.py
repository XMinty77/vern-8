"""Turn source text into words, in three passes over its statements.

1. collect_names: find every label and constant, so forward references work.
2. lay_out: decide where everything goes. Sizes never depend on values.
3. encode: fill in the values.

Every pass carries on after an error, so a run reports all of them.
"""

from collections import namedtuple

from forms import KINDS, PARTS, REGISTERS, ADDRESS, build_forms, describe, fits, reserved_names
from source import NAME, parse, parse_number

MEMORY_WORDS = 256

Word = namedtuple("Word", "address byte text")


class Assembler:
    def __init__(self, instructions):
        self.instructions = instructions
        self.forms = build_forms(instructions)
        self.reserved = reserved_names(self.forms)
        self.constants = {}
        self.labels = {}
        self.errors = []

    def error(self, stmt, msg):
        self.errors.append((stmt.line, msg))

    def check_new_name(self, stmt, name):
        if not NAME.fullmatch(name):
            self.error(stmt, f"bad name {name!r}")
        elif name.upper() in self.reserved:
            self.error(stmt, f"{name} is a mnemonic, directive or register name")
        elif name in self.labels or name in self.constants:
            self.error(stmt, f"{name} is already defined")
        else:
            return True
        return False

    def collect_names(self, statements):
        for stmt in statements:
            if len(stmt.labels) > 1:
                self.error(stmt, "more than one label on a line")
            if stmt.labels and stmt.mnemonic == ".EQU":
                self.error(stmt, "a label can't share a line with .equ")
            for label in stmt.labels:
                if self.check_new_name(stmt, label):
                    self.labels[label] = 0  # Its address comes in lay_out
            if stmt.mnemonic == ".EQU":
                self.define_constant(stmt)

    def define_constant(self, stmt):
        if len(stmt.operands) != 2:
            self.error(stmt, ".equ takes a name and a number")
            return
        name, text = stmt.operands
        if not self.check_new_name(stmt, name):
            return
        self.constants[name] = 0  # Stays if the value is bad: later uses aren't errors too
        try:
            value = parse_number(text)
        except ValueError as e:
            self.error(stmt, f"bad .equ value: {e}")
            return
        if value > 255:
            self.error(stmt, f".equ value {text} is out of range, 0 to 255")
            return
        self.constants[name] = value

    def find_form(self, stmt):
        forms = self.forms.get(stmt.mnemonic)
        if forms is None:
            what = "directive" if stmt.mnemonic.startswith(".") else "mnemonic"
            self.error(stmt, f"unknown {what} {stmt.spelling}")
            return None
        for form in forms:
            if fits(form, stmt.operands):
                return form
        expected = " | ".join(describe(stmt.mnemonic, form) for form in forms)
        self.error(stmt, f"bad operands for {stmt.mnemonic}, expected: {expected}")
        return None

    def place_labels(self, pending, address):
        for stmt, label in pending:
            self.labels[label] = address
            if address == MEMORY_WORDS:  # Any further, and lay_out has reported the overrun
                self.error(stmt, f"label {label} would be at 0x{address:X}, past 0xFF")
        pending.clear()

    def lay_out(self, statements):
        """Return (statement, form, address) for everything that emits words."""
        placed = []
        pending = []  # Labels waiting for the next word, so across a .org too
        address = 0
        for stmt in statements:
            pending += [(stmt, label) for label in stmt.labels]
            if stmt.mnemonic is None or stmt.mnemonic == ".EQU":
                continue
            form = self.find_form(stmt)
            if form is None:
                continue  # Unknown size: counted as none, so no false errors later on
            if stmt.mnemonic == ".ORG":
                target = self.resolve(stmt, stmt.operands[0], ADDRESS)
                if target is not None and target < address:
                    self.error(stmt, f".org moves backward, from 0x{address:02X} to 0x{target:02X}")
                elif target is not None:
                    address = target
                continue
            self.place_labels(pending, address)
            placed.append((stmt, form, address))
            address += len(form.words)
            if address - len(form.words) <= MEMORY_WORDS < address:  # Only the first to go past
                self.error(stmt, f"program runs past 0xFF, to 0x{address - 1:X}")
        self.place_labels(pending, address)
        return placed

    def resolve(self, stmt, text, kind):
        """Return the value of a non-register operand, or None after reporting an error."""
        limit, labels_allowed = KINDS[kind]
        if text in self.constants:
            value = self.constants[text]
        elif text in self.labels:
            if not labels_allowed:
                self.error(stmt, f"label {text} isn't allowed here, this operand is {kind}")
                return None
            value = self.labels[text]
        elif NAME.fullmatch(text):
            self.error(stmt, f"undefined name {text}")
            return None
        else:
            try:
                value = parse_number(text)
            except ValueError as e:
                self.error(stmt, str(e))
                return None
        if value > limit:
            self.error(stmt, f"{text} is out of range for {kind}, 0 to {limit}")
            return None
        return value

    def encode(self, placed):
        words = []
        for stmt, form, address in placed:
            values = [
                self.resolve(stmt, text, kind)
                for text, kind in zip(stmt.operands, form.operands)
                if kind not in REGISTERS
            ]
            if None in values:
                continue
            if stmt.mnemonic == "HALT":
                values = [address + 2]  # The address of its own JMP
            for i, word in enumerate(form.words):
                words.append(self.encode_word(address + i, word, values))
        return words

    def encode_word(self, address, word, values):
        name, _, part = word.partition(" ")
        opcode = 0 if name == ".byte" else self.instructions[name][0]
        if not part:
            return Word(address, opcode, name)
        imm = PARTS[part](values)
        return Word(address, opcode | imm, f"{name} 0x{imm:X}")


def assemble(source, instructions):
    """Return (words, errors). errors is a list of (line, message), in line order."""
    asm = Assembler(instructions)
    statements = parse(source)
    asm.collect_names(statements)
    placed = asm.lay_out(statements)
    words = asm.encode(placed)
    return words, sorted(asm.errors, key=lambda error: error[0])


def format_hex(words):
    """Return the words as text for $readmemh, with @ markers only at gaps."""
    lines = []
    next_address = 0
    for word in words:
        if word.address != next_address:
            lines.append(f"@{word.address:02X}")
        lines.append(f"{word.byte:02X} // {word.address:02X}: {word.text}")
        next_address = word.address + 1
    return "".join(line + "\n" for line in lines)

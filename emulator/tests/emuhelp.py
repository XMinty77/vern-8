"""Shared helpers for the emulator tests: assembling, running, reading traces."""

import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EMU = ROOT / "build" / "emulator" / "emu"
STEPPER = ROOT / "build" / "emulator" / "stepper"
ASM = ROOT / "assembler" / "asm.py"
ISA_CSV = ROOT / "docs" / "instructions.csv"

STATE_FIELDS = ["pc", "a", "b", "ar", "f", "d", "s0", "s1", "s2", "s3"]


def assemble(tmp_path, source, name="prog"):
    """Assembles `source` with the project's assembler; returns the hex path."""
    src = tmp_path / f"{name}.asm"
    out = tmp_path / f"{name}.hex"
    src.write_text(source)
    r = subprocess.run([sys.executable, str(ASM), str(src), "-o", str(out)],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    return out


@dataclass
class Record:
    kind: str                # "R" or "S"
    epc: str                 # PC the instruction was fetched from ("xx" for R)
    op: str                  # instruction word ("xx" for R)
    state: dict              # STATE_FIELDS -> string, as written
    write: tuple = None      # writes mode: (addr, value) strings, or None
    mem: list = None         # full mode: 256 strings


@dataclass
class Trace:
    records: list
    end: str                 # "HALT", "LIMIT" or "ERROR"
    error: tuple = None      # (pc, op, message) for ERROR
    lines: list = field(default_factory=list)

    @property
    def last(self):
        return self.records[-1].state

    @property
    def steps(self):
        return [r for r in self.records if r.kind == "S"]


def parse_trace(text, mode="writes"):
    """Parses a trace strictly, checking every field's shape."""
    lines = text.splitlines()
    records, end, error = [], None, None
    for i, line in enumerate(lines):
        assert end is None, f"line after END: {line!r}"
        tok = line.split(" ")
        assert "" not in tok, f"irregular spacing: {line!r}"
        if tok[0] == "END":
            end = tok[1]
            assert end in ("HALT", "LIMIT", "ERROR"), line
            if end == "ERROR":
                assert len(tok) >= 5, line
                error = (tok[2], tok[3], " ".join(tok[4:]))
            else:
                assert len(tok) == 2, line
            continue
        assert tok[0] in ("R", "S"), line
        assert (tok[0] == "R") == (i == 0), "R must be exactly the first record"
        widths = [2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2]
        for t, w in zip(tok[1:13], widths):
            assert len(t) == w and all(c in "0123456789abcdefx" for c in t), line
        state = dict(zip(STATE_FIELDS, tok[3:13]))
        rec = Record(tok[0], tok[1], tok[2], state)
        rest = tok[13:]
        if mode == "writes":
            assert len(rest) == 3, line
            if rest[0] == "1":
                rec.write = (rest[1], rest[2])
            else:
                assert rest == ["0", "xx", "xx"], line
        else:
            nruns = int(rest[0], 16)
            assert len(rest[0]) == 3 and len(rest) == 1 + 2 * nruns, line
            mem = []
            for j in range(nruns):
                count, value = rest[1 + 2 * j], rest[2 + 2 * j]
                assert len(count) == 3 and len(value) == 2, line
                assert int(count, 16) > 0, line
                if mem:
                    assert value != mem[-1], f"runs not merged: {line!r}"
                mem += [value] * int(count, 16)
            assert len(mem) == 256, line
            rec.mem = mem
        records.append(rec)
    assert end is not None, "trace has no END line"
    return Trace(records, end, error, lines)


EXIT = {"HALT": 0, "ERROR": 1, "LIMIT": 2}


def run_emu(hex_path, *args, mode="writes", check=True):
    """Runs the emulator; returns (Trace, CompletedProcess). With check, the
    exit code must match the trace's END status."""
    cmd = [str(EMU), str(hex_path), *args]
    if mode != "writes":
        cmd += ["-m", mode]
    r = subprocess.run(cmd, capture_output=True, text=True)
    assert r.returncode in (0, 1, 2), r.stderr
    trace = parse_trace(r.stdout, mode)
    if check:
        assert r.returncode == EXIT[trace.end]
    return trace, r


def run_asm(tmp_path, source, *args, mode="writes"):
    return run_emu(assemble(tmp_path, source), *args, mode=mode)[0]


def run_raw(*args, stdin=None):
    """Runs the emulator with arbitrary arguments, nothing checked."""
    return subprocess.run([str(EMU), *map(str, args)], capture_output=True,
                          text=True, input=stdin)

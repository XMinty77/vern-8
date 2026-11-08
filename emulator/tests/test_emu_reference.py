"""Every opcode, one instruction at a time, against the reference model.

The stepper harness runs the C core (decoding from docs/instructions.csv) on
each case; refmodel.py computes the expected result independently."""

import random
import subprocess

import pytest

import refmodel
from emuhelp import STEPPER


def case_line(code, st):
    seed = "xx" if st["seed"] is None else f"{st['seed']:02x}"
    s = " ".join(f"{x:02x}" for x in st["s"])
    return (f"{code:02x} {st['pc']:02x} {st['a']} {st['b']} {st['ar']} "
            f"{st['f']} {st['d']:x} {s} {seed}")


def check(cases):
    """Runs (code, state) cases through the stepper; returns the mismatches."""
    stdin = "".join(case_line(c, st) + "\n" for c, st in cases)
    r = subprocess.run([str(STEPPER)], input=stdin, capture_output=True,
                       text=True)
    assert r.returncode == 0, r.stderr
    got = r.stdout.splitlines()
    assert len(got) == len(cases)
    bad = []
    for (code, st), line in zip(cases, got):
        want = refmodel.run(code, st)
        result = "ERR" if line.startswith("ERR ") else line
        if result != want:
            bad.append(f"{case_line(code, st)}\n  got  {line}\n  want {want}")
    return bad


def random_state(rng, unknowns):
    def reg():
        if unknowns and rng.random() < 0.3:
            return rng.choice(["xx", f"x{rng.randrange(16):x}",
                               f"{rng.randrange(16):x}x"])
        return f"{rng.randrange(256):02x}"

    return {
        "pc": rng.choice([0x00, 0xFE, 0xFF, rng.randrange(256)]),
        "a": reg(), "b": reg(), "ar": reg(),
        "f": rng.choice("01x" if unknowns else "01"),
        "d": rng.randrange(5),
        "s": [rng.randrange(256) for _ in range(4)],
        "seed": None if unknowns and rng.random() < 0.3 else rng.randrange(256),
    }


@pytest.mark.parametrize("unknowns", [False, True], ids=["known", "unknowns"])
def test_every_opcode_random_states(unknowns):
    rng = random.Random(1234 + unknowns)
    cases = [(code, random_state(rng, unknowns))
             for code in range(256) for _ in range(400)]
    bad = check(cases)
    assert not bad, f"{len(bad)} mismatches, first:\n" + "\n".join(bad[:5])


@pytest.mark.parametrize("group", [0x80, 0x88, 0x90], ids=hex)
def test_alu_and_flag_ops_exhaustive(group):
    """All 65536 (A, B) pairs for each ALU and flag op, F both ways."""
    rng = random.Random(group)
    cases = []
    for code in range(group, group + 8):
        for a in range(256):
            for b in range(256):
                cases.append((code, {
                    "pc": rng.randrange(256), "a": f"{a:02x}", "b": f"{b:02x}",
                    "ar": f"{rng.randrange(256):02x}", "f": "01"[(a ^ b) & 1],
                    "d": 0, "s": [0, 0, 0, 0], "seed": 0}))
    bad = check(cases)
    assert not bad, f"{len(bad)} mismatches, first:\n" + "\n".join(bad[:5])


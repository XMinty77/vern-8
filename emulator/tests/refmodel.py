"""Reference model of one instruction, written separately from the C core.

Decoding follows the encoding map in docs/isa.md (hard-coded here on purpose,
so the tests also check the C decoder that reads docs/instructions.csv).
Values use the trace notation: two hex digits, an unknown nibble as 'x'.
"""

ALU = ["INVA", "INVB", "ADD", "SUB", "MUL", "DIV", "SWAP", "INC",
       "AND", "NAND", "OR", "NOR", "XOR", "XNOR", "SHL", "SHR"]
FLAG_OPS = ["EQ", "NEQ", "LT", "GTE", "GT", "LTE", "CLF", "STF"]
NIBBLE_OPS = {0x0: "ILA", 0x1: "IHA", 0x2: "ILB", 0x3: "IHB", 0x4: "ALO",
              0x5: "AHI", 0x6: "SLDA", 0x7: "SLDB", 0xE: "SSTA", 0xF: "SSTB"}
FIXED = {0x98: "JMP", 0x99: "JF", 0x9A: "CALL", 0x9B: "RET", 0xD8: "TAR",
         0xDC: "LDA", 0xDD: "LDB", 0xDE: "STA", 0xDF: "STB"}


def decode(code):
    """(mnemonic, operand) for an 8-bit code; undefined codes give NOP."""
    hi, lo = code >> 4, code & 0xF
    if hi in NIBBLE_OPS:
        return NIBBLE_OPS[hi], lo
    if hi == 0x8:
        return ALU[lo], None
    if hi == 0x9 and lo < 8:
        return FLAG_OPS[lo], None
    return FIXED.get(code, "NOP"), None


class Unknown(Exception):
    """The instruction reads a value that isn't fully known."""


def mem_value(seed, addr):
    """Data memory pattern the stepper harness sets up."""
    return None if seed is None else (addr * 0x9D + seed) & 0xFF


def h(n):
    return f"{n:02x}"


def need(s):
    """Integer value of a register string, or Unknown if it has an x."""
    if "x" in s:
        raise Unknown(s)
    return int(s, 16)


def step(code, st):
    """Executes `code` from state `st` (a dict with pc, d, s[4] as ints; a, b,
    ar as 2-char strings; f as '0', '1' or 'x'; seed for data memory).
    Returns (new_state, write) with write = (addr, value) or None."""
    name, v = decode(code)
    n = dict(st)
    n["s"] = list(st["s"])
    n["pc"] = (st["pc"] + 1) % 256
    write = None

    def load(addr):
        m = mem_value(st["seed"], addr)
        if m is None:
            raise Unknown(f"M[{addr}]")
        return h(m)

    if name in ("ILA", "ILB", "ALO"):
        reg = {"ILA": "a", "ILB": "b", "ALO": "ar"}[name]
        n[reg] = st[reg][0] + f"{v:x}"
    elif name in ("IHA", "IHB", "AHI"):
        reg = {"IHA": "a", "IHB": "b", "AHI": "ar"}[name]
        n[reg] = f"{v:x}" + st[reg][1]
    elif name in ("SLDA", "SLDB"):
        n["a" if name == "SLDA" else "b"] = load(v)
    elif name in ("SSTA", "SSTB"):
        write = (v, need(st["a" if name == "SSTA" else "b"]))
    elif name in ("LDA", "LDB"):
        n["a" if name == "LDA" else "b"] = load(need(st["ar"]))
    elif name in ("STA", "STB"):
        addr = need(st["ar"])
        write = (addr, need(st["a" if name == "STA" else "b"]))
    elif name == "INVA":
        n["a"] = h(255 - need(st["a"]))
    elif name == "INVB":
        n["b"] = h(255 - need(st["b"]))
    elif name == "INC":
        a = need(st["a"])
        n["a"] = h((a + 1) % 256)
        n["f"] = "1" if a == 255 else "0"
    elif name in ALU or name in FLAG_OPS[:6]:
        a, b = need(st["a"]), need(st["b"])
        if name == "ADD":
            n["a"], n["f"] = h((a + b) % 256), str(int(a + b >= 256))
        elif name == "SUB":
            n["a"], n["f"] = h((a - b) % 256), str(int(b > a))
        elif name == "MUL":
            n["a"], n["f"] = h(a * b % 256), str(int(a * b >= 256))
        elif name == "DIV":
            if b == 0:
                n["f"] = "1"
            else:
                n["a"], n["b"], n["f"] = h(a // b), h(a % b), "0"
        elif name == "SWAP":
            n["a"], n["b"] = st["b"], st["a"]
        elif name in ("AND", "NAND", "OR", "NOR", "XOR", "XNOR"):
            bits = []
            for i in range(8):
                x, y = (a >> i) & 1, (b >> i) & 1
                bits.append({"AND": x and y, "NAND": not (x and y),
                             "OR": x or y, "NOR": not (x or y),
                             "XOR": x != y, "XNOR": x == y}[name])
            n["a"] = h(sum(int(bit) << i for i, bit in enumerate(bits)))
        elif name == "SHL":
            n["a"] = h((a * 2 ** b) % 256 if b < 8 else 0)
        elif name == "SHR":
            n["a"] = h(a // 2 ** b if b < 8 else 0)
        else:
            n["f"] = str(int({"EQ": a == b, "NEQ": a != b, "LT": a < b,
                              "GTE": a >= b, "GT": a > b, "LTE": a <= b}[name]))
    elif name == "CLF":
        n["f"] = "0"
    elif name == "STF":
        n["f"] = "1"
    elif name == "JMP":
        n["pc"] = need(st["ar"])
    elif name == "JF":
        if st["f"] == "x":
            raise Unknown("F")
        if st["f"] == "1":
            n["pc"] = need(st["ar"])
    elif name == "CALL":
        n["pc"] = need(st["ar"])
        n["s"] = [(st["pc"] + 1) % 256] + st["s"][:3]
        n["d"] = min(st["d"] + 1, 4)
    elif name == "RET":
        if st["d"] > 0:
            n["pc"] = st["s"][0]
            n["s"] = st["s"][1:] + [0]
            n["d"] = st["d"] - 1
    elif name == "TAR":
        n["ar"] = h(need(st["a"]))
    else:
        assert name == "NOP"
    return n, write


def run(code, st):
    """step() rendered the way the stepper harness prints it."""
    try:
        n, write = step(code, st)
    except Unknown:
        return "ERR"
    w = f"1 {write[0]:02x} {write[1]:02x}" if write else "0 xx xx"
    s = " ".join(f"{x:02x}" for x in n["s"])
    return (f"{n['pc']:02x} {n['a']} {n['b']} {n['ar']} {n['f']} {n['d']:x} "
            f"{s} {w}")

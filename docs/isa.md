# Instruction set

The full instruction table is provided in [`instructions.csv`](instructions.csv).

## Encoding map

| Pattern (b7–b0) | Instructions |
|---|---|
| `0000 nnnn` / `0001 nnnn` | ILA / IHA: write A's low / high nibble, keep the other |
| `0010 nnnn` / `0011 nnnn` | ILB / IHB: same for B |
| `0100 nnnn` / `0101 nnnn` | ALO / AHI: same for AR |
| `0110 nnnn` / `0111 nnnn` | SLDA / SLDB: r ← M[n], n = 0 to 15 |
| `1110 nnnn` / `1111 nnnn` | SSTA / SSTB: M[n] ← r |
| `1000 oooo` | ALU, 16 ops: INVA, INVB, ADD, SUB, MUL, DIV, SWAP, INC, AND, NAND, OR, NOR, XOR, XNOR, SHL, SHR |
| `1001 0ccc` | Flag ops: EQ, NEQ, LT, GTE, GT, LTE, CLF, STF. b0 inverts the condition; CLF / STF are the "always false" / "always true" pair. |
| `1001 100c` | JMP / JF: PC ← AR, JF only if F = 1 |
| `1001 1010` | CALL: push PC + 1, PC ← AR |
| `1001 1011` | RET: pop into PC; on an empty stack, only PC + 1 |
| `1101 1000` | TAR: AR ← A |
| `1101 11sr` | LDA, LDB, STA, STB through AR. s: 0 = load, 1 = store. r: 0 = A, 1 = B. |

## Flags

F is written only by ADD (carry out), SUB (borrow), INC (carry out), MUL (non-zero discarded bits), DIV (divide by zero) and the flag-op group. Everything else leaves F unchanged.

## Code space

193 of 256 codes are used. Free: `1010 xxxx`, `1011 xxxx`, `1100 xxxx`, `1001 1100`–`1001 1111`, `1101 0000`–`1101 0111`, `1101 1001`–`1101 1011` (63 codes). Undefined opcodes behave as NOP: PC = PC + 1 and nothing else changes.

## Machine rules

### Registers

- **A** and **B**: 8-bit working registers.
- **AR**: 8-bit address register.
- **PC**: 8-bit program counter.
- **F**: 1-bit flag.
- **S0** to **S3**: 4-entry call stack of 8-bit return addresses, S0 on top.
- **D**: call depth, 0 to 4.

S0 to S3 and D are not directly readable or writable by instructions.

ILA, IHA, ILB, IHB, ALO and AHI change only their nibble, the other nibble keeps its value.

### Memories

- **Instruction memory:** 256 × 8, addressed by PC. Combinational read. Loaded from a hex file before simulation starts.
- **Data memory:** 256 × 8, addressed by AR, or by V for SLD/SST (addresses 0 to 15). Combinational read; writes happen on the rising clock edge.

### Arithmetic

Unsigned 8-bit. Results that do not fit in 8 bits wrap around.

### Clocking

All state updates happen together on the rising clock edge.

### PC update

PC = PC + 1 after every instruction unless its RTL sets PC. PC wraps from 0xFF to 0x00. JF with F = 0 gives PC = PC + 1.

### Reset

After reset, PC = 0, S0 to S3 = 0 and D = 0. A, B, AR, F and data memory are undefined.

The reset signal `rst` is synchronous and active-high.

### Call stack

- **CALL** pushes PC + 1 into S0 and shifts S0 to S2 down into S1 to S3. When D = 4, the old S3 is lost and D stays 4, otherwise D increases by 1.
- **RET** with D > 0 loads PC from S0, shifts S1 to S3 up into S0 to S2, and shifts 0 into S3. RET with D = 0 is NOP.

### Conventions

- **Subroutines:** the call stack holds return addresses only. A subroutine that changes A, B, AR or F must save and restore them in data memory if the caller needs them. Nesting deeper than 4 calls loses the oldest return address.
- **Computed addresses:** TAR copies A into AR, so LD, ST, JMP, JF and CALL can all use an address computed in A.
- **Halt:** there is no HALT instruction. A program halts by a jump loop.

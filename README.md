# Vernacular 8

A tiny single-cycle 8-bit CPU I'm writing in SystemVerilog. Simulation only, learning project.

- Somewhere between an accumulator and a load/store architecture. It has load/store instructions and two working registers (A, B) which most instructions revolve around.
- Harvard memory: 256 bytes of instruction memory and 256 bytes of data memory. An 8-bit address register for addressing.
- 8-bit instructions with expanding opcodes, 43 instructions using 193 of 256 codes.
- 4-deep hardware call stack for `CALL`/`RET`.
- 1-bit flag for comparisons, conditional branching and general operation status.

**Status:** the RTL is written and runs programs. The ALU, RU, WU and CU have testbenches, and an assembler exists. The core's testbench and an emulator to check it against are next.

## Versioning

Current version: 1.0.0

- **Major:** ISA revision.
- **Minor:** Spec/architecture revision.
- **Patch:** Implementation revision.

## Layout

```
docs/        ISA, unit spec, design rationale
rtl/         synthesizable SystemVerilog
tb/          testbenches
assembler/   assembler
build/       build outputs (not committed)
```

## Documentation

- [Instruction set](docs/isa.md), with the full table in [`docs/instructions.csv`](docs/instructions.csv)
- [Unit spec](docs/spec.md)
- [Design rationale](docs/design-rationale.md)
- [Assembler](assembler/README.md)

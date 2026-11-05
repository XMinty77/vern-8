# Design rationale

Informal record of key architectural decisions.

## Expanding opcodes

To make efficient use of instruction space, instructions that carry an 4-bit immediate operand get a 4-bit opcode, whilst instructions without operands use longer opcodes carved from the remaining space. I was inspired by UTF-8 and found out this is a real technique. This fits 43 instructions, ten of them with immediates, into fixed 8-bit words.

## Compare encoding with an invert bit

In the compare group, b0 inverts the condition: EQ/NEQ, LT/GTE, GT/LTE. The fourth pair is "always false" / "always true", which gives CLF and STF without extra logic. This makes Verilog simpler.

## Not entirely load/store, not entirely accumulator

The ALU operates only on A and B. Just like load/store, two registers allow for more instructions freedom, and memory is reached only through loads and stores. Just like accumulator, instructions never have to specify registers as operands. This keeps every ALU instruction operand-free and the datapath simple, at the cost of more instructions per memory operation.

## Nibble immediates that keep the other nibble

Instructions with immediates write one nibble and keep the other as-is. The nice consequence is that a nibble can be changed alone with one instruction. The bad consequence is that a program must expend two instructions to be sure of a register's value.

## Hardware return-address stack

To have *some* subroutine capabilities, a 4-entry shift-register stack is introduced. CALL and RET need no stack pointer and no data-memory traffic, but nesting is limited to 4 levels and register values must be handled by convention.

## Computed addresses

TAR (AR ← A) is added to enable computing in AR. This enables every AR-addressed instruction (LD, ST, JMP, JF, CALL) to use computed addresses, giving arrays, jump tables and computed calls without separate indexed modes.

## Combinational MUL and DIV

Simple combinational MUL/DIV fits the architecture of this CPU.

## MUL behavior

Compute the full 16-bit product and look for OF in the high byte, for simplicity. A cheaper partial-product detector can be explored later.

## Centralized decode

Mostly justified by me wanting to practice writing a CU. Classic choice for a small CPU.

## Unit boundaries

**ALU:** Combinational module taking in current A/B/F and the opcode, and spits out new A/B/F.

**WU**: Sequential module that handles memory operations and holds the two working registers plus the address register.

**RU**: Sequential module that handles branching and execution registers (PC, F, S0 through S3, D).

**CU**: Responsible for decode and computing the inputs to other units.

**Core**: Responsible for muxing and routing between all the units. It holds an instance of all units as well as the two memories.

The CU picks the route and supplies whatever changes per instruction (e.g. immediates), while the core implements the routes and necessary muxing between the units.

## Reset

Synchronous, active-high.

## White-box testbenches

Hierarchical references are used in benches to make testing easier and more direct, at the cost of coupling to the implementation.

## Direct testing

Hierarchical `force` and `release` on internal signals were used to make testing easier as well. Real sequences will be provided by program tests later down the line. The tradeoff is it'll be a little harder to pinpoint the issue from the core down to the unit.

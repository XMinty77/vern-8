# CPU unit spec

Unless said otherwise, rst signals override all other behavior including combinations

Unless said otherwise, any combination of control inputs not listed is disallowed and drives `x`

## RU - Running Unit

Takes care of the running/addressing flows. Is stateful, clocked, has a reset.

Holds F, PC, call stack, call depth.

Inputs:

- jump
- jump_conditional
- call
- ret
- new_F
- write_F
- AR
- clk
- rst

Flow and semantics:

- rst => Set F to 0, PC to 0, S0 through S3 to 0, and call depth to 0
- jump => execute a jump
- jump + jump_conditional => execute a conditional jump. if F low => PC + 1
- call => execute a call, going to AR
- ret => execute a return, ret with D = 0 => PC + 1
- write_F => update F, and PC takes PC + 1
- nothing selected => PC takes PC + 1
- Any other combination: `x`  to all internal state

Outputs:

- PC
- F

## ALU - Arithmetic Logic Unit

Combinational brain. Not stateful.

Inputs:

- cur_A
- cur_B
- cur_F
- opcode (full 8 bits)

Flow and semantics:

- Handles INVA through STF
- Opcodes outside the set result in `x` outputs
- Passthrough for unchanged values

Outputs:

- new_A
- new_B
- new_F

## WU - Working Unit

Holds A, B and AR. Stateful, clocked.

This is the old ABU. It handles memory operations.

Inputs:

- new_A
- new_B
- write_AB
- new_AR
- write_AR
- do_TAR
- use_A (high => use A, low => use B, for the operation)
- mask (8 bits)
- mask_2 (8 bits)
- load
- store
- simple_addr (4 bits)
- simple_load
- simple_store
- mem_val_in
- clk
- rst

Flow and semantics:

- rst => set A, B and AR to 0
- write_AB => update A and B to new values, where the mask is high (mask for A, mask_2 for B)
- write_AR => update AR to new value, where the mask is high (mask)
- do_tar => execute TAR, copy A into AR
- load => load M[AR] into the register picked by use_A
- store => store the register picked by use_A into M[AR]
- simple_load => same with M[simple_addr]
- simple_store => same with M[simple_addr]
- nothing selected => do nothing
- Anything else => `x` in A, B and AR (combination of any two signals is disallowed), mem outputs get zero

Memory access:

- mem_addr is assigned on a combinational path, sets what the module wants to access (e.g. AR for full load/store)
- mem_val_in is assigned by the top level module, wired from the memory module
- mem_write is a definite low unless a store is involved, and always low during rst

Outputs:

- A
- B
- AR
- mem_addr
- mem_val_out
- mem_write (high => write, low => read)

## CU - Control Unit

Decoding brain. Stateless and combinational.

Inputs:

- instruction (wired combinationally as PM[PC])

Flow and semantics:

- Set ru_cs, alu_cs or wu_cs based on instruction
  - WU for ILA through STB and TAR
  - ALU for INVA through STF
  - RU for JMP through RET
  - Nothing for undefined opcode
- Drives the necessary unit inputs accordingly
- Commands an instruction doesn't need are held low
- Outputs to be muxed into the other unit inputs by core module

Outputs:

- ru_cs (route to RU)
- ru_jump
- ru_jump_conditional
- ru_call
- ru_ret

- alu_cs (route to ALU)
- alu_opcode

- wu_cs
- wu_new_A
- wu_new_B
- wu_write_AB
- wu_new_AR
- wu_write_AR
- wu_do_tar
- wu_use_A (high => use A, low => use B, for the operation)
- wu_mask (8 bits)
- wu_mask_2 (8 bits)
- wu_load
- wu_store
- wu_simple_addr (4 bits)
- wu_simple_load
- wu_simple_store

## Core Module

Responsible for instantiating all units and top level muxing/routing.

Instances:

- RU
- WU
- ALU
- CU
- PM
- M

Flow and semantics (impl turns into muxes):

- clk and rst to clocked modules
- WU.AR to RU.AR
- RU.PC to PM.addr
- PM.out to CU.instruction
- 0 to PM.in, PM.write
- PM gets a HEX_FILE, M doesn't
- For each one below, pass through the appropriately named CU.* ports, for the instance inputs not listed, set to zero

- ru_cs:
  - 0 to RU.new_F, RU.write_F
  - 0 to M.write, M.addr, M.in
- wu_cs:
  - M.out to WU.mem_val_in
  - WU.mem_val_out to M.in
  - WU.mem_addr to M.addr
  - WU.mem_write to M.write
  - 0 to RU.new_F, RU.write_F
- alu_cs:
  - 0 to M.write, M.addr, M.in
  - 1 to RU.write_F, WU.write_AB
  - '1 to WU.mask, WU.mask_2
  - ALU.new_A to WU.new_A
  - ALU.new_B to WU.new_B
  - ALU.new_F to RU.new_F
  - WU.A to ALU.cur_A
  - WU.B to ALU.cur_B
  - RU.F to ALU.cur_F
- None of them:
  - 0 to RU.new_F, RU.write_F
  - 0 to M.write, M.addr, M.in

## Memory

Used for PM and M.

Parameters:
- HEX_FILE (loaded into the memory before simulation starts, empty => nothing is loaded and words stay `x`)

Inputs:
- addr
- in
- write
- clk

Flow and semantics:
- Combinationally, out is memory[addr]
- Sequentially, write => memory[addr] is assigned in

Outputs:
- out

# Assembler

A small assembler, written as part of the project. Turns source into the hex file loaded into instruction memory.

## Usage

```
python3 assembler/asm.py prog.asm -o build/prog.hex
```

Opcodes come from `docs/instructions.csv`. On error, it exits and does not modify the output file.

## Source format

Each line holds an optional label, a statement and an optional comment:

```
loop:   IMF A, 0x2A     ; load the whole register
        JNEQ loop       # back until A equals B
        HALT            // stop here
```

- **Comments:** `;`, `#`, `%` and `//` are all supported.
- **Numbers:** decimal `42`, hex `0x2A` or binary `0b101010`. Negative numbers are errors.
- **Case:** labels and constants are case-sensitive, everything else is case-insensitive.
- **Names:** alphanumerical with underscores and a letter at the start. Mnemonics, directives and registers are reserved.

## Physical instructions

These are the ones from the ISA table, they work as spelled and expected. The instructions with an immediate take an operand as a number or constant.

## Register forms

Physical instructions in the form standard to this assembly language.

| Form | A | B | AR |
| --- | --- | --- | --- |
| `IML r, n` | `ILA` | `ILB` | `ALO` |
| `IMH r, n` | `IHA` | `IHB` | `AHI` |
| `INV r` | `INVA` | `INVB` | error |
| `SLD r, n` | `SLDA` | `SLDB` | error |
| `SST r, n` | `SSTA` | `SSTB` | error |
| `LD r` | `LDA` | `LDB` | error |
| `ST r` | `STA` | `STB` | error |

`IML` and `IMH` change one nibble and keep the other, `IMF` sets the whole thing (below).

## Emulated instructions

Each form always expands to the same words, even when a word looks redundant. In the tables, `x` is a number from 0 to 255, a constant or a label unless noted, and `lo`/`hi` are its nibbles.

### Full immediate

| Form | Becomes | Words |
| --- | --- | --- |
| `IMF A, x` | `ILA lo`, `IHA hi` | 2 |
| `IMF B, x` | `ILB lo`, `IHB hi` | 2 |
| `IMF AR, x` | `ALO lo`, `AHI hi` | 2 |

`IMF` takes labels, so `IMF A, table` then `TAR` covers computed addresses.

### Jumps

The same forms work for `JMP`, `JF` and `CALL`, shown here as `JMP`. Bare `JMP`, `JF` and `CALL` stay physical and use whatever AR already holds.

| Form | Becomes | Words |
| --- | --- | --- |
| `JMP x` | `ALO lo`, `AHI hi`, `JMP` | 3 |
| `JMP AR` | `JMP` | 1 |
| `JMP A` | `TAR`, `JMP` | 2 |
| `JMP B` | `SWAP`, `TAR`, `SWAP`, `JMP` | 4 |

### Memory

`r` is A or B, and the register always comes first. `ST` works the same way as `LD`.

| Form | Becomes | Words |
| --- | --- | --- |
| `LD r, x` | `ALO lo`, `AHI hi`, `LDr` | 3 |
| `LD r, AR` | `LDr` | 1 |
| `LD r, A` | `TAR`, `LDr` | 2 |
| `LD r, B` | `SWAP`, `TAR`, `SWAP`, `LDr` | 4 |

Here `x` is a number or a constant, never a label. Memory is Harvard and labels mark instruction memory, so `LD A, loop` would read data memory at an unrelated address. Address forms never become `SLD` or `SST`; write those when you want the short form.

### Compare and jump

The same forms work for `JEQ`, `JNEQ`, `JLT`, `JGTE`, `JGT` and `JLTE`, shown here as `JEQ`. Each starts with the flag instruction of the same name, and F keeps the result afterwards.

| Form | Becomes | Words |
| --- | --- | --- |
| `JEQ x` | `EQ`, `ALO lo`, `AHI hi`, `JF` | 4 |
| `JEQ AR` | `EQ`, `JF` | 2 |
| `JEQ A` | `EQ`, `TAR`, `JF` | 3 |
| `JEQ B` | `EQ`, `SWAP`, `TAR`, `SWAP`, `JF` | 5 |

### Jump if F, else

`JFE x, y` goes to `x` if F is set and to `y` if it isn't, and never falls through. It takes addresses only, not registers.

| Form | Becomes | Words |
| --- | --- | --- |
| `JFE x, y` | `ALO`, `AHI`, `JF` to `x`, then `ALO`, `AHI`, `JMP` to `y` | 6 |

## What gets overwritten

Emulated instructions overwrite only AR, plus F for compare and jump, plus the register `IMF` names. A, B and data memory are otherwise safe, because a single line should never destroy a value you're keeping.

| Instruction | AR | F | A, B |
| --- | --- | --- | --- |
| `IMF r, x` | Only if `r` is AR | Kept | Only if `r` is A or B |
| `JMP`, `JF`, `CALL` with `x`, `A` or `B` | Overwritten | Kept | Kept |
| `LD`, `ST` with `x`, `A` or `B` | Overwritten | Kept | `LD` writes `r` |
| `JEQ` and family | Overwritten, except with `AR` | Overwritten | Kept |
| `JFE`, `HALT` | Overwritten | Kept | Kept |

AR is overwritten even when `JF x` doesn't take the jump. A pointer you loop with has to live in A or data memory.

This rule is why there's no `MOV`, `DEC`, `ADDI`, `PUSH` or `POP`. The ISA can't do those without borrowing B or a data memory word, so programs write them out by hand.

## Halt and filler

| Form | Becomes | Words | Notes |
| --- | --- | --- | --- |
| `HALT` | `ALO`, `AHI`, `JMP` to that same `JMP` | 3 | The PC stops changing, which gives a simple stop condition |
| `NOP` | Byte `0xA0` | 1 | The ISA has no NOP, but undefined opcodes act as one. The assembler refuses to run if the ISA ever takes this code |
| `.byte n` | The raw byte | 1 | 0 to 255, no labels. For undefined opcodes in test programs; nothing can read instruction memory as data |

## Directives

### `.equ name, value`

Names a constant, mainly for data addresses:

```
.equ counter, 3
        SLD A, counter
        LD B, counter
```

The value is a literal number from 0 to 255. A constant can go anywhere a number can and is range-checked where it's used, so `IML A, big` is an error if `big` is above 15. It can be defined anywhere in the file. Unlike labels, constants are allowed as `imm4` operands because they only change when you edit them.

### `.org address`

Moves the next word to that address, for example `.org 0xFE` to test the PC wrapping from `0xFF` to `0x00`. The address is a number or a constant, and moving backward is an error, so code can't overwrite other code. Skipped words stay x, so a program that runs into a gap fails loudly.

## Output

A text file for `$readmemh`: one word per line, with its address and physical instruction in a comment.

```
0A // 00: ILA 0xA
1F // 01: IHA 0xF
98 // 02: JMP
@FE
A0 // FE: NOP
C7 // FF: .byte 0xC7
```

The comments always show physical instructions, so the file matches what you see in waveforms. `@FE` appears only where `.org` leaves a gap.

Unused memory isn't padded, so a runaway program goes loudly x. The cost is that Icarus prints "Not enough words" each time it loads a program shorter than 256 words.

## Errors

Every error in a run is reported as `file:line: message`.

| Case | Example |
| --- | --- |
| Unknown mnemonic or directive | `FOO`, `.bar` |
| Wrong number of operands | `ADD 3`, `LDA 5`, `IML A` |
| Wrong kind of operand | `INV AR`, `JFE A, B` |
| Value out of range | `ILA 0x2A`, `IMF A, 256` |
| Malformed or negative number | `ILA 0xZZ`, `IMF A, -1` |
| Label where a label isn't allowed | `ALO loop`, `LD A, loop`, `.byte loop` |
| Undefined or duplicate name | `JMP nowhere`, two `loop:` lines |
| Reserved name | `add:`, `ar:` |
| More than one label on a line, or a label on `.equ` or `.org` | `a: b: ADD`, `here: .org 0x10` |
| Backward `.org` | `.org 0x10` after address `0x20` |
| Program past `0xFF` | The 257th word, or a label left at `0x100` |
| Bad `.equ` value | `.equ big, 300`, `.equ a2, other` |

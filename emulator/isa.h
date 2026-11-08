/* Instruction decoding, built at startup from docs/instructions.csv. */
#ifndef ISA_H
#define ISA_H

#include <stddef.h>
#include <stdint.h>

/* Every instruction the emulator knows how to execute. OP_NOP stands for
 * every code no CSV row matches (undefined opcodes behave as NOP). */
typedef enum {
  OP_NOP = 0,
  OP_ILA, OP_IHA, OP_ILB, OP_IHB, OP_ALO, OP_AHI,
  OP_SLDA, OP_SLDB, OP_SSTA, OP_SSTB,
  OP_LDA, OP_LDB, OP_STA, OP_STB,
  OP_INVA, OP_INVB, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SWAP, OP_INC,
  OP_AND, OP_NAND, OP_OR, OP_NOR, OP_XOR, OP_XNOR, OP_SHL, OP_SHR,
  OP_EQ, OP_NEQ, OP_LT, OP_GTE, OP_GT, OP_LTE, OP_CLF, OP_STF,
  OP_JMP, OP_JF, OP_CALL, OP_RET, OP_TAR,
  OP_COUNT
} op_t;

typedef struct {
  op_t op[256];      /* instruction for each code */
  uint8_t wild[256]; /* bits of the code that are the operand (imm4) */
} isa_t;

/* Mnemonic of an op ("NOP" for OP_NOP). */
const char *isa_name(op_t op);

/* Operand of `code`: its wildcard bits, packed down to bit 0 (order kept). */
uint8_t isa_operand(const isa_t *isa, uint8_t code);

/* Builds the decode table from the CSV at `path`. Returns 0 on success; on
 * failure returns -1 and writes a message into err. Strict: every known
 * instruction must appear exactly once, no unknown names, no two rows may
 * match the same code, and the operand width must match the instruction. */
int isa_load(isa_t *isa, const char *path, char *err, size_t errlen);

#endif

/* Architectural state and the execution of one instruction. */
#ifndef CPU_H
#define CPU_H

#include <stddef.h>
#include <stdint.h>

#include "isa.h"

/* A value with known bits: bit i of `v` means something only if bit i of
 * `k` is 1. Unknown bits of `v` are kept at 0. */
typedef struct {
  uint8_t v, k;
} val8;

#define KNOWN(x) ((x).k == 0xFF)

typedef struct {
  uint8_t pc;
  val8 a, b, ar;
  val8 f;       /* 1-bit flag: only bit 0 is used, k is 0 or 1 */
  uint8_t d;    /* call depth, 0 to 4 */
  uint8_t s[4]; /* call stack, s[0] on top */
  val8 dmem[256];
  val8 imem[256];
} cpu_t;

typedef struct {
  uint8_t code; /* the instruction word executed (when it was known) */
  op_t op;
  int wrote; /* 1 if the instruction wrote data memory */
  uint8_t waddr, wdata;
  char err[96]; /* set when cpu_step returns -1 */
} step_t;

/* Reset: PC, S0-S3 and D to 0; A, B, AR, F and all of data memory unknown.
 * Instruction memory is left as loaded. */
void cpu_reset(cpu_t *c);

/* Executes the instruction at PC. Returns 0 on success, or -1 if it reads a
 * value that isn't fully known (or the instruction word itself is unknown);
 * in that case the state is left unchanged and st->err says why. */
int cpu_step(cpu_t *c, const isa_t *isa, step_t *st);

#endif

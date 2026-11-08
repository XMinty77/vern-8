/* The trace file the SystemVerilog bench reads. Its syntax is documented in
 * notes/emulator-spec.md, "Trace format as built". */
#ifndef TRACE_H
#define TRACE_H

#include <stdio.h>

#include "cpu.h"

typedef enum { MEM_WRITES, MEM_FULL } mem_mode_t;

/* The record for the state after reset. */
void trace_reset(FILE *out, const cpu_t *c, mem_mode_t mode);

/* The record for one executed instruction: `pc` is the address it was
 * fetched from, `st` what it did, `c` the state after it. */
void trace_step(FILE *out, uint8_t pc, const step_t *st, const cpu_t *c,
                mem_mode_t mode);

void trace_end_halt(FILE *out);
void trace_end_limit(FILE *out);
/* `code` is the instruction word at `pc`, with its unknown digits as x. */
void trace_end_error(FILE *out, uint8_t pc, val8 code, const char *msg);

/* Writes v as two hex digits, an unknown nibble as x. buf holds 3 chars. */
void hex2(char *buf, val8 v);

#endif

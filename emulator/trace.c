#include "trace.h"

#include <string.h>

static const char HEX[] = "0123456789abcdef";

void hex2(char *buf, val8 v) {
  buf[0] = (v.k & 0xF0) == 0xF0 ? HEX[v.v >> 4] : 'x';
  buf[1] = (v.k & 0x0F) == 0x0F ? HEX[v.v & 0x0F] : 'x';
  buf[2] = '\0';
}

static char flag_char(val8 f) { return f.k & 1 ? (char)('0' + (f.v & 1)) : 'x'; }

/* PC A B AR F D S0 S1 S2 S3 */
static void state(FILE *out, const cpu_t *c) {
  char a[3], b[3], ar[3];
  hex2(a, c->a);
  hex2(b, c->b);
  hex2(ar, c->ar);
  fprintf(out, " %02x %s %s %s %c %x %02x %02x %02x %02x", c->pc, a, b, ar,
          flag_char(c->f), c->d, c->s[0], c->s[1], c->s[2], c->s[3]);
}

/* All 256 bytes as runs: the run count, then (length, value) per run. */
static void full_memory(FILE *out, const cpu_t *c) {
  char vals[256][3];
  for (int i = 0; i < 256; i++) hex2(vals[i], c->dmem[i]);
  int runs = 0;
  for (int i = 0; i < 256; i++)
    if (i == 0 || strcmp(vals[i], vals[i - 1]) != 0) runs++;
  fprintf(out, " %03x", runs);
  for (int i = 0; i < 256;) {
    int j = i;
    while (j < 256 && strcmp(vals[j], vals[i]) == 0) j++;
    fprintf(out, " %03x %s", j - i, vals[i]);
    i = j;
  }
}

void trace_reset(FILE *out, const cpu_t *c, mem_mode_t mode) {
  fputs("R xx xx", out);
  state(out, c);
  if (mode == MEM_WRITES)
    fputs(" 0 xx xx", out);
  else
    full_memory(out, c);
  fputc('\n', out);
}

void trace_step(FILE *out, uint8_t pc, const step_t *st, const cpu_t *c,
                mem_mode_t mode) {
  fprintf(out, "S %02x %02x", pc, st->code);
  state(out, c);
  if (mode == MEM_WRITES) {
    if (st->wrote)
      fprintf(out, " 1 %02x %02x", st->waddr, st->wdata);
    else
      fputs(" 0 xx xx", out);
  } else {
    full_memory(out, c);
  }
  fputc('\n', out);
}

void trace_end_halt(FILE *out) { fputs("END HALT\n", out); }

void trace_end_limit(FILE *out) { fputs("END LIMIT\n", out); }

void trace_end_error(FILE *out, uint8_t pc, val8 code, const char *msg) {
  char op[3];
  hex2(op, code);
  fprintf(out, "END ERROR %02x %s %s\n", pc, op, msg);
}

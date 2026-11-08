/* Test harness: executes single instructions from arbitrary states, so the
 * tests can compare every opcode against a reference model.
 *
 * usage: stepper [ISA_CSV] < cases
 *
 * Each input line:  CODE PC A B AR F D S0 S1 S2 S3 MEM
 * Each output line: PC A B AR F D S0 S1 S2 S3 W WADDR WDATA   or   ERR message
 *
 * Fields are hex; A, B, AR and F may have x digits. MEM is a seed: data
 * memory starts as M[i] = (i * 0x9d + MEM) mod 256, or all unknown if MEM is
 * xx. The output uses the trace's notation. */
#include <stdio.h>
#include <string.h>

#include "../cpu.h"
#include "../isa.h"
#include "../trace.h"

#ifndef DEFAULT_ISA_CSV
#define DEFAULT_ISA_CSV "docs/instructions.csv"
#endif

static int parse(const char *s, val8 *out) {
  size_t n = strlen(s);
  if (n < 1 || n > 2) return -1;
  val8 r = {0, 0};
  for (size_t i = 0; i < n; i++) {
    char ch = s[i];
    r.v = (uint8_t)(r.v << 4);
    r.k = (uint8_t)(r.k << 4);
    if (ch >= '0' && ch <= '9') {
      r.v |= (uint8_t)(ch - '0');
      r.k |= 0x0F;
    } else if (ch >= 'a' && ch <= 'f') {
      r.v |= (uint8_t)(ch - 'a' + 10);
      r.k |= 0x0F;
    } else if (ch != 'x') {
      return -1;
    }
  }
  if (n == 1 && (r.k & 0x0F)) r.k |= 0xF0;
  *out = r;
  return 0;
}

int main(int argc, char **argv) {
  static isa_t isa;
  static cpu_t c;
  char err[256], line[256];
  if (isa_load(&isa, argc > 1 ? argv[1] : DEFAULT_ISA_CSV, err, sizeof err)) {
    fprintf(stderr, "stepper: %s\n", err);
    return 3;
  }
  while (fgets(line, sizeof line, stdin)) {
    char f[12][8];
    if (sscanf(line, "%7s %7s %7s %7s %7s %7s %7s %7s %7s %7s %7s %7s", f[0],
               f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10],
               f[11]) != 12) {
      fprintf(stderr, "stepper: bad line: %s", line);
      return 3;
    }
    val8 v[12];
    for (int i = 0; i < 12; i++) {
      if (parse(f[i], &v[i])) {
        fprintf(stderr, "stepper: bad field '%s'\n", f[i]);
        return 3;
      }
    }
    for (int i = 0; i < 256; i++) c.imem[i] = (val8){0, 0};
    c.pc = v[1].v;
    c.imem[c.pc] = v[0];
    c.a = v[2];
    c.b = v[3];
    c.ar = v[4];
    c.f = (val8){(uint8_t)(v[5].v & 1), (uint8_t)(v[5].k & 1)};
    c.d = v[6].v;
    for (int i = 0; i < 4; i++) c.s[i] = v[7 + i].v;
    for (int i = 0; i < 256; i++)
      c.dmem[i] = v[11].k ? (val8){(uint8_t)(i * 0x9d + v[11].v), 0xFF}
                          : (val8){0, 0};

    step_t st;
    if (cpu_step(&c, &isa, &st)) {
      printf("ERR %s\n", st.err);
      continue;
    }
    char a[3], b[3], ar[3];
    hex2(a, c.a);
    hex2(b, c.b);
    hex2(ar, c.ar);
    printf("%02x %s %s %s %c %x %02x %02x %02x %02x", c.pc, a, b, ar,
           c.f.k ? (char)('0' + c.f.v) : 'x', c.d, c.s[0], c.s[1], c.s[2],
           c.s[3]);
    if (st.wrote)
      printf(" 1 %02x %02x\n", st.waddr, st.wdata);
    else
      printf(" 0 xx xx\n");
  }
  return 0;
}

#include "isa.h"
#include "util.h"

#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const struct {
  const char *name;
  int imm_bits; /* operand width the semantics expect */
} k_ops[OP_COUNT] = {
  [OP_NOP] = {"NOP", 0},
  [OP_ILA] = {"ILA", 4},   [OP_IHA] = {"IHA", 4},   [OP_ILB] = {"ILB", 4},
  [OP_IHB] = {"IHB", 4},   [OP_ALO] = {"ALO", 4},   [OP_AHI] = {"AHI", 4},
  [OP_SLDA] = {"SLDA", 4}, [OP_SLDB] = {"SLDB", 4},
  [OP_SSTA] = {"SSTA", 4}, [OP_SSTB] = {"SSTB", 4},
  [OP_LDA] = {"LDA", 0},   [OP_LDB] = {"LDB", 0},
  [OP_STA] = {"STA", 0},   [OP_STB] = {"STB", 0},
  [OP_INVA] = {"INVA", 0}, [OP_INVB] = {"INVB", 0},
  [OP_ADD] = {"ADD", 0},   [OP_SUB] = {"SUB", 0},   [OP_MUL] = {"MUL", 0},
  [OP_DIV] = {"DIV", 0},   [OP_SWAP] = {"SWAP", 0}, [OP_INC] = {"INC", 0},
  [OP_AND] = {"AND", 0},   [OP_NAND] = {"NAND", 0}, [OP_OR] = {"OR", 0},
  [OP_NOR] = {"NOR", 0},   [OP_XOR] = {"XOR", 0},   [OP_XNOR] = {"XNOR", 0},
  [OP_SHL] = {"SHL", 0},   [OP_SHR] = {"SHR", 0},
  [OP_EQ] = {"EQ", 0},     [OP_NEQ] = {"NEQ", 0},   [OP_LT] = {"LT", 0},
  [OP_GTE] = {"GTE", 0},   [OP_GT] = {"GT", 0},     [OP_LTE] = {"LTE", 0},
  [OP_CLF] = {"CLF", 0},   [OP_STF] = {"STF", 0},
  [OP_JMP] = {"JMP", 0},   [OP_JF] = {"JF", 0},     [OP_CALL] = {"CALL", 0},
  [OP_RET] = {"RET", 0},   [OP_TAR] = {"TAR", 0},
};

const char *isa_name(op_t op) {
  return (op >= 0 && op < OP_COUNT) ? k_ops[op].name : "?";
}

uint8_t isa_operand(const isa_t *isa, uint8_t code) {
  uint8_t wild = isa->wild[code], v = 0;
  int out = 0;
  for (int bit = 0; bit < 8; bit++) {
    if (wild & (1u << bit)) {
      v |= (uint8_t)(((code >> bit) & 1u) << out);
      out++;
    }
  }
  return v;
}

/* ---- CSV reading (RFC 4180: quoted fields, "" escapes, CRLF or LF) ---- */

#define MAX_FIELDS 64
#define MAX_FIELD 512

typedef struct {
  const char *p, *end;
  int line; /* line the current record starts on */
  int cur_line;
} csv_t;

/* Reads one record. Returns the number of fields, 0 at end of input, or -1
 * on a malformed record. Fields are copied into `fields` (NUL-terminated). */
static int csv_record(csv_t *c, char fields[][MAX_FIELD], int max) {
  if (c->p >= c->end) return 0;
  c->line = c->cur_line;
  int n = 0;
  for (;;) {
    if (n == max) return -1;
    char *out = fields[n];
    size_t len = 0;
    if (c->p < c->end && *c->p == '"') {
      c->p++;
      for (;;) {
        if (c->p >= c->end) return -1; /* unterminated quote */
        char ch = *c->p++;
        if (ch == '"') {
          if (c->p < c->end && *c->p == '"') {
            c->p++;
          } else {
            break;
          }
        }
        if (ch == '\n') c->cur_line++;
        if (len + 1 >= MAX_FIELD) return -1;
        out[len++] = ch;
      }
      if (c->p < c->end && *c->p != ',' && *c->p != '\n' && *c->p != '\r')
        return -1; /* text after a closing quote */
    } else {
      while (c->p < c->end && *c->p != ',' && *c->p != '\n' && *c->p != '\r') {
        if (len + 1 >= MAX_FIELD) return -1;
        out[len++] = *c->p++;
      }
    }
    out[len] = '\0';
    n++;
    if (c->p < c->end && *c->p == ',') {
      c->p++;
      continue;
    }
    if (c->p < c->end && *c->p == '\r') c->p++;
    if (c->p < c->end && *c->p == '\n') c->p++;
    c->cur_line++;
    return n;
  }
}

static void trim(char *s) {
  size_t len = strlen(s);
  while (len > 0 && isspace((unsigned char)s[len - 1])) s[--len] = '\0';
  size_t lead = strspn(s, " \t");
  if (lead) memmove(s, s + lead, len - lead + 1);
}

static int fail(char *err, size_t errlen, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  vsnprintf(err, errlen, fmt, ap);
  va_end(ap);
  return -1;
}

int isa_load(isa_t *isa, const char *path, char *err, size_t errlen) {
  size_t size;
  char *text = read_file(path, &size);
  if (!text) return fail(err, errlen, "%s: cannot read", path);

  static char fields[MAX_FIELDS][MAX_FIELD];
  csv_t c = {text, text + size, 1, 1};
  int rc = -1;

  int nf = csv_record(&c, fields, MAX_FIELDS);
  if (nf <= 0) {
    fail(err, errlen, "%s: missing or malformed header", path);
    goto out;
  }
  int col_name = -1, col_bit[8];
  for (int b = 0; b < 8; b++) col_bit[b] = -1;
  for (int i = 0; i < nf; i++) {
    trim(fields[i]);
    if (strcmp(fields[i], "Name") == 0) col_name = i;
    if (fields[i][0] == 'b' && fields[i][1] >= '0' && fields[i][1] <= '7' &&
        fields[i][2] == '\0')
      col_bit[fields[i][1] - '0'] = i;
  }
  if (col_name < 0) {
    fail(err, errlen, "%s: header has no Name column", path);
    goto out;
  }
  for (int b = 0; b < 8; b++) {
    if (col_bit[b] < 0) {
      fail(err, errlen, "%s: header has no b%d column", path, b);
      goto out;
    }
  }

  int row_of[OP_COUNT] = {0}; /* CSV line each op was defined on */
  int line_of_code[256] = {0};
  for (int i = 0; i < 256; i++) {
    isa->op[i] = OP_NOP;
    isa->wild[i] = 0;
  }

  while ((nf = csv_record(&c, fields, MAX_FIELDS)) != 0) {
    if (nf < 0) {
      fail(err, errlen, "%s:%d: malformed CSV record", path, c.line);
      goto out;
    }
    int blank = 1;
    for (int i = 0; i < nf; i++) {
      trim(fields[i]);
      if (fields[i][0]) blank = 0;
    }
    if (blank) continue;

    int need = col_name;
    for (int b = 0; b < 8; b++)
      if (col_bit[b] > need) need = col_bit[b];
    if (nf <= need) {
      fail(err, errlen, "%s:%d: too few fields", path, c.line);
      goto out;
    }

    const char *name = fields[col_name];
    op_t op = OP_COUNT;
    for (int o = 1; o < OP_COUNT; o++) {
      if (strcmp(name, k_ops[o].name) == 0) op = (op_t)o;
    }
    if (op == OP_COUNT) {
      fail(err, errlen, "%s:%d: unknown instruction '%s'", path, c.line, name);
      goto out;
    }
    if (row_of[op]) {
      fail(err, errlen, "%s:%d: %s already defined on line %d", path, c.line,
           name, row_of[op]);
      goto out;
    }
    row_of[op] = c.line;

    uint8_t fixed = 0, value = 0;
    int nwild = 0;
    for (int b = 0; b < 8; b++) {
      const char *cell = fields[col_bit[b]];
      if (strcmp(cell, "0") == 0) {
        fixed |= (uint8_t)(1u << b);
      } else if (strcmp(cell, "1") == 0) {
        fixed |= (uint8_t)(1u << b);
        value |= (uint8_t)(1u << b);
      } else if (strcmp(cell, "imm4") == 0) {
        nwild++;
      } else {
        fail(err, errlen, "%s:%d: %s: bad b%d cell '%s'", path, c.line, name, b,
             cell);
        goto out;
      }
    }
    if (nwild != k_ops[op].imm_bits) {
      fail(err, errlen, "%s:%d: %s has a %d-bit operand, expected %d bits",
           path, c.line, name, nwild, k_ops[op].imm_bits);
      goto out;
    }

    for (int code = 0; code < 256; code++) {
      if ((code & fixed) != value) continue;
      if (isa->op[code] != OP_NOP) {
        fail(err, errlen, "%s:%d: %s overlaps %s (line %d) at code 0x%02X",
             path, c.line, name, k_ops[isa->op[code]].name, line_of_code[code],
             code);
        goto out;
      }
      isa->op[code] = op;
      isa->wild[code] = (uint8_t)~fixed;
      line_of_code[code] = c.line;
    }
  }

  for (int o = 1; o < OP_COUNT; o++) {
    if (!row_of[o]) {
      fail(err, errlen, "%s: no row for %s", path, k_ops[o].name);
      goto out;
    }
  }
  rc = 0;
out:
  free(text);
  return rc;
}

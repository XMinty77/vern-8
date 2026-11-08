#include "hexload.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "util.h"

static int fail(char *err, size_t errlen, const char *path, int line,
                const char *fmt, ...) {
  char msg[160];
  va_list ap;
  va_start(ap, fmt);
  vsnprintf(msg, sizeof msg, fmt, ap);
  va_end(ap);
  snprintf(err, errlen, "%s:%d: %s", path, line, msg);
  return -1;
}

static int is_word_char(char ch) {
  return (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') ||
         (ch >= 'A' && ch <= 'F') || ch == 'x' || ch == 'X' || ch == 'z' ||
         ch == 'Z' || ch == '_';
}

/* Value of a hex digit, or -1 for an unknown (x/z) digit. */
static int digit(char ch) {
  if (ch >= '0' && ch <= '9') return ch - '0';
  if (ch >= 'a' && ch <= 'f') return ch - 'a' + 10;
  if (ch >= 'A' && ch <= 'F') return ch - 'A' + 10;
  return -1;
}

int hex_load(const char *path, val8 mem[256], char *err, size_t errlen) {
  for (int i = 0; i < 256; i++) mem[i] = (val8){0, 0};

  size_t size;
  char *text = read_file(path, &size);
  if (!text) {
    snprintf(err, errlen, "%s: cannot read", path);
    return -1;
  }

  const char *p = text, *end = text + size;
  int line = 1, rc = -1;
  unsigned addr = 0;
  char tok[64];

  while (p < end) {
    char ch = *p;
    if (ch == '\n') {
      line++;
      p++;
    } else if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\f' ||
               ch == '\v') {
      p++;
    } else if (ch == '/' && p + 1 < end && p[1] == '/') {
      while (p < end && *p != '\n') p++;
    } else if (ch == '/' && p + 1 < end && p[1] == '*') {
      int start = line;
      p += 2;
      while (p + 1 < end && !(p[0] == '*' && p[1] == '/')) {
        if (*p == '\n') line++;
        p++;
      }
      if (p + 1 >= end) {
        fail(err, errlen, path, start, "unterminated block comment");
        goto out;
      }
      p += 2;
    } else if (ch == '@' || is_word_char(ch)) {
      int marker = (ch == '@');
      if (marker) p++;
      size_t len = 0;
      while (p < end && is_word_char(*p)) {
        if (len + 1 >= sizeof tok) {
          fail(err, errlen, path, line, "number too long");
          goto out;
        }
        tok[len++] = *p++;
      }
      tok[len] = '\0';
      if (p < end && !(*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n' ||
                       *p == '\f' || *p == '\v' || *p == '/')) {
        fail(err, errlen, path, line, "unexpected character '%c'", *p);
        goto out;
      }
      if (len == 0 || tok[0] == '_') {
        fail(err, errlen, path, line, marker ? "malformed address" : "malformed word");
        goto out;
      }
      /* Drop separators, then leading zeros (they don't add width). */
      char digits[64];
      size_t nd = 0;
      for (size_t i = 0; i < len; i++)
        if (tok[i] != '_') digits[nd++] = tok[i];
      digits[nd] = '\0';
      const char *d = digits;
      while (nd > 2 && *d == '0') {
        d++;
        nd--;
      }

      if (marker) {
        unsigned a = 0;
        for (size_t i = 0; i < nd; i++) {
          int dv = digit(d[i]);
          if (dv < 0) {
            fail(err, errlen, path, line, "unknown digit in address @%s", tok);
            goto out;
          }
          a = a * 16 + (unsigned)dv;
          if (a > 0xFF) {
            fail(err, errlen, path, line, "address @%s is past 0xFF", tok);
            goto out;
          }
        }
        addr = a;
      } else {
        if (nd > 2) {
          fail(err, errlen, path, line, "word %s is wider than 8 bits", tok);
          goto out;
        }
        if (addr > 0xFF) {
          fail(err, errlen, path, line, "word %s is past address 0xFF", tok);
          goto out;
        }
        val8 w = {0, 0};
        for (size_t i = 0; i < nd; i++) {
          int dv = digit(d[i]);
          w.v = (uint8_t)(w.v << 4);
          w.k = (uint8_t)(w.k << 4);
          if (dv >= 0) {
            w.v |= (uint8_t)dv;
            w.k |= 0x0F;
          }
        }
        if (nd == 1) {
          /* One digit: the upper nibble is zero, or x if the digit is x/z
           * (Verilog extends an unknown leading digit). */
          if (w.k & 0x0F) w.k |= 0xF0;
        }
        mem[addr++] = w;
      }
    } else {
      fail(err, errlen, path, line, "unexpected character '%c'", ch);
      goto out;
    }
  }
  rc = 0;
out:
  free(text);
  return rc;
}

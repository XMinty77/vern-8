#include "util.h"

#include <stdio.h>
#include <stdlib.h>

char *read_file(const char *path, size_t *size) {
  FILE *f = fopen(path, "rb");
  if (!f) return NULL;
  size_t cap = 4096, len = 0;
  char *buf = malloc(cap);
  size_t got;
  while (buf && (got = fread(buf + len, 1, cap - len, f)) > 0) {
    len += got;
    if (len == cap) {
      char *bigger = realloc(buf, cap *= 2);
      if (!bigger) free(buf);
      buf = bigger;
    }
  }
  if (buf && ferror(f)) {
    free(buf);
    buf = NULL;
  }
  fclose(f);
  *size = len;
  return buf;
}

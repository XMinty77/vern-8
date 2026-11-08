/* Loader for $readmemh-style hex files. */
#ifndef HEXLOAD_H
#define HEXLOAD_H

#include <stddef.h>

#include "cpu.h"

/* Loads `path` into mem[0..255], which starts all unknown; words the file
 * doesn't set stay unknown. Accepts what $readmemh accepts: whitespace-
 * separated hex words of up to 8 bits (x/X/z/Z digits are unknown, `_` is a
 * separator), `@addr` markers in hex, and `//` and block comments. A word
 * past address 0xFF or wider than 8 bits is an error. Returns 0, or -1 with
 * a message in err. */
int hex_load(const char *path, val8 mem[256], char *err, size_t errlen);

#endif

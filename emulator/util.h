#ifndef UTIL_H
#define UTIL_H

#include <stddef.h>

/* Reads a whole file into a malloc'd buffer (not NUL-terminated); its length
 * goes into *size. Returns NULL if the file can't be read. */
char *read_file(const char *path, size_t *size);

#endif

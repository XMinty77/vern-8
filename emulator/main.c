/* emu: instruction-level emulator of the Vernacular 8 CPU.
 *
 * Runs a program from reset and writes a trace of the architectural state
 * after every instruction, for the core's testbench to compare against. */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cpu.h"
#include "hexload.h"
#include "isa.h"
#include "trace.h"

#ifndef DEFAULT_ISA_CSV
#define DEFAULT_ISA_CSV "docs/instructions.csv"
#endif

#define DEFAULT_MAX_STEPS 100000ULL
/* A run halts once this many instructions in a row leave PC unchanged. More
 * than the stack depth, so a chain of RETs to their own address doesn't count. */
#define HALT_RUN 5

enum { EXIT_HALT = 0, EXIT_PROG_ERROR = 1, EXIT_LIMIT = 2, EXIT_USAGE = 3 };

static void usage(FILE *out) {
  fprintf(out,
          "usage: emu [options] PROGRAM.hex\n"
          "  -o, --trace FILE      write the trace to FILE (default: standard output)\n"
          "  -m, --mem MODE        data memory in the trace: writes (default) or full\n"
          "  -n, --max-steps N     stop a run that hasn't halted after N instructions\n"
          "                        (default %llu)\n"
          "  -i, --isa FILE        instruction table (default: %s)\n"
          "  -h, --help            show this help\n"
          "exit status: 0 halted, 1 error in the program, 2 step limit,\n"
          "             3 bad usage or unreadable/malformed input\n",
          DEFAULT_MAX_STEPS, DEFAULT_ISA_CSV);
}

static int usage_error(const char *fmt, const char *arg) {
  fprintf(stderr, "emu: ");
  fprintf(stderr, fmt, arg);
  fprintf(stderr, "\n");
  usage(stderr);
  return EXIT_USAGE;
}

/* Matches argv[*i] against -s / --long / --long=VALUE; on a match, stores the
 * option's value in *val (taking the next argument if needed). Returns 1 on
 * a match, 0 if it isn't this option, -1 if the value is missing. */
static int option(int argc, char **argv, int *i, const char *s,
                  const char *lng, const char **val) {
  const char *arg = argv[*i];
  size_t ll = strlen(lng);
  if (strcmp(arg, s) == 0 || strcmp(arg, lng) == 0) {
    if (*i + 1 >= argc) return -1;
    *val = argv[++*i];
    return 1;
  }
  if (strncmp(arg, lng, ll) == 0 && arg[ll] == '=') {
    *val = arg + ll + 1;
    return 1;
  }
  return 0;
}

int main(int argc, char **argv) {
  const char *trace_path = NULL, *isa_path = DEFAULT_ISA_CSV, *prog = NULL;
  const char *mode_s = "writes", *steps_s = NULL;
  int only_args = 0;

  for (int i = 1; i < argc; i++) {
    const char *arg = argv[i];
    if (only_args || arg[0] != '-' || arg[1] == '\0') {
      if (prog) return usage_error("more than one program: %s", arg);
      prog = arg;
      continue;
    }
    if (strcmp(arg, "--") == 0) {
      only_args = 1;
      continue;
    }
    if (strcmp(arg, "-h") == 0 || strcmp(arg, "--help") == 0) {
      usage(stdout);
      return 0;
    }
    int r;
    if ((r = option(argc, argv, &i, "-o", "--trace", &trace_path)) ||
        (r = option(argc, argv, &i, "-m", "--mem", &mode_s)) ||
        (r = option(argc, argv, &i, "-n", "--max-steps", &steps_s)) ||
        (r = option(argc, argv, &i, "-i", "--isa", &isa_path))) {
      if (r < 0) return usage_error("option %s needs a value", arg);
      continue;
    }
    return usage_error("unknown option %s", arg);
  }
  if (!prog) return usage_error("%s", "no program given");

  mem_mode_t mode;
  if (strcmp(mode_s, "writes") == 0)
    mode = MEM_WRITES;
  else if (strcmp(mode_s, "full") == 0)
    mode = MEM_FULL;
  else
    return usage_error("memory mode must be writes or full, not '%s'", mode_s);

  unsigned long long max_steps = DEFAULT_MAX_STEPS;
  if (steps_s) {
    char *endp;
    errno = 0;
    max_steps = strtoull(steps_s, &endp, 10);
    if (steps_s[0] < '0' || steps_s[0] > '9' || *endp || errno)
      return usage_error("bad step limit '%s'", steps_s);
  }

  static isa_t isa;
  static cpu_t cpu;
  char err[256];
  if (isa_load(&isa, isa_path, err, sizeof err) != 0) {
    fprintf(stderr, "emu: %s\n", err);
    return EXIT_USAGE;
  }
  if (hex_load(prog, cpu.imem, err, sizeof err) != 0) {
    fprintf(stderr, "emu: %s\n", err);
    return EXIT_USAGE;
  }

  FILE *out = stdout;
  if (trace_path) {
    out = fopen(trace_path, "w");
    if (!out) {
      fprintf(stderr, "emu: %s: %s\n", trace_path, strerror(errno));
      return EXIT_USAGE;
    }
  }

  cpu_reset(&cpu);
  trace_reset(out, &cpu, mode);

  int status = EXIT_LIMIT;
  unsigned long long steps = 0;
  int unchanged = 0;
  while (steps < max_steps) {
    uint8_t pc = cpu.pc;
    step_t st;
    if (cpu_step(&cpu, &isa, &st) != 0) {
      trace_end_error(out, pc, cpu.imem[pc], st.err);
      fprintf(stderr, "emu: error after %llu instructions, at PC %02x: %s\n",
              steps, pc, st.err);
      status = EXIT_PROG_ERROR;
      break;
    }
    steps++;
    trace_step(out, pc, &st, &cpu, mode);
    unchanged = cpu.pc == pc ? unchanged + 1 : 0;
    if (unchanged == HALT_RUN) {
      trace_end_halt(out);
      status = EXIT_HALT;
      break;
    }
  }
  if (status == EXIT_LIMIT) {
    trace_end_limit(out);
    fprintf(stderr, "emu: no halt within %llu instructions\n", max_steps);
  }

  if (fflush(out) != 0 || ferror(out) || (out != stdout && fclose(out) != 0)) {
    fprintf(stderr, "emu: error writing the trace\n");
    return EXIT_USAGE;
  }
  return status;
}

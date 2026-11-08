#include "cpu.h"

#include <stdio.h>
#include <string.h>

static const val8 UNKNOWN = {0x00, 0x00};

static val8 known(uint8_t v) { return (val8){v, 0xFF}; }
static val8 flag(int f) { return (val8){(uint8_t)(f ? 1 : 0), 0x01}; }

void cpu_reset(cpu_t *c) {
  c->pc = 0;
  c->a = c->b = c->ar = UNKNOWN;
  c->f = UNKNOWN;
  c->d = 0;
  memset(c->s, 0, sizeof c->s);
  for (int i = 0; i < 256; i++) c->dmem[i] = UNKNOWN;
}

/* Write one nibble of r, keeping the other (known or not). */
static val8 set_lo(val8 r, uint8_t n) {
  return (val8){(uint8_t)((r.v & 0xF0) | (n & 0x0F)), (uint8_t)(r.k | 0x0F)};
}
static val8 set_hi(val8 r, uint8_t n) {
  return (val8){(uint8_t)((r.v & 0x0F) | (n << 4)), (uint8_t)(r.k | 0xF0)};
}

/* Strict reads: each returns -1 from cpu_step if the value isn't known. */
#define NEED(cond, ...)                              \
  do {                                               \
    if (!(cond)) {                                   \
      snprintf(st->err, sizeof st->err, __VA_ARGS__); \
      return -1;                                     \
    }                                                \
  } while (0)
#define NEED_A() NEED(KNOWN(c->a), "reads unknown A")
#define NEED_B() NEED(KNOWN(c->b), "reads unknown B")
#define NEED_AB() \
  do {            \
    NEED_A();     \
    NEED_B();     \
  } while (0)
#define NEED_AR(use) NEED(KNOWN(c->ar), "reads unknown AR (" use ")")
#define NEED_M(addr) \
  NEED(KNOWN(c->dmem[addr]), "reads unknown M[0x%02X]", (unsigned)(addr))

int cpu_step(cpu_t *c, const isa_t *isa, step_t *st) {
  st->wrote = 0;
  st->err[0] = '\0';
  st->code = c->imem[c->pc].v;
  st->op = OP_NOP;
  NEED(KNOWN(c->imem[c->pc]), "executes unknown instruction word");

  const uint8_t code = c->imem[c->pc].v;
  const op_t op = isa->op[code];
  const uint8_t v = isa_operand(isa, code);
  st->op = op;

  /* Next state. Every check happens before any field of *c changes, so a
   * failing instruction leaves the state as it was. */
  cpu_t n_regs; /* only the registers are copied; memory is written below */
  memcpy(&n_regs, c, offsetof(cpu_t, dmem));
  cpu_t *n = &n_regs;
  n->pc = (uint8_t)(c->pc + 1);

  const uint8_t a = c->a.v, b = c->b.v;
  int write = 0;
  uint8_t waddr = 0, wdata = 0;

  switch (op) {
    case OP_NOP: break;

    case OP_ILA: n->a = set_lo(c->a, v); break;
    case OP_IHA: n->a = set_hi(c->a, v); break;
    case OP_ILB: n->b = set_lo(c->b, v); break;
    case OP_IHB: n->b = set_hi(c->b, v); break;
    case OP_ALO: n->ar = set_lo(c->ar, v); break;
    case OP_AHI: n->ar = set_hi(c->ar, v); break;

    case OP_SLDA: NEED_M(v); n->a = c->dmem[v]; break;
    case OP_SLDB: NEED_M(v); n->b = c->dmem[v]; break;
    case OP_SSTA: NEED_A(); write = 1; waddr = v; wdata = a; break;
    case OP_SSTB: NEED_B(); write = 1; waddr = v; wdata = b; break;

    case OP_LDA: NEED_AR("address"); NEED_M(c->ar.v); n->a = c->dmem[c->ar.v]; break;
    case OP_LDB: NEED_AR("address"); NEED_M(c->ar.v); n->b = c->dmem[c->ar.v]; break;
    case OP_STA: NEED_AR("address"); NEED_A(); write = 1; waddr = c->ar.v; wdata = a; break;
    case OP_STB: NEED_AR("address"); NEED_B(); write = 1; waddr = c->ar.v; wdata = b; break;

    case OP_INVA: NEED_A(); n->a = known((uint8_t)~a); break;
    case OP_INVB: NEED_B(); n->b = known((uint8_t)~b); break;
    case OP_ADD: {
      NEED_AB();
      unsigned s = (unsigned)a + b;
      n->a = known((uint8_t)s);
      n->f = flag(s > 0xFF);
      break;
    }
    case OP_SUB:
      NEED_AB();
      n->a = known((uint8_t)(a - b));
      n->f = flag(a < b);
      break;
    case OP_MUL: {
      NEED_AB();
      unsigned p = (unsigned)a * b;
      n->a = known((uint8_t)p);
      n->f = flag((p >> 8) != 0);
      break;
    }
    case OP_DIV:
      NEED_AB();
      if (b == 0) {
        n->f = flag(1); /* A and B unchanged */
      } else {
        n->a = known((uint8_t)(a / b));
        n->b = known((uint8_t)(a % b));
        n->f = flag(0);
      }
      break;
    case OP_SWAP: NEED_AB(); n->a = c->b; n->b = c->a; break;
    case OP_INC:
      NEED_A();
      n->a = known((uint8_t)(a + 1));
      n->f = flag(a == 0xFF);
      break;
    case OP_AND:  NEED_AB(); n->a = known((uint8_t)(a & b)); break;
    case OP_NAND: NEED_AB(); n->a = known((uint8_t)~(a & b)); break;
    case OP_OR:   NEED_AB(); n->a = known((uint8_t)(a | b)); break;
    case OP_NOR:  NEED_AB(); n->a = known((uint8_t)~(a | b)); break;
    case OP_XOR:  NEED_AB(); n->a = known((uint8_t)(a ^ b)); break;
    case OP_XNOR: NEED_AB(); n->a = known((uint8_t)~(a ^ b)); break;
    case OP_SHL: NEED_AB(); n->a = known(b >= 8 ? 0 : (uint8_t)(a << b)); break;
    case OP_SHR: NEED_AB(); n->a = known(b >= 8 ? 0 : (uint8_t)(a >> b)); break;

    case OP_EQ:  NEED_AB(); n->f = flag(a == b); break;
    case OP_NEQ: NEED_AB(); n->f = flag(a != b); break;
    case OP_LT:  NEED_AB(); n->f = flag(a < b); break;
    case OP_GTE: NEED_AB(); n->f = flag(a >= b); break;
    case OP_GT:  NEED_AB(); n->f = flag(a > b); break;
    case OP_LTE: NEED_AB(); n->f = flag(a <= b); break;
    case OP_CLF: n->f = flag(0); break;
    case OP_STF: n->f = flag(1); break;

    case OP_JMP: NEED_AR("jump target"); n->pc = c->ar.v; break;
    case OP_JF:
      NEED(c->f.k == 0x01, "reads unknown F");
      if (c->f.v) {
        NEED_AR("jump target");
        n->pc = c->ar.v;
      }
      break;
    case OP_CALL:
      NEED_AR("jump target");
      n->s[3] = c->s[2];
      n->s[2] = c->s[1];
      n->s[1] = c->s[0];
      n->s[0] = (uint8_t)(c->pc + 1);
      n->d = c->d < 4 ? (uint8_t)(c->d + 1) : 4;
      n->pc = c->ar.v;
      break;
    case OP_RET:
      if (c->d > 0) {
        n->pc = c->s[0];
        n->s[0] = c->s[1];
        n->s[1] = c->s[2];
        n->s[2] = c->s[3];
        n->s[3] = 0;
        n->d = (uint8_t)(c->d - 1);
      }
      break;
    case OP_TAR: NEED_A(); n->ar = c->a; break;

    case OP_COUNT: break; /* not reachable: the decoder never yields it */
  }

  memcpy(c, n, offsetof(cpu_t, dmem));
  if (write) {
    c->dmem[waddr] = known(wdata);
    st->wrote = 1;
    st->waddr = waddr;
    st->wdata = wdata;
  }
  return 0;
}

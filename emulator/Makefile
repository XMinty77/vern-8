# Builds the emulator into build/emulator/ at the repo root.
#   make -C emulator          build build/emulator/emu
#   make -C emulator test     build, then run the tests (needs pytest)
#   make -C emulator clean    remove build/emulator/

ROOT    := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
SRC     := $(ROOT)/emulator
OUT     := $(ROOT)/build/emulator
ISA_CSV := $(ROOT)/docs/instructions.csv

CC      ?= cc
CFLAGS  ?= -O2 -g
CFLAGS  += -std=c11 -Wall -Wextra -Wpedantic -Wshadow -Wconversion
CPPFLAGS += -DDEFAULT_ISA_CSV='"$(ISA_CSV)"'

CORE    := isa cpu hexload trace util
CORE_O  := $(CORE:%=$(OUT)/%.o)
HEADERS := $(wildcard $(SRC)/*.h)

.PHONY: all test clean
all: $(OUT)/emu $(OUT)/stepper

$(OUT)/emu: $(CORE_O) $(OUT)/main.o
	$(CC) $(LDFLAGS) -o $@ $^

$(OUT)/stepper: $(CORE_O) $(OUT)/stepper.o
	$(CC) $(LDFLAGS) -o $@ $^

$(OUT)/%.o: $(SRC)/%.c $(HEADERS) | $(OUT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(OUT)/stepper.o: $(SRC)/tests/stepper.c $(HEADERS) | $(OUT)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(OUT):
	mkdir -p $@

test: all
	cd $(ROOT) && python3 -m pytest -q emulator

clean:
	rm -rf $(OUT)

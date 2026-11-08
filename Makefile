# ================ cpu-1 Makefile ================
# make              compile and run every bench (same as make sim)
# make alu          compile and run one bench: tb/alu_tb.sv
# make alu EXHAUSTIVE=1
#                   run in exhaustive mode (passes +exhaustive; works with make/make sim too)
# make alu ARGS=+foo
#                   pass any other plusargs to the bench
# make asm          assemble tb/programs/*.asm into build/programs/
# make emu          build the emulator
# make core         run the core bench on every assembled program (needs asm and emu)
# make core PROG=foo
#                   run it on build/programs/foo.hex only
# make lint         Verilator lint of every bench, with the RTL it uses
# make lint-alu     lint one bench
# make clean        delete build/
# A bench that fails ($fatal) makes make stop with an error.
# ================================================

# Packages, in dependency order: each one is compiled before anything that imports it.
# Add new packages here (and in .vscode/settings.json and .vscode/verible.filelist).
PKGS  := rtl/opcodes.sv tb/tb_prefs.sv
# All other RTL files: modules.
RTL   := $(filter-out $(PKGS),$(wildcard rtl/*.sv))
# Benches are tb/<unit>_tb.sv; each <unit> becomes a target (alu, ...).
UNITS := $(patsubst tb/%_tb.sv,%,$(wildcard tb/*_tb.sv))

BUILD     := build
IVERILOG  := iverilog -g2012 -Wall
VVP       := vvp -n
VERILATOR := verilator --lint-only -Wall --timing
ARGS      :=
# 1 adds +exhaustive to the bench's plusargs; anything else leaves it off.
EXHAUSTIVE :=

# Core bench programs: tb/programs/<name>.asm, assembled to build/programs/<name>.hex.
PROG_DIR  := tb/programs
PROG_HEXS := $(patsubst $(PROG_DIR)/%.asm,$(BUILD)/programs/%.hex,$(wildcard $(PROG_DIR)/*.asm))
EMU       := $(BUILD)/emulator/emu
# make core PROG=<name> runs only that program.
PROG      :=

.PHONY: all sim lint clean asm emu $(UNITS) $(addprefix lint-,$(UNITS))

all: sim

# The core bench last: it needs programs, and a failure stops make before the rest.
sim: $(filter-out core,$(UNITS)) $(filter core,$(UNITS))

# Compile a bench: packages first, then the RTL, then the bench. -s names the top module.
$(BUILD)/%_tb.vvp: tb/%_tb.sv $(PKGS) $(RTL) | $(BUILD)
	$(IVERILOG) -s $*_tb -o $@ $(PKGS) $(RTL) $<

# Run a bench. vvp exits with status 1 when the bench calls $fatal(1, ...).
$(filter-out core,$(UNITS)): %: $(BUILD)/%_tb.vvp
	$(VVP) $< $(if $(filter 1,$(EXHAUSTIVE)),+exhaustive) $(ARGS)

# Assemble every program in tb/programs/ into build/programs/.
asm: $(PROG_HEXS)

$(BUILD)/programs/%.hex: $(PROG_DIR)/%.asm
	python3 assembler/asm.py $< -o $@

# Build the emulator (its own Makefile, output in build/emulator/).
emu:
	$(MAKE) -C emulator

# Core bench, one simulation per program. Assumes make asm and make emu have run.
# For each hex: run the emulator to get its trace (exit 3 = it rejected the input),
# then the bench against that trace. A line "; expect: error" or "; expect: limit"
# in the program's source names a trace that must not end in a halt.
core: $(BUILD)/core_tb.vvp
	@test -x $(EMU) || { echo "No emulator at $(EMU): run make emu"; exit 1; }; \
	ran=0; failed=0; \
	for hex in $(if $(PROG),$(BUILD)/programs/$(PROG).hex,$(BUILD)/programs/*.hex); do \
	  test -e $$hex || { echo "No program at $$hex: run make asm"; exit 1; }; \
	  name=$$(basename $$hex .hex); trace=$(BUILD)/programs/$$name.trace; \
	  ran=$$((ran + 1)); \
	  $(EMU) -o $$trace $$hex 2>/dev/null; \
	  if [ $$? -eq 3 ]; then echo "$$name: the emulator rejected it"; failed=$$((failed + 1)); continue; fi; \
	  end=$$(sed -n 's/^;[[:space:]]*expect:[[:space:]]*\([a-z]*\).*/\1/p' $(PROG_DIR)/$$name.asm 2>/dev/null | head -n 1 | tr a-z A-Z); \
	  $(VVP) $< +hex=$$hex +trace=$$trace +end=$${end:-HALT} $(ARGS) || failed=$$((failed + 1)); \
	done; \
	echo "core: $$ran programs, $$failed failed"; \
	test $$failed -eq 0

lint: $(addprefix lint-,$(UNITS))

# Lint a bench and everything it instantiates (modules found in rtl/ by name).
$(addprefix lint-,$(UNITS)): lint-%: tb/%_tb.sv $(PKGS)
	$(VERILATOR) -Irtl --top-module $*_tb $(PKGS) $<

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)

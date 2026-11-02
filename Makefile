# ================ cpu-1 Makefile ================
# make              compile and run every bench (same as make sim)
# make alu          compile and run one bench: tb/alu_tb.sv
# make alu EXHAUSTIVE=1
#                   run in exhaustive mode (passes +exhaustive; works with make/make sim too)
# make alu ARGS=+foo
#                   pass any other plusargs to the bench
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

.PHONY: all sim lint clean $(UNITS) $(addprefix lint-,$(UNITS))

all: sim

sim: $(UNITS)

# Compile a bench: packages first, then the RTL, then the bench. -s names the top module.
$(BUILD)/%_tb.vvp: tb/%_tb.sv $(PKGS) $(RTL) | $(BUILD)
	$(IVERILOG) -s $*_tb -o $@ $(PKGS) $(RTL) $<

# Run a bench. vvp exits with status 1 when the bench calls $fatal(1, ...).
$(UNITS): %: $(BUILD)/%_tb.vvp
	$(VVP) $< $(if $(filter 1,$(EXHAUSTIVE)),+exhaustive) $(ARGS)

lint: $(addprefix lint-,$(UNITS))

# Lint a bench and everything it instantiates (modules found in rtl/ by name).
$(addprefix lint-,$(UNITS)): lint-%: tb/%_tb.sv $(PKGS)
	$(VERILATOR) -Irtl --top-module $*_tb $(PKGS) $<

$(BUILD):
	mkdir -p $@

clean:
	rm -rf $(BUILD)

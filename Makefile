COMPILER = iverilog
SIMULATOR = vvp
WAVEGUI = gtkwave
FLAGS = -Wall -g2012
CORE_DIR = ./core
BUS_DIR = ./bus
PERIPHERAL_DIR = ./peripheral
SYSTEM_DIR = ./system
TEST_FILE = ./test/cpu_tb.v
SOC_TEST_FILE = ./test/soc_tb.v
CACHE_TEST_FILE = ./test/cache_tb.v

SOURCES = $(shell find $(CORE_DIR) -name "*.v") $(shell find $(BUS_DIR) -name "*.v") $(shell find $(SYSTEM_DIR) -name "*.v") $(shell find $(PERIPHERAL_DIR) -name "*.v") $(TEST_FILE)
SOC_SOURCES = $(shell find $(CORE_DIR) -name "*.v") $(shell find $(BUS_DIR) -name "*.v") $(shell find $(SYSTEM_DIR) -name "*.v") $(shell find $(PERIPHERAL_DIR) -name "*.v") $(SOC_TEST_FILE)
CACHE_SOURCES = $(shell find $(CORE_DIR) -name "*.v") $(shell find $(BUS_DIR) -name "*.v") $(shell find $(SYSTEM_DIR) -name "*.v") $(shell find $(PERIPHERAL_DIR) -name "*.v") ./test/cache_tb.v
# TESTBENCH = testbench/tb_top.v
# OUTPUT = sim/simulation

all: compile run

soc: compile_soc run_soc

cache: compile_cache run_cache

compile:
	$(COMPILER) $(FLAGS) -o ./build/out $(SOURCES)

compile_soc:
	$(COMPILER) $(FLAGS) -o ./build/soc_out $(SOC_SOURCES)

compile_cache:
	$(COMPILER) $(FLAGS) -o ./build/cache_out $(CACHE_SOURCES)

run:
	$(SIMULATOR) -n ./build/out -vcd ./build/out.vcd

run_soc:
	$(SIMULATOR) -n ./build/soc_out -vcd ./build/soc_out.vcd

run_cache:
	$(SIMULATOR) -n ./build/cache_out -vcd ./build/cache_out.vcd

wave:
	$(WAVEGUI) ./build/out.vcd

wave_soc:
	$(WAVEGUI) ./build/soc_out.vcd

wave_cache:
	$(WAVEGUI) ./build/cache_out.vcd

clean:
	rm -f ./build/*

.PHONY: all compile run soc compile_soc run_soc cache compile_cache run_cache debug compile_debug run_debug clean
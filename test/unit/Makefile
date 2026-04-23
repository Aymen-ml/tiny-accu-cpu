# Unit-test Makefile for individual CPU modules using Cocotb

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../../src

# Select design under test, testbench, and python test module.
# Example: make -B DUT=alu
DUT ?= alu
TB ?= tb_$(DUT)
TEST ?= test_$(DUT)

SIM_BUILD = sim_build/$(DUT)

VERILOG_SOURCES += $(SRC_DIR)/$(DUT).v

# Module dependency stitching.
ifeq ($(DUT),control_unit)
VERILOG_SOURCES += $(SRC_DIR)/control_fsm.v
endif

ifeq ($(DUT),datapath)
VERILOG_SOURCES += $(SRC_DIR)/registers.v
VERILOG_SOURCES += $(SRC_DIR)/memory.v
VERILOG_SOURCES += $(SRC_DIR)/alu.v
endif

COMPILE_ARGS += -I$(SRC_DIR)
VERILOG_SOURCES += $(PWD)/$(TB).v

TOPLEVEL = $(TB)
COCOTB_TEST_MODULES = $(TEST)

include $(shell cocotb-config --makefiles)/Makefile.sim

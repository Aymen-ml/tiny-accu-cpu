# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def _cpu(dut):
    return dut.user_project.u_cpu_top


async def reset_dut(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1


async def run_instr(dut, instr):
    # Keep one instruction stable for a full fetch/execute pair.
    dut.ui_in.value = instr
    await ClockCycles(dut.clk, 2)


def pc_from_debug(dut):
    return int(dut.uio_out.value) & 0x0F


def fetch_from_debug(dut):
    return (int(dut.uio_out.value) >> 7) & 0x1


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start top-level ISA test")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    await reset_dut(dut)

    dut._log.info("Test simple external-instruction CPU")

    # LDI 5 -> ACC = 5
    await run_instr(dut, 0x05)
    assert int(dut.uo_out.value) == 5

    # STO 1 -> RAM[1] = 5
    await run_instr(dut, 0x31)
    assert int(dut.uo_out.value) == 5

    # LDI 3 -> ACC = 3
    await run_instr(dut, 0x03)
    assert int(dut.uo_out.value) == 3

    # ADD 1 -> ACC = 3 + RAM[1] = 8
    await run_instr(dut, 0x11)
    assert int(dut.uo_out.value) == 8

    # SUB 1 -> ACC = 8 - RAM[1] = 3
    await run_instr(dut, 0x21)
    assert int(dut.uo_out.value) == 3

    # LDM 1 -> ACC = RAM[1] = 5
    await run_instr(dut, 0x41)
    assert int(dut.uo_out.value) == 5

    # Create zero then verify conditional jump modifies PC nibble on debug bus.
    await run_instr(dut, 0x05)  # LDI 5
    await run_instr(dut, 0x21)  # SUB 1 -> ACC = 0
    assert int(dut.uo_out.value) == 0

    await run_instr(dut, 0x5A)  # JMPZ A
    assert (int(dut.uio_out.value) & 0x0F) == 0x0A

    # NOP keeps ACC unchanged.
    await run_instr(dut, 0xF0)
    assert int(dut.uo_out.value) == 0


@cocotb.test()
async def test_reset_and_phase_toggling(dut):
    """Critical block test: control_fsm phase behavior and reset defaults."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Reset defaults through top-level observability.
    assert int(dut.uo_out.value) == 0
    assert pc_from_debug(dut) == 0

    # Fetch flag should toggle each cycle in steady state.
    first = fetch_from_debug(dut)
    await ClockCycles(dut.clk, 1)
    second = fetch_from_debug(dut)
    await ClockCycles(dut.clk, 1)
    third = fetch_from_debug(dut)

    assert second != first
    assert third == first


@cocotb.test()
async def test_control_decode_signals(dut):
    """Critical block test: verify control_unit decode outputs in EXEC phase."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)
    cpu = _cpu(dut)

    # LDI: expect ACC write with immediate source in EXEC.
    dut.ui_in.value = 0x07
    await ClockCycles(dut.clk, 1)  # FETCH edge: IR latch
    assert int(cpu.acc_we) == 0
    await ClockCycles(dut.clk, 1)  # EXEC edge: decode active
    assert int(cpu.acc_we) == 1
    assert int(cpu.acc_src_sel) == 0b00

    # STO: expect data memory write enable.
    dut.ui_in.value = 0x31
    await ClockCycles(dut.clk, 2)
    assert int(cpu.data_we) == 1

    # SUB: expect ALU subtract mode with ACC write.
    dut.ui_in.value = 0x21
    await ClockCycles(dut.clk, 2)
    assert int(cpu.acc_we) == 1
    assert int(cpu.alu_sub) == 1


@cocotb.test()
async def test_leaf_modules_simple(dut):
    """Simple leaf checks via integration: ALU, memory, and register write-gating."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # ALU add path check: ACC should become 8.
    await run_instr(dut, 0x05)  # LDI 5
    await run_instr(dut, 0x31)  # STO 1
    await run_instr(dut, 0x03)  # LDI 3
    await run_instr(dut, 0x11)  # ADD 1 -> 8
    assert int(dut.uo_out.value) == 8

    # ALU sub path check: ACC should return to 3.
    await run_instr(dut, 0x21)  # SUB 1 -> 3
    assert int(dut.uo_out.value) == 3

    # Memory read path check.
    await run_instr(dut, 0x41)  # LDM 1 -> 5
    assert int(dut.uo_out.value) == 5

    # Register write gating via ena=0: state/output should hold.
    dut.ena.value = 0
    hold_acc = int(dut.uo_out.value)
    hold_pc = pc_from_debug(dut)
    await ClockCycles(dut.clk, 4)
    assert int(dut.uo_out.value) == hold_acc
    assert pc_from_debug(dut) == hold_pc

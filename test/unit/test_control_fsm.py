import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_control_fsm_toggle_and_hold(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)

    assert int(dut.fetch_phase.value) == 1
    assert int(dut.exec_phase.value) == 0

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)
    assert int(dut.fetch_phase.value) == 0
    assert int(dut.exec_phase.value) == 1

    await ClockCycles(dut.clk, 1)
    assert int(dut.fetch_phase.value) == 1
    assert int(dut.exec_phase.value) == 0

    dut.ena.value = 0
    prev_fetch = int(dut.fetch_phase.value)
    prev_exec = int(dut.exec_phase.value)
    await ClockCycles(dut.clk, 2)
    assert int(dut.fetch_phase.value) == prev_fetch
    assert int(dut.exec_phase.value) == prev_exec

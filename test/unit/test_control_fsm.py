import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer


@cocotb.test()
async def test_control_fsm_toggle_and_hold(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())
    
    # Allow clock to stabilize
    await Timer(1, unit="ns")

    dut.ena.value = 1
    dut.rst_n.value = 0
    await Timer(1, unit="ns")
    await ClockCycles(dut.clk, 3)  # Extra cycle to ensure reset is latched

    assert int(dut.fetch_phase.value) == 1
    assert int(dut.exec_phase.value) == 0

    dut.rst_n.value = 1
    await Timer(1, unit="ns")
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert int(dut.fetch_phase.value) == 0
    assert int(dut.exec_phase.value) == 1

    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert int(dut.fetch_phase.value) == 1
    assert int(dut.exec_phase.value) == 0

    dut.ena.value = 0
    prev_fetch = int(dut.fetch_phase.value)
    prev_exec = int(dut.exec_phase.value)
    await ClockCycles(dut.clk, 2)
    await Timer(1, unit="ns")
    assert int(dut.fetch_phase.value) == prev_fetch
    assert int(dut.exec_phase.value) == prev_exec

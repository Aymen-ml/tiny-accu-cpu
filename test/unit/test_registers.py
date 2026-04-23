import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_registers_reset_write_and_ena_hold(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.acc_we.value = 0
    dut.pc_we.value = 0
    dut.ir_we.value = 0
    dut.acc_d.value = 0
    dut.pc_d.value = 0
    dut.ir_d.value = 0
    await ClockCycles(dut.clk, 2)

    assert int(dut.acc_q.value) == 0
    assert int(dut.pc_q.value) == 0
    assert int(dut.ir_q.value) == 0

    dut.rst_n.value = 1
    dut.acc_we.value = 1
    dut.pc_we.value = 1
    dut.ir_we.value = 1
    dut.acc_d.value = 0xAA
    dut.pc_d.value = 0xC
    dut.ir_d.value = 0x5A
    await ClockCycles(dut.clk, 1)

    assert int(dut.acc_q.value) == 0xAA
    assert int(dut.pc_q.value) == 0xC
    assert int(dut.ir_q.value) == 0x5A

    dut.ena.value = 0
    dut.acc_d.value = 0x11
    dut.pc_d.value = 0x2
    dut.ir_d.value = 0x01
    await ClockCycles(dut.clk, 2)

    assert int(dut.acc_q.value) == 0xAA
    assert int(dut.pc_q.value) == 0xC
    assert int(dut.ir_q.value) == 0x5A

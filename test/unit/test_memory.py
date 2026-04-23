import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_memory_reset_write_read_and_ena_hold(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.data_we.value = 0
    dut.data_addr.value = 0
    dut.data_wdata.value = 0
    await ClockCycles(dut.clk, 2)

    for addr in (0, 5, 15):
        dut.data_addr.value = addr
        await Timer(1, unit="ns")
        assert int(dut.data_rdata.value) == 0

    dut.rst_n.value = 1
    dut.data_addr.value = 5
    dut.data_wdata.value = 0x3C
    dut.data_we.value = 1
    await ClockCycles(dut.clk, 1)

    dut.data_we.value = 0
    await Timer(1, unit="ns")
    assert int(dut.data_rdata.value) == 0x3C

    dut.ena.value = 0
    dut.data_we.value = 1
    dut.data_wdata.value = 0x55
    await ClockCycles(dut.clk, 1)
    dut.data_we.value = 0
    await Timer(1, unit="ns")
    assert int(dut.data_rdata.value) == 0x3C

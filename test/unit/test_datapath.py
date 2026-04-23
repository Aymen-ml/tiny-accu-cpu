import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_datapath_pc_and_acc_paths(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.instr_i.value = 0
    dut.acc_we_i.value = 0
    dut.pc_we_i.value = 0
    dut.ir_we_i.value = 0
    dut.data_we_i.value = 0
    dut.alu_sub_i.value = 0
    dut.acc_src_sel_i.value = 0b11
    dut.pc_load_operand_i.value = 0
    await ClockCycles(dut.clk, 2)

    assert int(dut.pc_o.value) == 0
    assert int(dut.acc_o.value) == 0

    dut.rst_n.value = 1

    # Latch IR with operand A and increment PC.
    dut.instr_i.value = 0x0A
    dut.ir_we_i.value = 1
    dut.pc_we_i.value = 1
    dut.pc_load_operand_i.value = 0
    await ClockCycles(dut.clk, 1)
    assert int(dut.pc_o.value) == 1
    assert int(dut.operand_o.value) == 0xA

    # ACC immediate path should use operand from IR.
    dut.ir_we_i.value = 0
    dut.pc_we_i.value = 0
    dut.acc_we_i.value = 1
    dut.acc_src_sel_i.value = 0b00
    await ClockCycles(dut.clk, 1)
    assert int(dut.acc_o.value) == 0x0A

    # Store ACC to RAM[operand] and read back via memory source.
    dut.acc_we_i.value = 0
    dut.data_we_i.value = 1
    await ClockCycles(dut.clk, 1)

    dut.data_we_i.value = 0
    dut.acc_we_i.value = 1
    dut.acc_src_sel_i.value = 0b10
    await ClockCycles(dut.clk, 1)
    assert int(dut.acc_o.value) == 0x0A

    # Absolute PC load from operand.
    dut.acc_we_i.value = 0
    dut.pc_we_i.value = 1
    dut.pc_load_operand_i.value = 1
    await ClockCycles(dut.clk, 1)
    assert int(dut.pc_o.value) == 0xA

    # Ena hold check.
    dut.ena.value = 0
    hold_pc = int(dut.pc_o.value)
    await ClockCycles(dut.clk, 2)
    assert int(dut.pc_o.value) == hold_pc

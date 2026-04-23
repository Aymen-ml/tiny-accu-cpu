import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


OP_LDI = 0x0
OP_SUB = 0x2
OP_STO = 0x3
OP_JMPZ = 0x5


@cocotb.test()
async def test_control_unit_decode_and_jump_gate(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.opcode_i.value = 0
    dut.acc_zero_i.value = 0
    await ClockCycles(dut.clk, 2)

    assert int(dut.fetch_phase_o.value) == 1
    assert int(dut.exec_phase_o.value) == 0

    dut.rst_n.value = 1

    # FETCH phase outputs.
    await Timer(1, unit="ns")
    assert int(dut.ir_we_o.value) == 1
    assert int(dut.pc_we_o.value) == 1

    # Enter EXEC and test LDI decode.
    dut.opcode_i.value = OP_LDI
    await ClockCycles(dut.clk, 1)
    await Timer(1, unit="ns")
    assert int(dut.exec_phase_o.value) == 1
    assert int(dut.acc_we_o.value) == 1
    assert int(dut.acc_src_sel_o.value) == 0b00

    # Next EXEC: SUB decode.
    await ClockCycles(dut.clk, 1)  # back to fetch
    dut.opcode_i.value = OP_SUB
    await ClockCycles(dut.clk, 1)  # exec
    await Timer(1, unit="ns")
    assert int(dut.acc_we_o.value) == 1
    assert int(dut.alu_sub_o.value) == 1

    # Next EXEC: STO decode.
    await ClockCycles(dut.clk, 1)
    dut.opcode_i.value = OP_STO
    await ClockCycles(dut.clk, 1)
    await Timer(1, unit="ns")
    assert int(dut.data_we_o.value) == 1

    # Next EXEC: JMPZ taken.
    await ClockCycles(dut.clk, 1)
    dut.opcode_i.value = OP_JMPZ
    dut.acc_zero_i.value = 1
    await ClockCycles(dut.clk, 1)
    await Timer(1, unit="ns")
    assert int(dut.pc_we_o.value) == 1
    assert int(dut.pc_load_operand_o.value) == 1

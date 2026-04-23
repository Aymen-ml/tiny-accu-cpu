import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_alu_add_sub(dut):
    dut.sub_i.value = 0
    dut.acc_i.value = 3
    dut.mem_i.value = 5
    await Timer(1, unit="ns")
    assert int(dut.result_o.value) == 8

    dut.sub_i.value = 1
    dut.acc_i.value = 8
    dut.mem_i.value = 5
    await Timer(1, unit="ns")
    assert int(dut.result_o.value) == 3

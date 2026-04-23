`default_nettype none
`timescale 1ns / 1ps

module tb_datapath;
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] instr_i;
  reg acc_we_i;
  reg pc_we_i;
  reg ir_we_i;
  reg data_we_i;
  reg alu_sub_i;
  reg [1:0] acc_src_sel_i;
  reg pc_load_operand_i;
  wire [7:0] acc_o;
  wire [3:0] pc_o;
  wire [3:0] opcode_o;
  wire [3:0] operand_o;
  wire acc_zero_o;

  datapath u_dut (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .instr_i(instr_i),
      .acc_we_i(acc_we_i),
      .pc_we_i(pc_we_i),
      .ir_we_i(ir_we_i),
      .data_we_i(data_we_i),
      .alu_sub_i(alu_sub_i),
      .acc_src_sel_i(acc_src_sel_i),
      .pc_load_operand_i(pc_load_operand_i),
      .acc_o(acc_o),
      .pc_o(pc_o),
      .opcode_o(opcode_o),
      .operand_o(operand_o),
      .acc_zero_o(acc_zero_o)
  );
endmodule

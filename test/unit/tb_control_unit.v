`default_nettype none
`timescale 1ns / 1ps

module tb_control_unit;
  reg clk;
  reg rst_n;
  reg ena;
  reg [3:0] opcode_i;
  reg acc_zero_i;
  wire fetch_phase_o;
  wire exec_phase_o;
  wire acc_we_o;
  wire pc_we_o;
  wire ir_we_o;
  wire data_we_o;
  wire alu_sub_o;
  wire [1:0] acc_src_sel_o;
  wire pc_load_operand_o;

  control_unit u_dut (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .opcode_i(opcode_i),
      .acc_zero_i(acc_zero_i),
      .fetch_phase_o(fetch_phase_o),
      .exec_phase_o(exec_phase_o),
      .acc_we_o(acc_we_o),
      .pc_we_o(pc_we_o),
      .ir_we_o(ir_we_o),
      .data_we_o(data_we_o),
      .alu_sub_o(alu_sub_o),
      .acc_src_sel_o(acc_src_sel_o),
      .pc_load_operand_o(pc_load_operand_o)
  );
endmodule

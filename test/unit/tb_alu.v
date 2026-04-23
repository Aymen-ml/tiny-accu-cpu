`default_nettype none
`timescale 1ns / 1ps

module tb_alu;
  reg sub_i;
  reg [7:0] acc_i;
  reg [7:0] mem_i;
  wire [7:0] result_o;

  alu u_dut (
      .sub_i(sub_i),
      .acc_i(acc_i),
      .mem_i(mem_i),
      .result_o(result_o)
  );
endmodule

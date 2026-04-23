`default_nettype none
`timescale 1ns / 1ps

module tb_registers;
  reg clk;
  reg rst_n;
  reg ena;
  reg acc_we;
  reg pc_we;
  reg ir_we;
  reg [7:0] acc_d;
  reg [3:0] pc_d;
  reg [7:0] ir_d;
  wire [7:0] acc_q;
  wire [3:0] pc_q;
  wire [7:0] ir_q;

  registers u_dut (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .acc_we(acc_we),
      .pc_we(pc_we),
      .ir_we(ir_we),
      .acc_d(acc_d),
      .pc_d(pc_d),
      .ir_d(ir_d),
      .acc_q(acc_q),
      .pc_q(pc_q),
      .ir_q(ir_q)
  );
endmodule

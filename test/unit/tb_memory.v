`default_nettype none
`timescale 1ns / 1ps

module tb_memory;
  reg clk;
  reg rst_n;
  reg ena;
  reg [3:0] data_addr;
  reg [7:0] data_wdata;
  reg data_we;
  wire [7:0] data_rdata;

  memory u_dut (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .data_addr(data_addr),
      .data_wdata(data_wdata),
      .data_we(data_we),
      .data_rdata(data_rdata)
  );
endmodule

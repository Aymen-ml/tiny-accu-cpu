/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Tiny data RAM (16 x 8) for the teaching CPU.
module memory (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [3:0] data_addr,
    input  wire [7:0] data_wdata,
    input  wire       data_we,
    output reg  [7:0] data_rdata
);

  reg [7:0] data_mem [0:15];
  integer idx;

  always @* begin
    data_rdata = data_mem[data_addr];
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      for (idx = 0; idx < 16; idx = idx + 1) begin
        data_mem[idx] <= 8'h00;
      end
    end else if (ena && data_we) begin
      data_mem[data_addr] <= data_wdata;
    end
  end

endmodule
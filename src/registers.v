/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Holds the accumulator, small program counter, and instruction register.
module registers (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire       acc_we,
    input  wire       pc_we,
    input  wire       ir_we,
    input  wire [7:0] acc_d,
    input  wire [3:0] pc_d,
    input  wire [7:0] ir_d,
    output reg  [7:0] acc_q,
    output reg  [3:0] pc_q,
    output reg  [7:0] ir_q
);

  always @(posedge clk) begin
    if (!rst_n) begin
      acc_q <= 8'h00;
      pc_q  <= 4'h0;
      ir_q  <= 8'h00;
    end else if (ena) begin
      if (acc_we) begin
        acc_q <= acc_d;
      end
      if (pc_we) begin
        pc_q <= pc_d;
      end
      if (ir_we) begin
        ir_q <= ir_d;
      end
    end
  end

endmodule
/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Small combinational ALU used by the accumulator CPU.
module alu (
    input  wire       sub_i,
    input  wire [7:0] acc_i,
    input  wire [7:0] mem_i,
    output reg  [7:0] result_o
);

  always @* begin
    if (sub_i) begin
      result_o = acc_i - mem_i;
    end else begin
      result_o = acc_i + mem_i;
    end
  end

endmodule
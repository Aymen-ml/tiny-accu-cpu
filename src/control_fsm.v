/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Two-state fetch/execute machine for the teaching CPU.
module control_fsm (
    input  wire clk,
    input  wire rst_n,
    input  wire ena,
    output reg  fetch_phase,
    output reg  exec_phase
);

  reg state_q;

  always @(posedge clk) begin
    if (!rst_n) begin
      state_q <= 1'b0;
    end else if (ena) begin
      state_q <= ~state_q;
    end
  end

  always @* begin
    fetch_phase = ~state_q;
    exec_phase  = state_q;
  end

endmodule
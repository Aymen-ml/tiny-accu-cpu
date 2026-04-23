`default_nettype none
`timescale 1ns / 1ps

module tb_control_fsm;
  reg clk;
  reg rst_n;
  reg ena;
  wire fetch_phase;
  wire exec_phase;

  control_fsm u_dut (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .fetch_phase(fetch_phase),
      .exec_phase(exec_phase)
  );
endmodule

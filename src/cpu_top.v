/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Top-level teaching CPU.
// This module now only integrates the control path and datapath.
module cpu_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  wire fetch_phase;
  wire exec_phase;

  wire [7:0] acc_q;
  wire [3:0] pc_q;
  wire [3:0] opcode;
  wire [3:0] operand;
  wire acc_zero;

  wire acc_we;
  wire pc_we;
  wire ir_we;
  wire data_we;
  wire alu_sub;
  wire [1:0] acc_src_sel;
  wire pc_load_operand;

  control_unit u_control_unit (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .opcode_i(opcode),
      .acc_zero_i(acc_zero),
      .fetch_phase_o(fetch_phase),
      .exec_phase_o(exec_phase),
      .acc_we_o(acc_we),
      .pc_we_o(pc_we),
      .ir_we_o(ir_we),
      .data_we_o(data_we),
      .alu_sub_o(alu_sub),
      .acc_src_sel_o(acc_src_sel),
      .pc_load_operand_o(pc_load_operand)
  );

  datapath u_datapath (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .instr_i(ui_in),
      .acc_we_i(acc_we),
      .pc_we_i(pc_we),
      .ir_we_i(ir_we),
      .data_we_i(data_we),
      .alu_sub_i(alu_sub),
      .acc_src_sel_i(acc_src_sel),
      .pc_load_operand_i(pc_load_operand),
      .acc_o(acc_q),
      .pc_o(pc_q),
      .opcode_o(opcode),
      .operand_o(operand),
      .acc_zero_o(acc_zero)
  );

  // Output mapping:
  // - uo_out: accumulator
  // - uio_out: debug bus [phase | opcode(3b) | pc(4b)]
  assign uo_out  = acc_q;
  assign uio_out = {fetch_phase, opcode[2:0], pc_q[3:0]};
  // Keep uio as outputs for visibility; uio_in remains free for future labs.
  assign uio_oe  = 8'hff;

  wire _unused = &{uio_in, 1'b0};

endmodule
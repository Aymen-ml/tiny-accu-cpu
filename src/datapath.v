/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Datapath for the teaching CPU.
// Contains registers, ALU, and RAM, plus local mux logic for writeback.
module datapath (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [7:0] instr_i,
    input  wire       acc_we_i,
    input  wire       pc_we_i,
    input  wire       ir_we_i,
    input  wire       data_we_i,
    input  wire       alu_sub_i,
    input  wire [1:0] acc_src_sel_i,
    input  wire       pc_load_operand_i,
    output wire [7:0] acc_o,
    output wire [3:0] pc_o,
    output wire [3:0] opcode_o,
    output wire [3:0] operand_o,
    output wire       acc_zero_o
);

  wire [7:0] acc_q;
  wire [3:0] pc_q;
  wire [7:0] ir_q;
  wire [7:0] data_rdata;
  wire [7:0] alu_result;

  wire [3:0] opcode = ir_q[7:4];
  wire [3:0] operand = ir_q[3:0];

  reg [7:0] acc_d;
  wire [3:0] pc_d = pc_load_operand_i ? operand : (pc_q + 4'd1);

  always @* begin
    case (acc_src_sel_i)
      2'b00: acc_d = {4'b0000, operand}; // immediate
      2'b01: acc_d = alu_result;         // ALU result
      2'b10: acc_d = data_rdata;         // RAM read
      default: acc_d = acc_q;            // hold
    endcase
  end

  registers u_registers (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .acc_we(acc_we_i),
      .pc_we(pc_we_i),
      .ir_we(ir_we_i),
      .acc_d(acc_d),
      .pc_d(pc_d),
      .ir_d(instr_i),
      .acc_q(acc_q),
      .pc_q(pc_q),
      .ir_q(ir_q)
  );

  memory u_memory (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .data_addr(operand),
      .data_wdata(acc_q),
      .data_we(data_we_i),
      .data_rdata(data_rdata)
  );

  alu u_alu (
      .sub_i(alu_sub_i),
      .acc_i(acc_q),
      .mem_i(data_rdata),
      .result_o(alu_result)
  );

  assign acc_o      = acc_q;
  assign pc_o       = pc_q;
  assign opcode_o   = opcode;
  assign operand_o  = operand;
  assign acc_zero_o = (acc_q == 8'h00);

endmodule
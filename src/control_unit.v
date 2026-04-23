/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Control unit for the teaching CPU.
// Generates all write-enables and select lines from opcode and phase.
module control_unit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [3:0] opcode_i,
    input  wire       acc_zero_i,
    output wire       fetch_phase_o,
    output wire       exec_phase_o,
    output reg        acc_we_o,
    output reg        pc_we_o,
    output reg        ir_we_o,
    output reg        data_we_o,
    output reg        alu_sub_o,
    output reg  [1:0] acc_src_sel_o,
    output reg        pc_load_operand_o
);

  localparam [3:0] OP_LDI  = 4'h0;
  localparam [3:0] OP_ADD  = 4'h1;
  localparam [3:0] OP_SUB  = 4'h2;
  localparam [3:0] OP_STO  = 4'h3;
  localparam [3:0] OP_LDM  = 4'h4;
  localparam [3:0] OP_JMPZ = 4'h5;
  localparam [3:0] OP_NOP  = 4'hF;

  wire fetch_phase;
  wire exec_phase;

  control_fsm u_control_fsm (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .fetch_phase(fetch_phase),
      .exec_phase(exec_phase)
  );

  assign fetch_phase_o = fetch_phase;
  assign exec_phase_o  = exec_phase;

  always @* begin
    acc_we_o          = 1'b0;
    pc_we_o           = 1'b0;
    ir_we_o           = 1'b0;
    data_we_o         = 1'b0;
    alu_sub_o         = 1'b0;
    acc_src_sel_o     = 2'b11; // hold
    pc_load_operand_o = 1'b0;

    if (fetch_phase) begin
      ir_we_o = 1'b1;
      pc_we_o = 1'b1;
    end else if (exec_phase) begin
      case (opcode_i)
        OP_LDI: begin
          acc_we_o      = 1'b1;
          acc_src_sel_o = 2'b00; // immediate
        end

        OP_ADD: begin
          acc_we_o      = 1'b1;
          acc_src_sel_o = 2'b01; // ALU add
        end

        OP_SUB: begin
          acc_we_o      = 1'b1;
          acc_src_sel_o = 2'b01; // ALU sub
          alu_sub_o     = 1'b1;
        end

        OP_STO: begin
          data_we_o = 1'b1;
        end

        OP_LDM: begin
          acc_we_o      = 1'b1;
          acc_src_sel_o = 2'b10; // memory read data
        end

        OP_JMPZ: begin
          if (acc_zero_i) begin
            pc_we_o           = 1'b1;
            pc_load_operand_o = 1'b1;
          end
        end

        OP_NOP: begin
          // Explicit NOP for teaching clarity.
        end

        default: begin
          // Unsupported opcodes act as NOP.
        end
      endcase
    end
  end

endmodule
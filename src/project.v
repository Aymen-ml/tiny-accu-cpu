/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns/1ps

module tt_um_alessio8132 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
reg [3:0] pc; //4-bit Program Counter
reg [3:0] acc; //4-Bit accumulator
reg [3:0] output_register; //4-bit output register
reg [3:0] ram [0:15]; // 16 memory locations, each 4 bits wide
reg [4:0] i; // 5 bits allows counting from 0 to 31
wire is_zero = (acc == 4'b0000); // Check if ACC is zero
always @(posedge clk) begin
        if (!rst_n) begin
            pc  <= 4'b0000;
            acc <= 4'b0000;
            output_register <= 4'b0000;
            
            // Clear RAM on reset
            for (i = 5'b00000; i < 5'b10000; i = i + 5'b00001) begin
                ram[i] <= 4'b0000;
            end
        end else begin
            if (ui_in[7:4] == 4'b1100) begin
                pc <= ui_in[3:0]; // Jump to the address in the bottom 4 bits
            end else if(ui_in[7:4] == 4'b1111) begin
                pc <= pc; // HALT: Don't move the PC
            end else if (ui_in[7:4] == 4'b0100 && acc == 4'b0000) begin
                pc <= ui_in[3:0]; // Jump to address in the bottom 4 bits if ACC is zero
            end else begin
                pc <= pc + 1;     // Otherwise, just keep counting
            end

            // DECODE & EXECUTE
            case (ui_in[7:4])      // Look at the top 4 bits
                4'b0001: acc <= ui_in[3:0];       // LDA: Load bottom 4 bits into acc
                4'b0010: acc <= acc + ram[ui_in[3:0]]; // ADD: Add value from RAM address ui_in[3:0] to acc
                4'b0011: acc <= acc - ram[ui_in[3:0]]; // SUB: Subtract value from RAM address ui_in[3:0] from ACC
                4'b0110: acc <= acc << 1;         // SHL: Shift left 
                4'b0111: acc <= acc ^ ram[ui_in[3:0]]; // XOR: bitwise exclusive or with value from RAM address ui_in[3:0]
                4'b1011: acc <= acc & ram[ui_in[3:0]]; // AND: bitwise and with value from RAM address ui_in[3:0]
                4'b1101: acc <= acc | ram[ui_in[3:0]]; // OR: bitwise or with value from RAM address ui_in[3:0]
                4'b1000: output_register <= acc;  // OUT: output current ACC content
                //4'b1111: pc <= pc;               // HALT: Don't move the PC
                //Internal RAM STORE
                4'b0101: begin                    
                    ram[ui_in[3:0]] <= acc;       // Write ACC to RAM at address ui_in[3:0]
                end
                
                //Internal RAM LOAD
                4'b1010: begin                    
                    acc <= ram[ui_in[3:0]];       // Read RAM at address ui_in[3:0] into ACC
                end
                default: begin
                    acc <= acc;
                    output_register <= output_register;
                end              
            endcase
        end
    end



assign uo_out = {pc, output_register};
assign uio_out = 8'b0000_0000; // Not using IO outputs
assign uio_oe  = 8'b0000_0000; // Not using IOs, so set all to input mode


wire _unused = &{ena, uio_in, 1'b0};

endmodule
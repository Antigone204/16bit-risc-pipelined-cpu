`timescale 1ns / 1ps

// ============================================================================
// Module: pc_reg
// Description: Program Counter register with enable (PC_Write) and sync/async reset
// ============================================================================
module pc_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pc_write,     // 1: Normal update, 0: Freeze/Stall
    input  wire [15:0] pc_next,
    output reg  [15:0] pc_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 16'h0000;
        end else if (pc_write) begin
            pc_out <= pc_next;
        end
        // when pc_write == 0, hold pc_out (Stall)
    end

endmodule

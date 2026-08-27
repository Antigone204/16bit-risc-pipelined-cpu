`timescale 1ns / 1ps

// ============================================================================
// Module: alu
// Description: 16-bit Arithmetic and Logic Unit
// Operations: PASS (B), ADD, SUB, AND, OR
// ============================================================================
module alu (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [2:0]  alu_op,
    output reg  [15:0] result,
    output wire        zero
);

    always @(*) begin
        case (alu_op)
            3'b000: result = b;          // PASS B
            3'b001: result = a + b;      // ADD
            3'b010: result = a - b;      // SUB
            3'b011: result = a & b;      // AND
            3'b100: result = a | b;      // OR
            default: result = 16'h0000;
        endcase
    end

    assign zero = (result == 16'h0000);

endmodule

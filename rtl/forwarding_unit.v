`timescale 1ns / 1ps

// ============================================================================
// Module: forwarding_unit
// Description: Sits in EX stage to resolve RAW (Read-After-Write) data hazards.
//              Generates ForwardA and ForwardB selection signals for 3-to-1 MUXes.
//
// ForwardA / ForwardB Encoding:
//   2'b00: No forwarding (use ID/EX operand data)
//   2'b01: Forward from EX/MEM stage (ALU Result)
//   2'b10: Forward from MEM/WB stage (Writeback Data)
// Priority: EX/MEM stage takes precedence over MEM/WB stage.
// ============================================================================
module forwarding_unit (
    input  wire [1:0] id_ex_rd_addr,    // Source operand 1 (Rd address in ID/EX)
    input  wire [1:0] id_ex_rs_addr,    // Source operand 2 (Rs address in ID/EX)
    
    input  wire       ex_mem_reg_write, // EX/MEM RegWrite control signal
    input  wire [1:0] ex_mem_rd_addr,   // EX/MEM destination register address
    
    input  wire       mem_wb_reg_write, // MEM/WB RegWrite control signal
    input  wire [1:0] mem_wb_rd_addr,   // MEM/WB destination register address
    
    output reg  [1:0] forward_a,        // Controls MUX_A_fwd
    output reg  [1:0] forward_b         // Controls MUX_B_fwd
);

    // ForwardA: Checks operand Rd of ID/EX against EX/MEM and MEM/WB destinations
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd_addr == id_ex_rd_addr)) begin
            forward_a = 2'b01; // Forward from EX/MEM
        end else if (mem_wb_reg_write && (mem_wb_rd_addr == id_ex_rd_addr)) begin
            forward_a = 2'b10; // Forward from MEM/WB
        end else begin
            forward_a = 2'b00; // No forwarding
        end
    end

    // ForwardB: Checks operand Rs of ID/EX against EX/MEM and MEM/WB destinations
    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd_addr == id_ex_rs_addr)) begin
            forward_b = 2'b01; // Forward from EX/MEM
        end else if (mem_wb_reg_write && (mem_wb_rd_addr == id_ex_rs_addr)) begin
            forward_b = 2'b10; // Forward from MEM/WB
        end else begin
            forward_b = 2'b00; // No forwarding
        end
    end

endmodule

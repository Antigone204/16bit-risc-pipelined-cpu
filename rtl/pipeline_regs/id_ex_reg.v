`timescale 1ns / 1ps

// ============================================================================
// Module: id_ex_reg
// Description: ID/EX Pipeline Register with synchronous Bubble/Clear capability
// ============================================================================
module id_ex_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        bubble,          // Injects NOP (clears control signals)
    
    // Control signals from ID stage
    input  wire        alu_a_src_in,
    input  wire        alu_src_in,
    input  wire [2:0]  alu_op_in,
    input  wire        mem_write_in,
    input  wire        mem_read_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    
    // Data & Register addresses from ID stage
    input  wire [15:0] rd_data_in,
    input  wire [15:0] rs_data_in,
    input  wire [15:0] imm_in,
    input  wire [1:0]  rd_addr_in,
    input  wire [1:0]  rs_addr_in,
    
    // Control signals to EX stage
    output reg         alu_a_src_out,
    output reg         alu_src_out,
    output reg  [2:0]  alu_op_out,
    output reg         mem_write_out,
    output reg         mem_read_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    
    // Data & Register addresses to EX stage
    output reg  [15:0] rd_data_out,
    output reg  [15:0] rs_data_out,
    output reg  [15:0] imm_out,
    output reg  [1:0]  rd_addr_out,
    output reg  [1:0]  rs_addr_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || bubble) begin
            // Clear control signals to 0 (effectively a NOP bubble)
            alu_a_src_out  <= 1'b0;
            alu_src_out    <= 1'b0;
            alu_op_out     <= 3'b000;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_out  <= 1'b0;
            
            rd_data_out    <= 16'h0000;
            rs_data_out    <= 16'h0000;
            imm_out        <= 16'h0000;
            rd_addr_out    <= 2'b00;
            rs_addr_out    <= 2'b00;
        end else begin
            alu_a_src_out  <= alu_a_src_in;
            alu_src_out    <= alu_src_in;
            alu_op_out     <= alu_op_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
            
            rd_data_out    <= rd_data_in;
            rs_data_out    <= rs_data_in;
            imm_out        <= imm_in;
            rd_addr_out    <= rd_addr_in;
            rs_addr_out    <= rs_addr_in;
        end
    end

endmodule

`timescale 1ns / 1ps

// ============================================================================
// Module: ex_mem_reg
// Description: EX/MEM Pipeline Register
// ============================================================================
module ex_mem_reg (
    input  wire        clk,
    input  wire        rst_n,
    
    // Control signals from EX stage
    input  wire        mem_write_in,
    input  wire        mem_read_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    
    // Data from EX stage
    input  wire [15:0] alu_result_in,
    input  wire [15:0] store_data_in,   // Forwarded Rd_data for ST instruction
    input  wire [1:0]  rd_addr_in,
    
    // Control signals to MEM stage
    output reg         mem_write_out,
    output reg         mem_read_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    
    // Data to MEM stage
    output reg  [15:0] alu_result_out,
    output reg  [15:0] store_data_out,
    output reg  [1:0]  rd_addr_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_to_reg_out <= 1'b0;
            reg_write_out  <= 1'b0;
            
            alu_result_out <= 16'h0000;
            store_data_out <= 16'h0000;
            rd_addr_out    <= 2'b00;
        end else begin
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out  <= reg_write_in;
            
            alu_result_out <= alu_result_in;
            store_data_out <= store_data_in;
            rd_addr_out    <= rd_addr_in;
        end
    end

endmodule

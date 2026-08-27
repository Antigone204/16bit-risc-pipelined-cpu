`timescale 1ns / 1ps

// ============================================================================
// Module: mem_wb_reg
// Description: MEM/WB Pipeline Register
// ============================================================================
module mem_wb_reg (
    input  wire        clk,
    input  wire        rst_n,
    
    // Control signals from MEM stage
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    
    // Data from MEM stage
    input  wire [15:0] alu_result_in,
    input  wire [15:0] mem_read_data_in,
    input  wire [1:0]  rd_addr_in,
    
    // Control signals to WB stage
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    
    // Data to WB stage
    output reg  [15:0] alu_result_out,
    output reg  [15:0] mem_read_data_out,
    output reg  [1:0]  rd_addr_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_to_reg_out    <= 1'b0;
            reg_write_out     <= 1'b0;
            
            alu_result_out    <= 16'h0000;
            mem_read_data_out <= 16'h0000;
            rd_addr_out       <= 2'b00;
        end else begin
            mem_to_reg_out    <= mem_to_reg_in;
            reg_write_out     <= reg_write_in;
            
            alu_result_out    <= alu_result_in;
            mem_read_data_out <= mem_read_data_in;
            rd_addr_out       <= rd_addr_in;
        end
    end

endmodule

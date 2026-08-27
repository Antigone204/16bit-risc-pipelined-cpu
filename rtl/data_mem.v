`timescale 1ns / 1ps

// ============================================================================
// Module: data_mem
// Description: 16-bit Data Memory (RAM)
// ============================================================================
module data_mem (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] addr,
    input  wire [15:0] write_data,
    input  wire        mem_write,
    input  wire        mem_read,
    output wire [15:0] read_data
);

    reg [15:0] ram [0:255];
    integer i;

    // Synchronous write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 256; i = i + 1) begin
                ram[i] <= 16'h0000;
            end
        end else if (mem_write) begin
            ram[addr[7:0]] <= write_data;
        end
    end

    // Asynchronous read (or read when mem_read is asserted)
    assign read_data = (mem_read) ? ram[addr[7:0]] : 16'h0000;

endmodule

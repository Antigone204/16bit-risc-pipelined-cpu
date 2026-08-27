`timescale 1ns / 1ps

// ============================================================================
// Module: reg_file
// Description: 4 x 16-bit General Purpose Register File (R0 - R3)
// Features: Dual combinational read ports, single synchronous write port
// ============================================================================
module reg_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  r_addr1,     // Rd address for read
    input  wire [1:0]  r_addr2,     // Rs address for read
    input  wire [1:0]  w_addr,      // Write destination address
    input  wire [15:0] w_data,      // Write data
    input  wire        w_en,        // RegWrite enable
    output wire [15:0] r_data1,     // Rd read data
    output wire [15:0] r_data2,     // Rs read data
    // Debug output to probe registers
    output wire [15:0] r0,
    output wire [15:0] r1,
    output wire [15:0] r2,
    output wire [15:0] r3
);

    reg [15:0] registers [0:3];
    integer i;

    // Synchronous write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1) begin
                registers[i] <= 16'h0000;
            end
        end else if (w_en) begin
            registers[w_addr] <= w_data;
        end
    end

    // Combinational read with internal forwarding (write-through for same-cycle WB)
    assign r_data1 = (w_en && (w_addr == r_addr1)) ? w_data : registers[r_addr1];
    assign r_data2 = (w_en && (w_addr == r_addr2)) ? w_data : registers[r_addr2];

    // Debug output
    assign r0 = registers[0];
    assign r1 = registers[1];
    assign r2 = registers[2];
    assign r3 = registers[3];

endmodule

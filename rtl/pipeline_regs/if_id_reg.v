`timescale 1ns / 1ps

// ============================================================================
// Module: if_id_reg
// Description: IF/ID Pipeline Register with Synchronous Flush and Write Enable
// Priority: Flush > Write Enable (Flush clears to 0/NOP, Write=0 holds value)
// ============================================================================
module if_id_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        write_en,  // From HDU: 0 freezes IF/ID (stall)
    input  wire        flush,     // From HDU: 1 clears IF/ID (Jump branch flush)
    input  wire [15:0] instr_in,
    input  wire [15:0] pc_in,
    output reg  [15:0] instr_out,
    output reg  [15:0] pc_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_out <= 16'h0000;
            pc_out    <= 16'h0000;
        end else if (flush) begin
            // Flush priority over write: replace invalid instruction with NOP (16'h0000)
            instr_out <= 16'h0000;
            pc_out    <= 16'h0000;
        end else if (write_en) begin
            // Normal latching
            instr_out <= instr_in;
            pc_out    <= pc_in;
        end
        // When write_en == 0 and flush == 0, hold current contents
    end

endmodule

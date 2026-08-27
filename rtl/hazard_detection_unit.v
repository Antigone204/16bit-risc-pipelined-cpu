`timescale 1ns / 1ps

// ============================================================================
// Module: hazard_detection_unit (HDU)
// Description: Detects Load-Use hazards and coordinates pipeline stalls/bubbles,
//              as well as control hazard flushes upon JUMP execution.
// ============================================================================
module hazard_detection_unit (
    // Inputs from ID/EX register
    input  wire        id_ex_mem_read,
    input  wire [1:0]  id_ex_rd_addr,
    
    // Inputs from IF/ID instruction (current instruction being decoded)
    input  wire [1:0]  if_id_rd_addr,
    input  wire [1:0]  if_id_rs_addr,
    
    // Input from Control Unit (ID stage)
    input  wire        jump,
    
    // Outputs
    output reg         pc_write,       // 1: Update PC, 0: Stall/Freeze PC
    output reg         if_id_write,    // 1: Update IF/ID, 0: Stall/Freeze IF/ID
    output reg         id_ex_bubble,   // 1: Inject NOP bubble into ID/EX
    output wire        if_id_flush     // 1: Flush IF/ID instruction (on Jump)
);

    // Jump flush control line directly connected
    assign if_id_flush = jump;

    // Load-Use Hazard Detection:
    // When instruction currently in EX is a Load (id_ex_mem_read == 1)
    // and its destination register is read by the instruction currently in ID
    always @(*) begin
        if (id_ex_mem_read && 
            ((id_ex_rd_addr == if_id_rd_addr) || (id_ex_rd_addr == if_id_rs_addr))) begin
            // Load-Use Hazard detected: Stall pipeline by 1 cycle
            pc_write     = 1'b0; // Freeze PC
            if_id_write  = 1'b0; // Freeze IF/ID
            id_ex_bubble = 1'b1; // Clear control signals into ID/EX (insert bubble)
        end else begin
            // Normal operation
            pc_write     = 1'b1;
            if_id_write  = 1'b1;
            id_ex_bubble = 1'b0;
        end
    end

endmodule

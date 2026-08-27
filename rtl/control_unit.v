`timescale 1ns / 1ps

// ============================================================================
// Module: control_unit
// Description: Main Control Unit decoding 4-bit Opcode to control signals
// ============================================================================
module control_unit (
    input  wire [3:0]  opcode,
    output reg         alu_a_src,    // 0: Rd_data, 1: Rs_data
    output reg         alu_src,      // 0: Rs_data, 1: Imm/Offset
    output reg  [2:0]  alu_op,       // 000: PASS, 001: ADD, 010: SUB, 011: AND, 100: OR
    output reg         mem_write,    // 1: Write to Data Memory (ST)
    output reg         mem_read,     // 1: Read from Data Memory (LD)
    output reg         mem_to_reg,   // 1: WB from Data Mem, 0: WB from ALU
    output reg         reg_write,    // 1: Enable write to register file
    output reg         jump          // 1: Unconditional Jump
);

    always @(*) begin
        // Default values
        alu_a_src  = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 3'b000;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
        jump       = 1'b0;

        case (opcode)
            4'b0000: begin // mov Rd, #imm
                alu_a_src  = 1'b0;
                alu_src    = 1'b1;
                alu_op     = 3'b000; // PASS B (Imm)
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b0001: begin // mov Rd, Rs
                alu_a_src  = 1'b1;   // Rs
                alu_src    = 1'b0;   // Rs
                alu_op     = 3'b000; // PASS (from Rs)
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b0010: begin // add Rd, #imm
                alu_a_src  = 1'b0; // Rd
                alu_src    = 1'b1; // Imm
                alu_op     = 3'b001; // ADD
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b0011: begin // add Rd, Rs
                alu_a_src  = 1'b0; // Rd
                alu_src    = 1'b0; // Rs
                alu_op     = 3'b001; // ADD
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b0101: begin // sub Rd, Rs
                alu_a_src  = 1'b0; // Rd
                alu_src    = 1'b0; // Rs
                alu_op     = 3'b010; // SUB
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b0111: begin // and Rd, Rs
                alu_a_src  = 1'b0; // Rd
                alu_src    = 1'b0; // Rs
                alu_op     = 3'b011; // AND
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b1001: begin // or Rd, Rs
                alu_a_src  = 1'b0; // Rd
                alu_src    = 1'b0; // Rs
                alu_op     = 3'b100; // OR
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b1010: begin // jump #imm
                jump       = 1'b1;
                reg_write  = 1'b0;
                mem_write  = 1'b0;
                mem_read   = 1'b0;
            end

            4'b1100: begin // ld Rd, Rs, #off (Addr = Rs + off)
                alu_a_src  = 1'b1; // Rs
                alu_src    = 1'b1; // Offset
                alu_op     = 3'b001; // ADD for effective address
                mem_write  = 1'b0;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
                jump       = 1'b0;
            end

            4'b1101: begin // st Rd, Rs, #off (Addr = Rs + off, Data = Rd)
                alu_a_src  = 1'b1; // Rs
                alu_src    = 1'b1; // Offset
                alu_op     = 3'b001; // ADD for effective address
                mem_write  = 1'b1;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b0;
                jump       = 1'b0;
            end

            default: begin
                alu_a_src  = 1'b0;
                alu_src    = 1'b0;
                alu_op     = 3'b000;
                mem_write  = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b0;
                jump       = 1'b0;
            end
        endcase
    end

endmodule

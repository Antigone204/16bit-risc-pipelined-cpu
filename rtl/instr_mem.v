`timescale 1ns / 1ps

// ============================================================================
// Module: instr_mem
// Description: Instruction Memory (Word-addressed ROM/RAM)
// ============================================================================
module instr_mem (
    input  wire [15:0] addr,
    output wire [15:0] instr
);

    reg [15:0] mem [0:255];

    // Asynchronous read (or combinational read)
    assign instr = mem[addr[7:0]];

    // Internal initialization for simulation / synthesis default
    initial begin
        // Program example to test hazards, forwarding, load-use, jump flush
        // 0: mov R0, #5       (0000 00 00 00000101 -> 16'h0005) R0 = 5
        // 1: mov R1, #3       (0000 01 00 00000011 -> 16'h0403) R1 = 3
        // 2: add R0, R1       (0011 00 01 00000000 -> 16'h3100) R0 = 5 + 3 = 8 (RAW Forwarding)
        // 3: add R2, R0       (0011 10 00 00000000 -> 16'h3800) R2 = 0 + 8 = 8 (RAW Forwarding)
        // 4: st  R0, R1, #0   (1101 00 01 00000000 -> 16'hD100) Mem[3+0] = 8
        // 5: ld  R3, R1, #0   (1100 11 01 00000000 -> 16'hCD00) R3 = Mem[3] = 8
        // 6: add R3, #2       (0010 11 00 00000010 -> 16'h2C02) R3 = 8 + 2 = 10 (Load-Use Stall + Fwd)
        // 7: jump #10         (1010 00 00 00001010 -> 16'hA00A) Jump to 10 (Control Hazard Flush)
        // 8: add R0, #1       (16'h2001) -> Should be flushed!
        // 9: add R1, #1       (16'h2401) -> Should not execute!
        // 10: sub R3, R1      (0101 11 01 00000000 -> 16'h5D00) R3 = 10 - 3 = 7
        
        mem[0]  = 16'h0005; // mov R0, #5
        mem[1]  = 16'h0403; // mov R1, #3
        mem[2]  = 16'h3100; // add R0, R1
        mem[3]  = 16'h3800; // add R2, R0
        mem[4]  = 16'hD100; // st  R0, R1, #0
        mem[5]  = 16'hCD00; // ld  R3, R1, #0
        mem[6]  = 16'h2C02; // add R3, #2
        mem[7]  = 16'hA00A; // jump #10
        mem[8]  = 16'h2001; // add R0, #1 (Flushed)
        mem[9]  = 16'h2401; // add R1, #1 (Flushed/skipped)
        mem[10] = 16'h5D00; // sub R3, R1
    end

endmodule

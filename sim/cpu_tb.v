`timescale 1ns / 1ps

// ============================================================================
// Module: cpu_tb
// Description: Comprehensive Testbench for 16-Bit RISC Pipelined CPU
// ============================================================================
module cpu_tb;

    reg         clk;
    reg         rst_n;
    
    wire [15:0] pc_out;
    wire [15:0] if_id_instr_out;
    wire [15:0] alu_result_out;
    wire [15:0] wb_data_out;
    wire [15:0] r0, r1, r2, r3;

    // Instantiate DUT (Device Under Test)
    cpu_top u_cpu_top (
        .clk             (clk),
        .rst_n           (rst_n),
        .pc_out          (pc_out),
        .if_id_instr_out (if_id_instr_out),
        .alu_result_out  (alu_result_out),
        .wb_data_out     (wb_data_out),
        .r0              (r0),
        .r1              (r1),
        .r2              (r2),
        .r3              (r3)
    );

    // 50MHz Clock Generation (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Waveform dump for GTKWave / ModelSim / Vivado
        $dumpfile("cpu_pipeline.vcd");
        $dumpvars(0, cpu_tb);

        $display("==================================================================");
        $display("   16-Bit RISC 5-Stage Pipelined CPU Simulation Starting...      ");
        $display("==================================================================");

        // Initialize signals
        clk   = 0;
        rst_n = 0;

        // Apply Reset
        #25;
        rst_n = 1;
        $display("[Time %0t ns] Reset released. CPU execution begins.", $time);

        // Run simulation for 250ns
        #250;

        $display("==================================================================");
        $display("   Simulation Finished. Final Register File State:               ");
        $display("   R0 = %0d (Expected: 8)", r0);
        $display("   R1 = %0d (Expected: 3)", r1);
        $display("   R2 = %0d (Expected: 8)", r2);
        $display("   R3 = %0d (Expected: 7)", r3);
        $display("==================================================================");

        $finish;
    end

    // Monitor pipeline activity each cycle
    always @(posedge clk) begin
        if (rst_n) begin
            $display("[Time %4t ns] PC = %4h | IF/ID = %4h | ALU_Out = %4h | WB_Data = %4h | R0=%0d, R1=%0d, R2=%0d, R3=%0d",
                     $time, pc_out, if_id_instr_out, alu_result_out, wb_data_out, r0, r1, r2, r3);
        end
    end

endmodule

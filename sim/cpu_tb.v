`timescale 1ns / 1ps

// ============================================================================
// Module: cpu_tb
// Description: Testbench for 16-Bit RISC CPU verifying Hazard Handling & FPGA Ports
// Reference: UESTC Digital Logic Design Report (Table 2 Test Cases)
// ============================================================================
module cpu_tb;

    reg         clk;
    reg         rst;
    wire [7:0]  led;
    
    wire [15:0] pc_out;
    wire [15:0] if_id_instr_out;
    wire [15:0] alu_result_out;
    wire [15:0] wb_data_out;
    wire [15:0] r0_out, r1_out, r2_out, r3_out;

    // Instantiate Top Module
    cpu_top u_cpu_top (
        .clk             (clk),
        .rst             (rst),
        .led             (led),
        .pc_out          (pc_out),
        .if_id_instr_out (if_id_instr_out),
        .alu_result_out  (alu_result_out),
        .wb_data_out     (wb_data_out),
        .r0_out          (r0_out),
        .r1_out          (r1_out),
        .r2_out          (r2_out),
        .r3_out          (r3_out)
    );

    // 100MHz System Clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_pipeline.vcd");
        $dumpvars(0, cpu_tb);

        $display("==================================================================");
        $display("   16-Bit RISC 5-Stage Pipelined CPU Simulation (UESTC 202602)   ");
        $display("   Reference: Patterson & Hennessy (RISC-V Edition)               ");
        $display("==================================================================");

        // Active-high reset for 20ns
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        $display("[Time %0t ns] Reset de-asserted. CPU begins fetching from 0x0000.", $time);

        // Run simulation for 200ns
        #200;

        $display("==================================================================");
        $display("   Simulation Complete. Hardware & Register Status:              ");
        $display("   R0 = %0d | R1 = %0d | R2 = %0d | R3 = %0d", r0_out, r1_out, r2_out, r3_out);
        $display("   On-Board LED[7:0] = %b (R0[3:0]=%b, R1[3:0]=%b)", led, led[7:4], led[3:0]);
        $display("==================================================================");

        $finish;
    end

    // Cycle Monitor
    always @(posedge clk) begin
        if (!rst) begin
            $display("[Time %4t ns] PC = %4h | IF/ID = %4h | ALU_Out = %4h | WB = %4h | LED = 8'h%2h | R0=%0d, R1=%0d",
                     $time, pc_out, if_id_instr_out, alu_result_out, wb_data_out, led, r0_out, r1_out);
        end
    end

endmodule

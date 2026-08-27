`timescale 1ns / 1ps

// ============================================================================
// Module: cpu_top
// Description: Top-Level 16-Bit RISC 5-Stage Pipelined CPU
// Features:
//   - 5 Stages: IF -> ID -> EX -> MEM -> WB
//   - Full Forwarding Unit (EX/MEM & MEM/WB -> EX) for RAW Data Hazards
//   - Hazard Detection Unit (HDU) in ID stage for Load-Use Hazard Bubble Stall
//   - Control Hazard Jump Flush logic
// ============================================================================
module cpu_top (
    input  wire        clk,
    input  wire        rst_n,
    
    // Probing signals for verification
    output wire [15:0] pc_out,
    output wire [15:0] if_id_instr_out,
    output wire [15:0] alu_result_out,
    output wire [15:0] wb_data_out,
    output wire [15:0] r0,
    output wire [15:0] r1,
    output wire [15:0] r2,
    output wire [15:0] r3
);

    // ========================================================================
    // 1. IF Stage (Instruction Fetch)
    // ========================================================================
    wire [15:0] pc_current;
    wire [15:0] pc_plus_1;
    wire [15:0] pc_next;
    wire [15:0] instr_fetched;
    
    wire        pc_write;
    wire        if_id_write;
    wire        if_id_flush;
    
    assign pc_plus_1 = pc_current + 16'd1;
    
    // PC Register
    pc_reg u_pc_reg (
        .clk      (clk),
        .rst_n    (rst_n),
        .pc_write (pc_write),
        .pc_next  (pc_next),
        .pc_out   (pc_current)
    );
    
    // Instruction Memory
    instr_mem u_instr_mem (
        .addr  (pc_current),
        .instr (instr_fetched)
    );
    
    // IF/ID Pipeline Register
    wire [15:0] if_id_instr;
    wire [15:0] if_id_pc;
    
    if_id_reg u_if_id_reg (
        .clk       (clk),
        .rst_n     (rst_n),
        .write_en  (if_id_write),
        .flush     (if_id_flush),
        .instr_in  (instr_fetched),
        .pc_in     (pc_plus_1),
        .instr_out (if_id_instr),
        .pc_out    (if_id_pc)
    );
    
    // ========================================================================
    // 2. ID Stage (Instruction Decode & Operand Fetch)
    // ========================================================================
    wire [3:0]  id_opcode  = if_id_instr[15:12];
    wire [1:0]  id_rd_addr = if_id_instr[11:10];
    wire [1:0]  id_rs_addr = if_id_instr[9:8];
    wire [15:0] id_imm     = {{8{if_id_instr[7]}}, if_id_instr[7:0]}; // Sign extended
    
    // Control Unit
    wire        id_alu_a_src;
    wire        id_alu_src;
    wire [2:0]  id_alu_op;
    wire        id_mem_write;
    wire        id_mem_read;
    wire        id_mem_to_reg;
    wire        id_reg_write;
    wire        id_jump;
    
    control_unit u_control_unit (
        .opcode     (id_opcode),
        .alu_a_src  (id_alu_a_src),
        .alu_src    (id_alu_src),
        .alu_op     (id_alu_op),
        .mem_write  (id_mem_write),
        .mem_read   (id_mem_read),
        .mem_to_reg (id_mem_to_reg),
        .reg_write  (id_reg_write),
        .jump       (id_jump)
    );
    
    // Jump Target MUX for PC Next
    assign pc_next = (id_jump) ? {8'h00, if_id_instr[7:0]} : pc_plus_1;
    
    // Register File
    wire [15:0] id_rd_data;
    wire [15:0] id_rs_data;
    
    // Forward-declared signals from WB Stage
    wire [15:0] wb_data;
    wire [1:0]  mem_wb_rd_addr;
    wire        mem_wb_reg_write;
    
    reg_file u_reg_file (
        .clk     (clk),
        .rst_n   (rst_n),
        .r_addr1 (id_rd_addr),
        .r_addr2 (id_rs_addr),
        .w_addr  (mem_wb_rd_addr),
        .w_data  (wb_data),
        .w_en    (mem_wb_reg_write),
        .r_data1 (id_rd_data),
        .r_data2 (id_rs_data),
        .r0      (r0),
        .r1      (r1),
        .r2      (r2),
        .r3      (r3)
    );
    
    // Hazard Detection Unit (Load-Use & Jump Flush)
    wire        id_ex_bubble;
    wire        id_ex_mem_read;
    wire [1:0]  id_ex_rd_addr;
    
    hazard_detection_unit u_hdu (
        .id_ex_mem_read (id_ex_mem_read),
        .id_ex_rd_addr  (id_ex_rd_addr),
        .if_id_rd_addr  (id_rd_addr),
        .if_id_rs_addr  (id_rs_addr),
        .jump           (id_jump),
        .pc_write       (pc_write),
        .if_id_write    (if_id_write),
        .id_ex_bubble   (id_ex_bubble),
        .if_id_flush    (if_id_flush)
    );
    
    // ID/EX Pipeline Register
    wire        id_ex_alu_a_src;
    wire        id_ex_alu_src;
    wire [2:0]  id_ex_alu_op;
    wire        id_ex_mem_write;
    wire        id_ex_mem_to_reg;
    wire        id_ex_reg_write;
    
    wire [15:0] id_ex_rd_data;
    wire [15:0] id_ex_rs_data;
    wire [15:0] id_ex_imm;
    wire [1:0]  id_ex_rs_addr;
    
    id_ex_reg u_id_ex_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .bubble         (id_ex_bubble),
        
        .alu_a_src_in   (id_alu_a_src),
        .alu_src_in     (id_alu_src),
        .alu_op_in      (id_alu_op),
        .mem_write_in   (id_mem_write),
        .mem_read_in    (id_mem_read),
        .mem_to_reg_in  (id_mem_to_reg),
        .reg_write_in   (id_reg_write),
        
        .rd_data_in     (id_rd_data),
        .rs_data_in     (id_rs_data),
        .imm_in         (id_imm),
        .rd_addr_in     (id_rd_addr),
        .rs_addr_in     (id_rs_addr),
        
        .alu_a_src_out  (id_ex_alu_a_src),
        .alu_src_out    (id_ex_alu_src),
        .alu_op_out     (id_ex_alu_op),
        .mem_write_out  (id_ex_mem_write),
        .mem_read_out   (id_ex_mem_read),
        .mem_to_reg_out (id_ex_mem_to_reg),
        .reg_write_out  (id_ex_reg_write),
        
        .rd_data_out    (id_ex_rd_data),
        .rs_data_out    (id_ex_rs_data),
        .imm_out        (id_ex_imm),
        .rd_addr_out    (id_ex_rd_addr),
        .rs_addr_out    (id_ex_rs_addr)
    );
    
    // ========================================================================
    // 3. EX Stage (Execution & Address Calculation)
    // ========================================================================
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;
    
    // Forward-declared signals from EX/MEM stage
    wire        ex_mem_reg_write;
    wire [1:0]  ex_mem_rd_addr;
    wire [15:0] ex_mem_alu_result;
    
    // Forwarding Unit
    forwarding_unit u_forwarding_unit (
        .id_ex_rd_addr    (id_ex_rd_addr),
        .id_ex_rs_addr    (id_ex_rs_addr),
        .ex_mem_reg_write (ex_mem_reg_write),
        .ex_mem_rd_addr   (ex_mem_rd_addr),
        .mem_wb_reg_write (mem_wb_reg_write),
        .mem_wb_rd_addr   (mem_wb_rd_addr),
        .forward_a        (forward_a),
        .forward_b        (forward_b)
    );
    
    // Stage 1: 3-to-1 Forwarding MUXes
    wire [15:0] fwd_a_data = (forward_a == 2'b01) ? ex_mem_alu_result :
                             (forward_a == 2'b10) ? wb_data : id_ex_rd_data;
                             
    wire [15:0] fwd_b_data = (forward_b == 2'b01) ? ex_mem_alu_result :
                             (forward_b == 2'b10) ? wb_data : id_ex_rs_data;
    
    // Stage 2: 2-to-1 Operand MUXes (Cascaded with Imm & ALUASrc / ALUSrc)
    wire [15:0] alu_in_a = (id_ex_alu_a_src == 1'b0) ? fwd_a_data : fwd_b_data;
    wire [15:0] alu_in_b = (id_ex_alu_src == 1'b0)   ? fwd_b_data : id_ex_imm;
    
    // Store data (Rd register value) takes forwarded value
    wire [15:0] store_data = fwd_a_data;
    
    // ALU
    wire [15:0] alu_result;
    wire        alu_zero;
    
    alu u_alu (
        .a      (alu_in_a),
        .b      (alu_in_b),
        .alu_op (id_ex_alu_op),
        .result (alu_result),
        .zero   (alu_zero)
    );
    
    // EX/MEM Pipeline Register
    wire        ex_mem_mem_write;
    wire        ex_mem_mem_read;
    wire        ex_mem_mem_to_reg;
    wire [15:0] ex_mem_store_data;
    
    ex_mem_reg u_ex_mem_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        
        .mem_write_in   (id_ex_mem_write),
        .mem_read_in    (id_ex_mem_read),
        .mem_to_reg_in  (id_ex_mem_to_reg),
        .reg_write_in   (id_ex_reg_write),
        
        .alu_result_in  (alu_result),
        .store_data_in  (store_data),
        .rd_addr_in     (id_ex_rd_addr),
        
        .mem_write_out  (ex_mem_mem_write),
        .mem_read_out   (ex_mem_mem_read),
        .mem_to_reg_out (ex_mem_mem_to_reg),
        .reg_write_out  (ex_mem_reg_write),
        
        .alu_result_out (ex_mem_alu_result),
        .store_data_out (ex_mem_store_data),
        .rd_addr_out    (ex_mem_rd_addr)
    );
    
    // ========================================================================
    // 4. MEM Stage (Memory Access)
    // ========================================================================
    wire [15:0] mem_read_data;
    
    data_mem u_data_mem (
        .clk        (clk),
        .rst_n      (rst_n),
        .addr       (ex_mem_alu_result),
        .write_data (ex_mem_store_data),
        .mem_write  (ex_mem_mem_write),
        .mem_read   (ex_mem_mem_read),
        .read_data  (mem_read_data)
    );
    
    // MEM/WB Pipeline Register
    wire        mem_wb_mem_to_reg;
    wire [15:0] mem_wb_alu_result;
    wire [15:0] mem_wb_mem_read_data;
    
    mem_wb_reg u_mem_wb_reg (
        .clk               (clk),
        .rst_n             (rst_n),
        
        .mem_to_reg_in     (ex_mem_mem_to_reg),
        .reg_write_in      (ex_mem_reg_write),
        
        .alu_result_in     (ex_mem_alu_result),
        .mem_read_data_in  (mem_read_data),
        .rd_addr_in        (ex_mem_rd_addr),
        
        .mem_to_reg_out    (mem_wb_mem_to_reg),
        .reg_write_out     (mem_wb_reg_write),
        
        .alu_result_out    (mem_wb_alu_result),
        .mem_read_data_out (mem_wb_mem_read_data),
        .rd_addr_out       (mem_wb_rd_addr)
    );
    
    // ========================================================================
    // 5. WB Stage (Write Back)
    // ========================================================================
    assign wb_data = (mem_wb_mem_to_reg) ? mem_wb_mem_read_data : mem_wb_alu_result;
    
    // ========================================================================
    // Probing Output Assignments
    // ========================================================================
    assign pc_out          = pc_current;
    assign if_id_instr_out = if_id_instr;
    assign alu_result_out  = alu_result;
    assign wb_data_out     = wb_data;

endmodule

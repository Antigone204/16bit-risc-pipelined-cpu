#!/bin/bash
# ==============================================================================
# Simulation Script for 16-Bit RISC CPU
# ==============================================================================
set -e

SRC_DIR="../rtl"
SIM_DIR="../sim"
PIPELINE_REGS_DIR="../rtl/pipeline_regs"

echo "=== Compiling with Icarus Verilog ==="
iverilog -o sim_out \
    ${SRC_DIR}/pc_reg.v \
    ${SRC_DIR}/instr_mem.v \
    ${SRC_DIR}/reg_file.v \
    ${SRC_DIR}/control_unit.v \
    ${SRC_DIR}/alu.v \
    ${SRC_DIR}/data_mem.v \
    ${SRC_DIR}/hazard_detection_unit.v \
    ${SRC_DIR}/forwarding_unit.v \
    ${PIPELINE_REGS_DIR}/if_id_reg.v \
    ${PIPELINE_REGS_DIR}/id_ex_reg.v \
    ${PIPELINE_REGS_DIR}/ex_mem_reg.v \
    ${PIPELINE_REGS_DIR}/mem_wb_reg.v \
    ${SRC_DIR}/cpu_top.v \
    ${SIM_DIR}/cpu_tb.v

echo "=== Running Simulation ==="
vvp sim_out

echo "=== Simulation Completed Successfully! ==="
echo "Waveform file 'cpu_pipeline.vcd' generated."

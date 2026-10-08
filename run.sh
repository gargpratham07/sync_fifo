#!/bin/sh
# Compile and run the FIFO testbench using Icarus Verilog
# Usage: ./run.sh

mkdir -p sim
iverilog -o sim/fifo_sim rtl/*.v tb/tb_sync_fifo.v || exit 1
cd sim && vvp fifo_sim

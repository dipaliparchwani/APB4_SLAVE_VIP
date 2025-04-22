#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <sv_file> <top_module>"
    exit 1
fi

# Assign arguments to variables
file=$1
top_module=$2

# Verify that the SystemVerilog file exists
if [ ! -f "$file" ]; then
    echo "File $file does not exist"
    exit 1
fi

# Compile the SystemVerilog file with full access for visibility
echo "Compiling $file..."
vlog "$file" 

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful"
    echo "Running simulation for $top_module in QuestaSim GUI with waveform..."
    # Launch QuestaSim GUI without optimization, add signals, and run
    vopt work. "$top_module" -o tb_opt+acc=arn
    vsim -c -assertdebug -msgmode both work."$top_module" -vopt -do "add wave -position insertpoint /$top_module/*; run -all"
else
    echo "Compilation failed"
    exit 1
fi

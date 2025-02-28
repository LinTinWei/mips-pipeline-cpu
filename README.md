# MIPS Pipeline CPU
This project implements a 5-stage pipelined MIPS processor in Verilog.

## Steps Implemented:
- ✅ Step 1: Instruction Set and Decoder
- ⏳ Step 2: Datapath (In Progress)
- ⏳ Step 3: ALU and Control Unit
- ⏳ Step 4: Pipeline Registers
- ⏳ Step 5: Hazard Handling

## How to Run:
```bash
iverilog -o instruction_decode_tb instruction_decode_tb.v
vvp instruction_decode_tb
gtkwave dump.vcd

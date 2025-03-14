# ALU testbench
Result:(Test ADD, Sub, AND, OR, Select<branch>, Zero)

A:         10, B:          5, ALU Control: 000, Result:         15, Zero: 0

A:         10, B:          5, ALU Control: 001, Result:          5, Zero: 0

A: 0000000c, B: 0000000a, ALU Control: 010, Result: 00000008, Zero: 0

A: 0000000c, B: 0000000a, ALU Control: 011, Result: 0000000e, Zero: 0

A:          5, B:         10, ALU Control: 100, Result:          1, Zero: 0

A:         10, B:         10, ALU Control: 001, Result:          0, Zero: 1

# Control Unit testbench

Result: (Test R-type(ADD), LW, SW, BEQ and Jump)

R-type ADD -> RegWrite: 1, ALUControl: 000

LW -> MemRead: 1, RegWrite: 1, ALUSrc: 1

SW -> MemWrite: 1, ALUSrc: 1

BEQ -> Branch: 1, ALUControl: 001

Jump -> Jump: 1

# MIPS 5-level  Pipeline testbench:

addi $t1, $zero, 5	# put value 5 into register $t1 (finished)

addi $t2, $zero, 10	# put value 10 into register $t2 (finished)

add $t0, $t1, $t2	# add $t1 and $t2 then store into $t0 (in progress)

# Forwarding Note:(Finished)

forward_a = 2'b01 express EX stage Rs from MEM stage ALU result

forward_a = 2'b10 express EX stage Rs from WB stage result

forward_b is the same definition to deal the Rt forwarding.

# Control Hazard: (In progress)

Flush: test -> beq test (Finished)

beq  $t0, $t1, 2      # 如果 $t0 == $t1，則跳轉 (跳過 `addi`)

addi $t2, $zero, 10   # 若未跳轉，$t2 會變成 10

nop                   # 讓 pipeline 穩定

# Branch Prediction (Finished)

20080005  // addi $t0, $zero, 5

2009000A  // addi $t1, $zero, 10

01095020  // add $t2, $t0, $t1

11490002  // beq $t2, $t1, LABEL

10000002  // beq $t2, $zero, FAIL

08000008  // j Target

00000000  // nop

# test each instructions work correctly.

# Usage method:
# First step: compile and bond each module to top-module:

iverilog -o pipeline_cpu_tb  pipeline_cpu_tb.v pipeline_cpu.v control_unit.v alu.v register_file.v instruction_memory.v data_memory.v forwarding_unit.v branch_prediction.v

# Second step: show the wave form at gtkwave:

gtkwave pipeline_cpu.vcd



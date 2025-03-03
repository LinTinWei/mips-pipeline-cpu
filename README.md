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

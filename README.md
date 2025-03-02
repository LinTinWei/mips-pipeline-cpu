# ALU testbench
Result:(Test ADD, Sub, AND, OR, Select<branch>, Zero)

A:         10, B:          5, ALU Control: 000, Result:         15, Zero: 0

A:         10, B:          5, ALU Control: 001, Result:          5, Zero: 0

A: 0000000c, B: 0000000a, ALU Control: 010, Result: 00000008, Zero: 0

A: 0000000c, B: 0000000a, ALU Control: 011, Result: 0000000e, Zero: 0

A:          5, B:         10, ALU Control: 100, Result:          1, Zero: 0 <if(A > B) ? 1 : 0>

A:         10, B:         10, ALU Control: 001, Result:          0, Zero: 1

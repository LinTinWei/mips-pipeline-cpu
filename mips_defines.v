`ifndef MIPS_DEFINES
`define MIPS_DEFINES

// Opcode 定義
`define OPCODE_RTYPE 6'b000000 // R-type instruction
`define OPCODE_LW    6'b100011 // lw (load word)
`define OPCODE_SW    6'b101011 // sw (store word)
`define OPCODE_BEQ   6'b000100 // beq (branch if equal)
`define OPCODE_J     6'b000010 // j (jump)

// Funct 定義 (R-type instruction 使用)
`define FUNCT_ADD    6'b100000 // add
`define FUNCT_SUB    6'b100010 // sub
`define FUNCT_AND    6'b100100 // and
`define FUNCT_OR     6'b101000 // or
`define FUNCT_SLT    6'b110000 // slt
`endif

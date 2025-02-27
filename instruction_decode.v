`include "mips_defines.v"

module instruction_decode(
	input [31:0] instruction,	// 32 位元指令
	output reg [5:0] opcode, 	// 操作碼
	output reg [4:0] rs, rt, rd,    // 暫存器欄位
	output reg [15:0] immediate,	// 立即數
	output reg [25:0] jump_address,	// 跳躍地址
	output reg is_rtype, is_lw, is_sw, is_beq, is_jump // instruction type
);
always @(*) begin
	// 解析指令
	opcode = instruction[31:26];
	rs = instruction[25:21];
	rt = instruction[20:16];

	// 判斷指令類型
	is_rtype = (opcode == `OPCODE_RTYPE);
	is_lw = (opcode == `OPCODE_LW);
	is_sw = (opcode == `OPCODE_SW);
	is_beq = (opcode == `OPCODE_BEQ);
	is_jump = (opcode == `OPCODE_J);

	if (is_rtype) begin
		rd = instruction[15:11];	// 目標暫存器(R-type)
	end else if (is_jump) begin
		jump_address = instruction[25:0];	// 跳躍地址
	end else begin
		immediate = instruction[15:0];
	end
end
endmodule		

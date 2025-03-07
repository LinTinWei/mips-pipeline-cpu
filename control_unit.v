module control_unit(
	input [5:0] opcode,	// 指令的 Opcode
	input [5:0] funct,	// R-type 指令的 Funct 欄位
	output reg reg_write,	// 暫存器寫入
	output reg reg_dst,	// 暫存器寫入位址
	output reg mem_read,	// 記憶體讀取
	output reg mem_write,	// 記憶體寫入
	output reg branch,	// 分支指令
	output reg jump,	// 跳轉指令
	output reg alu_src,	// ALU 第二操作數來源 (立即數或是暫存器)
	output reg mem_to_reg,	// 新增控制信號
	output reg [2:0] alu_control	// ALU 控制信號 (加減法等)
);

// ALU 操作編碼
localparam ALU_ADD = 3'b010;
localparam ALU_SUB = 3'b110;
localparam ALU_AND = 3'b000;
localparam ALU_OR  = 3'b001;
localparam ALU_SLT = 3'b111;
localparam ALU_NOP = 3'b100;

// 指令操作編碼 (Opcodes)
localparam OPCODE_RTYPE = 6'b000000;	// R-Type 指令
localparam OPCODE_ADDI  = 6'b001000;	// addi
localparam OPCODE_LW    = 6'b100011;	// LW
localparam OPCODE_SW    = 6'b101011;	// SW
localparam OPCODE_BEQ	= 6'b000100;	// BEQ
localparam OPCODE_ANDI	= 6'b001100;	// ANDI
localparam OPCODE_JUMP	= 6'b000010;	// J

always @(*) begin
	// 預設值
	reg_write = 0;
	reg_dst = 0;	// 預設為 R-type
	alu_src = 0;
	mem_read = 0;
	mem_write = 0;
	mem_to_reg = 0; // 預設情況為使用 ALU 結果
	branch = 0;
	jump = 0;
	alu_control = ALU_NOP;
	$display("Opcode: %b, Memory Write: %b", opcode, mem_write);
	case (opcode)
		OPCODE_RTYPE: begin	// R-type 指令
			reg_write = 1;
			reg_dst = 0;
			alu_src = 0;	// ALU 第二操作數來自於暫存器
			mem_to_reg = 0;
			case (funct)
				6'b100000: alu_control = ALU_ADD;	// ADD
				6'b100010: alu_control = ALU_SUB;	// SUB
				6'b100100: alu_control = ALU_AND;	// AND
				6'b100101: alu_control = ALU_OR;	// OR
				6'b101010: alu_control = ALU_SLT;	// SLT
				default: alu_control = ALU_NOP;		// 未知操作, 保持 NOP
			endcase
		end
		OPCODE_ADDI: begin
			reg_write = 1;
			reg_dst = 1;
			alu_src = 1;	// 用立即數
			alu_control = ALU_ADD;
			//$display("Opcode: %b", opcode);
		end
		
		OPCODE_LW: begin
			reg_write = 1;
			alu_src = 1;
			mem_read = 1;
			mem_to_reg = 1; // 來自內存
			alu_control = ALU_ADD; // 地址計算使用加法
		end

		OPCODE_SW: begin
			alu_src = 1;
			mem_write = 1;
			alu_control = ALU_ADD;	// 地址計算
		end

		OPCODE_BEQ: begin
			branch = 1;
			alu_control = ALU_SUB; 	// 減法用於比較
		end

		OPCODE_ANDI: begin
			reg_write = 1;
			alu_src = 1;
			alu_control = ALU_AND;
		end

		OPCODE_JUMP: begin
			jump = 1;
		end

		default: begin
			// 其他未知指令, 保持所有控制信號為 0 (NOP)
			alu_control = ALU_NOP;
		end
	endcase
end
endmodule

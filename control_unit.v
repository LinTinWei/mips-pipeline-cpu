module control_unit(
	input [5:0] opcode,	// 指令的 Opcode
	input [5:0] funct,	// R-type 指令的 Funct 欄位
	output reg reg_write,	// 暫存器寫入
	output reg mem_read,	// 記憶體讀取
	output reg mem_write,	// 記憶體寫入
	output reg branch,	// 分支指令
	output reg jump,	// 跳轉指令
	output reg alu_src,	// ALU 第二操作數來源 (立即數或是暫存器)
	output reg [2:0] alu_control	// ALU 控制信號 (加減法等)
);

always @(*) begin
	// 預設值
	reg_write = 0;
	mem_read = 0;
	mem_write = 0;
	branch = 0;
	jump = 0;
	alu_src = 0;
	alu_control = 3'b000;

	case (opcode)
		6'b000000: begin	// R-type 指令
			reg_write = 1;
			case (funct)
				6'b100000: alu_control = 3'b000;	// ADD
				6'b100010: alu_control = 3'b001;	// SUB
				6'b100100: alu_control = 3'b010;	// AND
				6'b101000: alu_control = 3'b011;	// OR
				6'b110000: alu_control = 3'b100;	// SLT
				default: alu_control = 3'b000;
			endcase
		end
		6'b100011: begin	// LW (Load Word) 
			reg_write = 1;
			mem_read = 1;
			alu_src = 1;
			alu_control = 3'b000;	// ADD
		end
		6'b101011: begin	// SW (Store Word)
			mem_write = 1;
			alu_src = 1;
			alu_control = 3'b000;	// ADD
		end
		6'b000100: begin	// BEQ (Branch if Equal)
			branch = 1;
			alu_control = 3'b001;	// SUB
		end
		6'b000010: begin	// J (Jump)
			jump = 1;
		end
		default: begin
			reg_write = 0;
			mem_read = 0;
			mem_write = 0;
			branch = 0;
			jump = 0;
			alu_control = 0;
		end
	endcase
end
endmodule

module alu(
	input [31:0] a, b,	// 操作數
	input [2:0] alu_control,	// 控制 ALU 操作
	output reg [31:0] alu_result,	// 運算結果
	output zero		// 是否為零 (用於 `beq`)
);

assign zero = (alu_result == 0);

always @(*) begin
	case (alu_control)
		3'b000: alu_result = a + b;		// 加法
		3'b001: alu_result = a - b;		// 減法
		3'b010: alu_result = a & b;		// AND
		3'b011: alu_result = a | b;		// OR
		3'b100: alu_result = (a < b) ? 1 : 0;	// 小於比較 (slt)
		default: alu_result = 0;
	endcase
	// $display("ALU Operation: A = %x, B = %x, ALU Control = %b, Result = %x", a, b, alu_control, alu_result);
end

endmodule

module alu(
	input [31:0] a, b,	// 操作數
	input [2:0] alu_control,	// 控制 ALU 操作
	output reg [31:0] result,	// 運算結果
	output zero		// 是否為零 (用於 `beq`)
);

assign zero = (result == 0);

always @(*) begin
	case (alu_control)
		3'b000: result = a + b;
		3'b001: result = a - b;
		3'b010: result = a & b;
		3'b011: result = a | b;
		3'b100: result = (a < b)?1:0;	// slt
		default: result = 0;
	endcase
end

endmodule

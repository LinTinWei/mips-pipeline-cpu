module datapath(
	input clk, rst,
	output reg [31:0] pc
);
	wire [31:0] next_pc;

	assign next_pc = pc + 4;	// PC + 4 的邏輯
	always @(posedge clk, posedge rst) begin
		if (rst)
			pc <= 0;	// 初始化 PC = 0
		else
			pc <= next_pc;	// 每次 clock 更新 PC
	end
endmodule

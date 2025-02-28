module pc(
	input clk,	// 時脈信號
	input rst,	// 重置信號
	input  [31:0] next_pc,	// 下一個 PC 地址
	output reg [31:0] pc	// 當前 PC
);
always @(posedge clk or posedge rst) begin
	if (rst)
		pc <= 32'b0;	// 初始化 PC = 0
	else
		pc <= next_pc;
end
endmodule

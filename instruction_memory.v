module instruction_memory(
	input [31:0] pc,	// 從 PC 中取得的地址
	output reg [31:0] instruction	// 取出的指令
);
reg [31:0] memory [0:255];	// 256 個 32-bit 指令空間(可放 256 條 MIPS 指令)

initial begin
	$readmemh("instructions.mem", memory);	// 從文件中讀取指令
end


always @(*) begin
	instruction = memory[pc >> 2];	// 取出對應指令 (每個指令 4 bytes), pc = 0 -> memory[0], pc = 4 -> memory[1]
end
endmodule

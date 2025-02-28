module data_memory(
	input clk,
	input mem_write, memread,	// 控制訊號
	input [31:0] addr, write_data,	// 地址與數據
	output reg [31:0] read_data	// 讀取數據
);

reg [31:0] memory [0:255];	// 256 個 32-bit 記憶體

always @(posedge clk) begin
	if (mem_write)
		memory[addr >> 2] <= write_data;
end

always @(*) begin
	if (mem_read)
		read_data = memory[addr >> 2];
end

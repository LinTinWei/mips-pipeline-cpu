module register_file(
	input clk,
	input reg_write,	// 控制是否輸入
	input [4:0] read_reg1, read_reg2, write_reg,	// 暫存器地址
	input [31:0] write_data,	// 要寫入的資料
	output reg [31:0] read_data1, read_data2	// 讀取數據
);

reg [31:0] registers[31:0];	// 32 個 32-bit 暫存器

always @(*) begin
	read_data1 = registers[read_reg1];
	read_data2 = registers[read_reg2];
end
always @(posedge clk) begin
	registers[write_reg] <= write_data;
end
endmodule

module register_file(
	input clk,
	input rst,
	input reg_write,	// 控制是否輸入
	input [4:0] read_reg1, read_reg2, write_reg,	// 暫存器地址
	input [31:0] write_data,	// 要寫入的資料
	output reg [31:0] read_data1, read_data2	// 讀取數據
);

reg [31:0] registers[31:0];	// 32 個 32-bit 暫存器

// 當 rst = 1, 將所有暫存器清零
integer i;
always @(posedge clk or posedge rst) begin
	$display("Register Write: %b", reg_write);
	if (rst == 1) begin
		for (i = 1; i < 32; i = i + 1) begin
			registers[i] <= 32'b0;
		end
		$display("Initialized Register Files.");
	end
	else if (reg_write == 1'b1) begin
		registers[write_reg] <= write_data;
		$display("Write Register[%d] = %h, Write Data = %h", write_reg, registers[write_reg], write_data);
	end
end

// 讀取地址改變時, 立即輸出對應的數據
always @(*) begin
	read_data1 = registers[read_reg1];
	read_data2 = registers[read_reg2];
end

endmodule

`timescale 1ns/1ps

module register_file_tb;

	reg clk, rst;
	reg reg_write;
	reg [4:0] read_reg1, read_reg2, write_reg;
	reg [31:0] write_data;
	wire [31:0] read_data1, read_data2;

	// 實例化 Register File
	register_file uut(
		.clk(clk),
		.rst(rst),
		.reg_write(reg_write),
		.read_reg1(read_reg1),
		.read_reg2(read_reg2),
		.write_reg(write_reg),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

	// 產生時脈訊號
	always #5 clk = ~clk;	// 每 5ns 反轉一次 (10ns 一個週期)


	initial begin
		$dumpfile("register_file.vcd");
		$dumpvars(0, register_file_tb);

		clk = 0;
		rst = 1;	// 啟動重置
		reg_write = 0;
		read_reg1 = 0;
		read_reg2 = 0;
		write_reg = 0;
		write_data = 0;

		#10;
		rst = 0;	// 取消重置

		// 測試寫入暫存器 $t0 (地址 8)
		write_reg = 5'd8;
		write_data = 32'hA5A5A5A5;
		reg_write = 1;
		#10;
		reg_write = 0;	// 停止寫入

		// 讀取剛剛的暫存器
		read_reg1 = 5'd8;
		#10;
		$display("Read Data1 (Reg 8) = %h", read_data1);

		// 再次寫入另一個暫存器 $t1 (地址9)
		write_reg = 5'd9;
		write_data = 32'h5A5A5A5A;
		reg_write = 1;
		#10;
		reg_write = 0;	// 停止寫入

		// 同時讀取兩個暫存器 $t0 and $t1
		read_reg1 = 5'd8;
		read_reg2 = 5'd9;
		#10;
		$display("Read Data1 (Reg 8) = %h, Read Data2 (Reg 9) = %h", read_data1, read_data2);

		$finish;
	end
	endmodule

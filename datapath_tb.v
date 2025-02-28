`timescale 1ns/1ps
module datapath_tb;

	reg clk, rst;
	wire [31:0] pc;

	// 實例化數據通路
	datapath uut (
		.clk(clk),
		.rst(rst),
		.pc(pc)
	);

	// 產生時脈信號
	always #5 clk = ~clk; 	// 每 5ns 翻轉一次 (10ns 週期)

	initial begin
		$dumpfile("datapath.vcd");	// 產生 vcd 波形檔
		$dumpvars(0, datapath_tb);

		// 初始化
		clk = 0;
		rst = 1;
		#10 rst = 0;	// 10ns 後取消重置

		// 模擬運行 100ns
		
		#100;

		$finish;	// 結束模擬
	end

endmodule

`timescale 1ns/1ps

module pipeline_cpu_tb;

	reg clk, rst;
	integer i;

	// 實例化 Pipeline CPU
	pipeline_cpu uut (
		.clk,
		.rst
	);

	// 產生時鐘訊號(10ns 週期)
	always #5 clk = ~clk;

	initial begin
		// 初始化波形檔案
		$dumpfile("pipeline_cpu.vcd");
		$dumpvars(0, pipeline_cpu_tb);
		
		// 初始化訊號
		clk = 0;
		rst = 1;
		#10 rst = 0;	// 確保 reset 釋放, 讓系統進入正常工作狀態
	end

	// **測試主迴圈**
	always @(posedge clk) begin
		$display("\n======================= Cycle %0d ==========================", $time / 10);
		$display("PC: %h | Next PC: %h | Instruction: %h", uut.pc_reg, uut.pc_next, uut.if_id_instruction);
		// **check Forwarding**
		$display("Forward A: %b | Forward B: %b", uut.forward_a, uut.forward_b);
		$display("ALU Operand1: %h | ALU Operand2: %h | ALU Result: %h", uut.alu_operand1, uut.alu_operand2, uut.alu_result);

		// **check Register File**
		$display("Register $t0: %h | Register $t1: %h | Register $t2: %h", uut.rf.registers[8], uut.rf.registers[9], uut.rf.registers[10]);

		// **check Branch Prediction**
		$display("Branch: %b | Predicted Taken: %b | Actual Taken: %b | Mispredict: %b", uut.branch, uut.predicted_taken, uut.actual_taken, uut.mispredict);

		// ** check Jump
		$display("Jump: %b | New PC: %h", uut.is_jump, uut.pc_next);

		// ** 結束測試條件
		if (uut.pc_reg == 32'h00000020) begin
			$display("🚀 測試結束🚀 ");
			$finish;
		end
	end
	endmodule

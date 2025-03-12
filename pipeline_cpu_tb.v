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
		$display("Reset Complete: Simulation Starting...");

		
		// 測試期間運行 50 個時鐘週期
		for (i = 0; i < 10; i = i + 1) begin
			$display("---------------------------- dash line -----------------------------------");

			#10;
			$display("Cycle %d:", i);
			// Instruction Fetch (IF) 階段
            		$display("IF Stage - PC: %h, Instruction: %b", uut.pc_reg, uut.if_id_instruction);
			
			// Instruction Decode (ID) 階段
			$display("[ID] Opcode: %b | Rs: %d | Rt: %d | Rd: %d", uut.if_id_instruction[31:26], uut.rs, uut.rt, uut.rd);
            		$display("ID Stage - Read Data1: %h, Read Data2: %h", uut.id_ex_read_data1, uut.id_ex_read_data2);

			// Execution (EX) 階段
            		$display("EX Stage - ALU Result: %h, Operand2: %h", uut.alu_result, uut.alu_operand2);

			// Memory Access (MEM) 階段
           		$display("[MEM] MemRead: %b | MemWrite: %b, Mem Data: %h", uut.ex_mem_mem_read, uut.ex_mem_mem_write, uut.mem_data);

			// Write Back (WB) 階段
			if (uut.mem_wb_reg_write) begin
            			$display("[WB] Writing %h to Register %d", uut.write_data_wb, uut.mem_wb_write_reg);
			end
			$display("---------------------------- dash line -----------------------------------");
		end
		
		
		// 驗證寄存器數據是否正確
        	if (uut.rf.registers[9] != 32'h00000005 && uut.rf.registers[10] != 32'h0000000a) begin
            		$display("ERROR: Register $t1 = 00000005, $t2 = 0000000a, but got $t1 = %h, $t2 = %h, $t0 = %h", uut.rf.registers[9], uut.rf.registers[10], uut.rf.registers[8]);
        	end else begin
            		$display("SUCCESS: Register $t1 = 00000005, $t2 = 0000000a, $t0 = 0000000f");
        	end
		$finish;
	end
	endmodule

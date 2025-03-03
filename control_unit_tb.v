`timescale 1ns/1ps

module control_unit_tb;

	reg [5:0] opcode, funct;
	wire reg_write, mem_read, mem_write, branch, jump, alu_src;
	wire [2:0] alu_control;

	// 實例化控制單元
	control_unit uut(
		.opcode(opcode),
		.funct(funct),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.branch(branch),
		.jump(jump),
		.alu_src(alu_src),
		.alu_control(alu_control)
	);

	initial begin
		$dumpfile("control_unit.vcd");
		$dumpvars(0, control_unit_tb);
		
		// 測試 R-type (ADD)
		opcode = 6'b000000; funct = 6'b100000; #10;
		$display("R-type ADD -> RegWrite: %b, ALUControl: %b", reg_write, alu_control);

		// 測試 LW 指令
		opcode = 6'b100011; #10;
		$display("LW -> MemRead: %b, RegWrite: %b, ALUSrc: %b", mem_read, reg_write, alu_src);

		// 測試 SW 指令
		opcode = 6'b101011; #10;
		$display("SW -> MemWrite: %b, ALUSrc: %b", mem_write, alu_src);

		// 測試 BEQ 指令
		opcode = 6'b000100; #10;
		$display("BEQ -> Branch: %b, ALUControl: %b", branch, alu_control);

		// 測試 j (Jump) 指令
		opcode = 6'b000010; #10;
		$display("Jump -> Jump: %b", jump);

		$finish;
	end
	endmodule

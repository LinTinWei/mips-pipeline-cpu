`timescale 1ns/1ps

module control_unit_tb;

	reg [5:0] opcode, funct;
	wire reg_write, mem_read, mem_write, branch, jump, alu_src, mem_to_reg;
	wire [2:0] alu_control;

	// 實例化控制單元
	control_unit uut(
		.opcode(opcode),
		.funct(funct),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.mem_to_reg(mem_to_reg),
		.branch(branch),
		.jump(jump),
		.alu_src(alu_src),
		.alu_control(alu_control)
	);

	initial begin
		$dumpfile("control_unit.vcd");
		$dumpvars(0, control_unit_tb);
		
		// 測試 R-type (ADD)
		opcode = 6'b001000;	// addi 指令
		#10 $display("addi: RegWrite = %b, ALUSrc = %b, ALUOp = %b", reg_write, alu_src, alu_control);

		opcode = 6'b100011;	// lw 指令
		#10 $display("lw: MemRead = %b, MemToReg = %b", mem_read, mem_to_reg);

		opcode = 6'b000010; 	// j 指令
		#10 $display("jump: Jump = %b", jump);

		$finish;
	end
	endmodule

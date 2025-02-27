`timescale 1ns/1ps
`include "instruction_decode.v"

module instruction_decode_tb;

reg [31:0] instruction;
wire [5:0] opcode;
wire [4:0] rs, rt, rd;
wire [15:0] immediate;
wire [25:0] jump_address;
wire is_rtype, is_lw, is_sw, is_beq, is_jump;

// 實體化模組
instruction_decode uut (
	.instruction(instruction),
	.opcode(opcode),
	.rs(rs), .rt(rt), .rd(rd),
	.immediate(immediate),
	.jump_address(jump_address),
	.is_rtype(is_rtype), .is_lw(is_lw),
	.is_sw(is_sw), .is_beq(is_beq), .is_jump(is_jump)
);

initial begin
	// 啟用 vcd 紀錄
	$dumpfile("dump.vcd");
	$dumpvars(0, instruction_decode_tb); // 紀錄整個測試模組的變數

	// 測試 R-type instruction: add $t0, $t1, $t2
	instruction = 32'b000000_01001_01010_01000_00000_100000; #1;
	$display("Opcode: %b (R-type)", opcode);
        $display("Registers: rs = %b,rt = %b, rd = %b\n", rs, rt, rd);


	// 測試 I-type instruction: lw $t0, 4($t1)
	instruction = 32'b100011_01001_01000_0000_0000_0000_0100; #1;
	$display("Opcode: %b (lw)", opcode);
        $display("Registers: rs = %b,rt = %b, immediate = %b\n", rs, rt, immediate);


	// 測試 I-type instruction: sw $t0, 4($t1)
	instruction = 32'b101011_01001_01000_0000_0000_0000_0100; #1;
	$display("Opcode: %b (sw)", opcode);
        $display("Registers: rs = %b,rt = %b, immediate = %b\n", rs, rt, immediate);


	// 測試 J-type instruction: j 0x00400000
	instruction = 32'b000010_00000000010000000000000000; #1;
	$display("Opcode: %b (Jump)", opcode);
	$display("Jump Address: %b\n", jump_address);

	#10;
	$finish;
end
endmodule

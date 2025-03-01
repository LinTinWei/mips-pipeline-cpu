`timescale 1ns/1ps

module alu_tb;

	reg [31:0] a, b;
	reg [2:0] alu_control;
	wire [31:0] alu_result;
	wire zero;

	// 實例化 ALU
	alu uut(
		.a(a),
		.b(b),
		.alu_control(alu_control),
		.alu_result(alu_result),
		.zero(zero)
	);

	initial begin
		$dumpfile("alu.vcd");	// 產生 VCD 波形檔案
		$dumpvars(0, alu_tb);

		// 測試加法
		a = 10; b = 5; alu_control = 3'b000;
		#10;
		$display("A: %d, B: %d, ALU Control: %b, Result: %d, Zero: %b", a, b, alu_control, alu_result, zero);

		// 測試減法
		a = 10; b = 5; alu_control = 3'b001;
		#10;
		$display("A: %d, B: %d, ALU Control: %b, Result: %d, Zero: %b", a, b, alu_control, alu_result, zero);
		
		// 測試 AND
		a = 32'hC; b = 32'hA; alu_control = 3'b010;
		#10;
		$display("A: %x, B: %x, ALU Control: %b, Result: %x, Zero: %b", a, b, alu_control, alu_result, zero); 

		// 測試 OR
                a = 32'hC; b = 32'hA; alu_control = 3'b011;
                #10;
                $display("A: %x, B: %x, ALU Control: %b, Result: %x, Zero: %b", a, b, alu_control, alu_result, zero);


		// 測試 slt
		a = 5; b = 10; alu_control = 3'b100;
		#10
		$display("A: %d, B: %d, ALU Control: %b, Result: %d, Zero: %b", a, b, alu_control, alu_result, zero);
		
		// 測試 Zero flag
		a = 10; b = 10; alu_control = 3'b001;
		#10
		$display("A: %d, B: %d, ALU Control: %b, Result: %d, Zero: %b", a, b, alu_control, alu_result, zero);
	end
endmodule

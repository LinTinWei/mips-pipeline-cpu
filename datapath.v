module datapath(
	input clk, rst,
	output reg [31:0] pc
);
	wire [31:0] next_pc, instruction, read_data1, read_data2, write_data, alu_result;
	wire [4:0] write_reg;
	wire [2:0] alu_control;
	wire reg_write;
	
	// PC counter, 每次 + 4
	assign next_pc = pc + 4;	// PC + 4 的邏輯
	always @(posedge clk, posedge rst) begin
		if (rst)
			pc <= 0;	// 初始化 PC = 0
		else
			pc <= next_pc;	// 每次 clock 更新 PC
	end

	// Instruction Memory
	instruction_memory imem(
		.pc(pc),
		.instruction(instruction)
	);

	// Register file
	register_file regfile(
		.clk(clk),
		.reg_write(reg_write),
		.read_reg1(instruction[25:21]),
		.read_reg2(instruction[20:16]),
		.write_reg(write_reg),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

	// ALU
	alu alu_unit(
		.a(read_data1),
		.b(read_data2),
		.alu_control(alu_control),
		.alu_result(alu_result)
	);

endmodule

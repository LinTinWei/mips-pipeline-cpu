module pipeline_cpu(
	input clk,
	input rst
);

// === IF: Instruction Fetch ===
wire [31:0] pc, pc_next, instruction;
reg [31:0] pc_reg;

// PC 和 指令記憶體
instruction_memory imem(
	.pc(pc_reg),
	.instruction(instruction)
);

// PC + 4 遞增邏輯
assign pc_next = pc_reg + 4;

// IF/ID 暫存器
reg [31:0] if_id_pc, if_id_instruction;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		pc_reg <= 32'b0;
		if_id_pc <= 0;
		if_id_instruction <= 0;
	end else begin
		pc_reg <= pc_next;
		if_id_pc <= pc_reg;
		if_id_instruction <= instruction;
	end
end

// === ID: Instruction Decode ===
wire [4:0] rs, rt, rd, write_reg;
wire [31:0] read_data1, read_data2, write_data, sign_ext_imm;
wire reg_write, reg_dst, alu_src, mem_read, mem_write, branch, jump;
wire [2:0] alu_control;

// 解碼指令
assign rs = if_id_instruction[25:21];
assign rt = if_id_instruction[20:16];
assign rd = if_id_instruction[15:11];
assign write_reg = reg_dst ? rt :rd;	// RegDst = 1 : rd, RegDst = 0 : rt
assign sign_ext_imm = {{16{if_id_instruction[15]}}, if_id_instruction[15:0]};
// assign write_data = reg_dst?sign_ext_imm:ex_mem_alu_result;
always @(*) $display("Instruction: %h, ALU code: %b", if_id_instruction, alu_control);

// 控制單元
control_unit cu(
	.opcode(if_id_instruction[31:26]),
	.funct(if_id_instruction[5:0]),
	.reg_dst(reg_dst),
	.reg_write(reg_write),
	.alu_src(alu_src),
	.mem_read(mem_read),
	.mem_write(mem_write),
	.branch(branch),
	.jump(jump),
	.mem_to_reg(mem_to_reg),	// 新增控制信號
	.alu_control(alu_control)
);

// 暫存器檔案
register_file rf(
	.clk(clk),
	.rst(rst),
	.reg_write(reg_write),
	.read_reg1(rs),
	.read_reg2(rt),
	.write_reg(write_reg),
	.write_data(sign_ext_imm), // 使用最終寫回數據
	.read_data1(read_data1),
	.read_data2(read_data2)
);

// ID/EX 暫存器
reg [31:0] id_ex_read_data1, id_ex_read_data2, id_ex_imm;
reg [2:0] id_ex_alu_control;
reg id_ex_alu_src;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		id_ex_read_data1 <= 0;
		id_ex_read_data2 <= 0;
		id_ex_imm <= 0;
		id_ex_alu_control <= 0;
		id_ex_alu_src <= 0;
	end else begin
		id_ex_read_data1 <= read_data1;
		id_ex_read_data2 <= read_data2;
		id_ex_imm <= sign_ext_imm;
		id_ex_alu_control <= alu_control;
		id_ex_alu_src <= alu_src;
	end
end

// === EX: Execution (ALU 計算) ===
wire [31:0] alu_result, alu_operand2;
assign alu_operand2 = id_ex_alu_src?id_ex_imm:id_ex_read_data2;
always @(*) $display("Execution Stage id_ex_alu_src: %b, ALU Operand2: %h", id_ex_alu_src, alu_operand2);
alu my_alu(
	.a(id_ex_read_data1),
       	.b(alu_operand2),
	.alu_control(id_ex_alu_control),
	.alu_result(alu_result)
);

// EX/MEM 暫存器
reg [31:0] ex_mem_alu_result, ex_mem_write_data;
reg ex_mem_mem_read, ex_mem_mem_write;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		ex_mem_alu_result <= 0;
		ex_mem_write_data <= 0;
		ex_mem_mem_read <= 0;
		ex_mem_mem_write <= 0;
	end else begin
		ex_mem_alu_result <= alu_result;
		ex_mem_write_data <= id_ex_read_data2;
		ex_mem_mem_read <= mem_read;
		ex_mem_mem_write <= mem_write;
	end
end

// === MEM: Memory Access ===
wire [31:0] mem_data;
data_memory dmem(
	.clk(clk),
	.addr(ex_mem_alu_result),
	.write_data(ex_mem_write_data),
	.mem_read(ex_mem_mem_read),
	.mem_write(ex_mem_mem_write),
	.read_data(mem_data)
);

// MEM/WB 暫存器
reg [31:0] mem_wb_data, mem_wb_alu_result;
reg mem_wb_mem_to_reg;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mem_wb_data <= 0;
		mem_wb_alu_result <= 0;
		mem_wb_mem_to_reg <= 0;
	end else begin
		mem_wb_data <= mem_data;
		mem_wb_alu_result <= ex_mem_alu_result;
		mem_wb_mem_to_reg <= mem_to_reg;
	end
end

// === WB: Write Back ===
assign write_data = mem_wb_mem_to_reg ? mem_wb_data : ex_mem_alu_result;

endmodule

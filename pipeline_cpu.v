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

always @(posedge clk or posedge rst) begin
	if (rst) begin
		pc_reg <= 0;
	end else begin
		pc_reg <= pc_next;
	end
end

// IF/ID 暫存器
reg [31:0] if_id_pc, if_id_instruction;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		if_id_pc <= 0;
		if_id_instruction <= 0;
	end else begin
		if_id_pc <= pc_reg;
		if_id_instruction <= instruction;
	end
end


// === ID: Instruction Decode ===
wire [4:0] rs, rt, rd;
wire [31:0] read_data1, read_data2, sign_ext_imm;
wire reg_write, reg_dst, alu_src, mem_read, mem_write, branch, jump, mem_to_reg;
wire [2:0] alu_control;

// 解碼指令
assign rs = if_id_instruction[25:21];
assign rt = if_id_instruction[20:16];
assign rd = if_id_instruction[15:11];
// assign write_reg = reg_dst ? rt :rd;	// RegDst = 1 : rd, RegDst = 0 : rt
assign sign_ext_imm = {{16{if_id_instruction[15]}}, if_id_instruction[15:0]};

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
wire [31:0] write_data_wb;
wire [4:0] write_reg_wb;
reg mem_wb_reg_write;

register_file rf(
	.clk(clk),
	.rst(rst),
	.reg_write(mem_wb_reg_write),
	.read_reg1(rs),
	.read_reg2(rt),
	.write_reg(write_reg_wb),
	.write_data(write_data_wb), // 使用最終寫回數據
	.read_data1(read_data1),
	.read_data2(read_data2)
);


// ID/EX 暫存器
reg [31:0] id_ex_read_data1, id_ex_read_data2, id_ex_imm;
reg [4:0] id_ex_rs, id_ex_rt, id_ex_rd;
reg [2:0] id_ex_alu_control;
reg id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg, id_ex_reg_write, id_ex_reg_dst;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		id_ex_read_data1 <= 0;
		id_ex_read_data2 <= 0;
		id_ex_imm <= 0;
		id_ex_rs <= 0;
		id_ex_rt <= 0;
		id_ex_rd <= 0;
		id_ex_alu_control <= 0;
		id_ex_alu_src <= 0;
		id_ex_mem_read <= 0;
		id_ex_mem_write <= 0;
		id_ex_mem_to_reg <= 0;
		id_ex_reg_write <= 0;
		id_ex_reg_dst <= 0;
	end else begin
		id_ex_read_data1 <= read_data1;
                id_ex_read_data2 <= read_data2;
                id_ex_imm <= sign_ext_imm;
                id_ex_rs <= rs;
                id_ex_rt <= rt;
                id_ex_rd <= rd;
                id_ex_alu_control <= alu_control;
                id_ex_alu_src <= alu_src;
                id_ex_mem_read <= mem_read;
                id_ex_mem_write <= mem_write;
                id_ex_mem_to_reg <= mem_to_reg;
                id_ex_reg_write <= reg_write;
                id_ex_reg_dst <= reg_dst;
	end
end

// === EX: Execution ===
// EX/MEM 暫存器
reg [31:0] ex_mem_alu_result, ex_mem_write_data;
reg [4:0] ex_mem_write_reg;
reg ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_reg_write;

// MEM/WB 暫存器
reg [31:0] mem_wb_mem_data, mem_wb_alu_result;
reg [4:0] mem_wb_write_reg;
reg mem_wb_mem_to_reg;
// reg mem_wb_reg_write;

// === Forwarding 選擇信號 ===
wire [1:0] forward_a, forward_b;
wire [31:0] alu_operand1, alu_operand2;


// Forwarding Unit 實例化 (fu)
forwarding_unit fu(
	.ex_rs(id_ex_rs),
	.ex_rt(id_ex_rt),
	.mem_wb_write_reg(mem_wb_write_reg),
	.ex_mem_write_reg(ex_mem_write_reg),
	.mem_wb_reg_write(mem_wb_reg_write),
	.ex_mem_reg_write(ex_mem_reg_write),
	.forward_a(forward_a),
	.forward_b(forward_b)
);

// 透過 Forwarding 選擇 ALU 輸入
assign alu_operand1 = (forward_a == 2'b10)?ex_mem_alu_result:
			(forward_a == 2'b01)?write_data_wb:
			id_ex_read_data1;

assign alu_operand2 = (forward_b == 2'b10)?ex_mem_alu_result:
			(forward_b == 2'b01)?write_data_wb:
			(id_ex_alu_src)?id_ex_imm:id_ex_read_data2;

// ALU 計算
wire [31:0] alu_result;
wire [4:0] write_reg;

assign write_reg = id_ex_reg_dst ? id_ex_rt : id_ex_rd;

alu my_alu(
	.a(alu_operand1),
       	.b(alu_operand2),
	.alu_control(id_ex_alu_control),
	.alu_result(alu_result)
);

// EX/MEM 暫存器
// reg [31:0] ex_mem_alu_result, ex_mem_write_data;
// reg [4:0] ex_mem_write_reg;
// reg ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg, ex_mem_reg_write;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		ex_mem_alu_result <= 0;
		ex_mem_write_data <= 0;
		ex_mem_write_reg <= 0;
		ex_mem_mem_read <= 0;
		ex_mem_mem_write <= 0;
		ex_mem_mem_to_reg <= 0;
		ex_mem_mem_write <= 0;
		ex_mem_reg_write <= 0;
	end else begin
		ex_mem_alu_result <= alu_result;
                ex_mem_write_data <= id_ex_read_data2;
                ex_mem_write_reg <= write_reg;
                ex_mem_mem_read <= id_ex_mem_read;
                ex_mem_mem_write <= id_ex_mem_write;
                ex_mem_mem_to_reg <= id_ex_mem_to_reg;
                ex_mem_reg_write <= id_ex_reg_write;
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
// reg [31:0] mem_wb_mem_data, mem_wb_alu_result;
// reg [4:0] mem_wb_write_reg;
// reg mem_wb_mem_to_reg, mem_wb_reg_write;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mem_wb_mem_data <= 0;
		mem_wb_alu_result <= 0;
		mem_wb_write_reg <= 0;
		mem_wb_mem_to_reg <= 0;
		mem_wb_reg_write <= 0;
	end else begin
		mem_wb_mem_data <= mem_data;
                mem_wb_alu_result <= ex_mem_alu_result;
                mem_wb_write_reg <= ex_mem_write_reg;
                mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
                mem_wb_reg_write <= ex_mem_reg_write;
	end
end

// === WB: Write Back ===
// wire [31:0] write_data_wb;
assign write_data_wb = mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result;
assign write_reg_wb = mem_wb_write_reg;

endmodule

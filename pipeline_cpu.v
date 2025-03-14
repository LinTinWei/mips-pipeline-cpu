module pipeline_cpu(
	input clk,
	input rst
);

// === IF: Instruction Fetch ===
wire [31:0] pc, pc_next, instruction;
reg [31:0] pc_reg;

// === 分支預測
wire predicted_taken;
wire actual_taken;
wire mispredict;
wire [31:0] branch_target;
wire is_jump;
wire [31:0] jump_target;

// PC 和 指令記憶體
instruction_memory imem(
	.pc(pc_reg),
	.instruction(instruction)
);

// Prgram counter refresh
always @(posedge clk or posedge rst) begin
	if (rst) begin
		pc_reg <= 0;		// Reset 時將 PC 設為 0
	end else begin
		pc_reg <= pc_next;	// 每個時鐘週期更新 PC
	end
end

// Branch Prediction Unit (BHT)
branch_prediction bp (
	.clk(clk),
	.rst(rst),
	.branch(branch),
	.branch_taken(branch_taken),
	.pc(pc_reg),
	.predicted_taken(predicted_taken)
);

// 計算跳轉地址
assign branch_target = if_id_pc + (sign_ext_imm << 2);
assign jump_target = {if_id_pc[31:28], if_id_instruction[25:0], 2'b00};

// 判斷是否為 Jump 指令
assign is_jump = (if_id_instruction[31:26] == 6'b000010);	// opcode = 000010 for `j`

// 修正 mispredict: 若 BHT 預測錯誤修正 PC
assign actual_taken = branch & (read_data1 == read_data2);
assign mispredict = (predicted_taken != actual_taken) & branch;

// PC 更新邏輯
assign pc_next = is_jump ? jump_target:
       		 mispredict ? (actual_taken ? branch_target : pc_reg + 4):	
		(predicted_taken) ? branch_target : pc_reg + 4;

// === 暫停 IF stage 直到分之確定結果
// wire stall, branch;
// assign stall = branch & (read_data1 == read_data2);

/*
// === 靜態分支預測 (預測 Not Taken)
// wire predicted_taken;
// assign predicted_taken = 0;	// 靜態預測: 預測 branch 不跳轉
*/

// IF/ID 暫存器
reg [31:0] if_id_pc, if_id_instruction;
always @(posedge clk or posedge rst) begin
	if (rst || mispredict) begin
		if_id_pc <= 0;
		if_id_instruction <= 0; // 錯誤預測時, 清除 IF/ID
	end else begin
		if_id_pc <= pc_reg;
		if_id_instruction <= instruction;
	end
end

// === ID: Instruction Decode ===
wire [4:0] rs, rt, rd;
wire [31:0] read_data1, read_data2, sign_ext_imm;
wire reg_write, reg_dst, alu_src, mem_read, mem_write, jump, mem_to_reg;
wire [2:0] alu_control;

assign flush = (predicted_taken != (read_data1 == read_data2)) & branch; // BEQ 成立時 Flush


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
	.write_reg(write_reg_wb),	// 來自於 WB 階段
	.write_data(write_data_wb),	// 來自於 WB 階段
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

// === EX: Execution (ALU 計算) ===
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

// Write Register 選擇
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

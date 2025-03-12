module forwarding_unit(
	input [4:0] ex_rs, ex_rt,		// EX stage 的來源暫存器 Rs, Rt
	input [4:0] mem_wb_write_reg, ex_mem_write_reg,	// MEM, WB stage 的目標暫存器
	input mem_wb_reg_write, ex_mem_reg_write,	// MEM, WB stage 的 RegWrite 信號
	output reg [1:0] forward_a, forward_b	// 轉發選擇信號
);

always @(*) begin
	// 預設: 不進行轉發
	forward_a = 2'b00;
	forward_b = 2'b00;
	$display("ex_mem_reg_write: %b, mem_wb_reg_write: %b", ex_mem_reg_write, mem_wb_reg_write);
	$display("ex_mem_write_reg: %b, mem_wb_write_reg: %b", ex_mem_write_reg, mem_wb_write_reg);
	$display("ex_rs: %b, ex_rt: %b", ex_rs, ex_rt);


	// Forwarding A: EX 的 Rs 來自 EM/MEM stage 的 ALU 結果
	if (ex_mem_reg_write && (ex_mem_write_reg != 0) && (ex_mem_write_reg == ex_rs)) begin
		forward_a = 2'b10;
	end

	// Forwarding A: EX 的 Rs 來自 MEM/WB stage 的 ALU 結果
	else if (mem_wb_reg_write && (mem_wb_write_reg != 0) && (mem_wb_write_reg == ex_rs)) begin
		forward_a = 2'b01;
	end
	
	// Forwarding B: EX 的 Rt 來自 EX/MEM stage 的 ALU 結果
	if (ex_mem_reg_write && (ex_mem_write_reg != 0) && (ex_mem_write_reg == ex_rt)) begin
		forward_b = 2'b10;
	end

	// Forwarding B: EX 的 Rt 來自 MEM/WB stage 的 ALU 結果
	else if (mem_wb_reg_write && (mem_wb_write_reg != 0) && (mem_wb_write_reg == ex_rt)) begin
		forward_b = 2'b01;
	end
	$display("forward_a: %b, forward_b: %b", forward_a, forward_b);
end
endmodule

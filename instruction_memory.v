module instruction_memory(
	input [31:0] pc,	// 從 PC 中取得的地址
	output reg [31:0] instruction	// 取出的指令
);
reg [31:0] memory [0:255];	// 256 個 32-bit 指令空間(可放 256 條 MIPS 指令)
integer i;			// 在模組頂部聲明變數, 避免語法錯誤

initial begin
        $readmemh("instructions.mem", memory);  // 從文件中讀取指令
	for (i = 0; i < 16; i = i + 1) begin
		$display("Memory[%0d] = %h", i, memory[i]);	// 顯示初始記憶體內容
	end
end

// 根據 PC 提供對應的指令 (pc >> 2 獲取指令地址)

always @(*) begin
	if (pc > 0) begin
		instruction = #1 memory[pc >> 2];	// 取出對應指令 (每個指令 4 bytes)
	end else begin
		instruction = #1 memory[0];
	end
end
endmodule

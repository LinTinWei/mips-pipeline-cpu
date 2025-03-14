module branch_prediction (
	input clk,
	input rst,
	input branch,			// 這條指令是否是 branch 指令
	input branch_taken,		// 這條指令最終是否跳轉
	input [31:0] pc,		// 當前指令的 PC
	output wire predicted_taken	// 輸出預測結果
);

	// 256-entry Branch History Table(BHT), 每個 entry 2-bit
	reg [1:0] BHT [0:255];

	// 取 PC 低 8-bit 作為 BHT 索引
	wire [7:0] branch_index = pc[9:2];

	// 讀取預測值 (若 BHT[branch_index] >= 2'b10，則預測 Taken)
    	assign predicted_taken = (BHT[branch_index] >= 2'b10);

    	// 初始化 BHT (僅限模擬)
    	integer i;
    	initial begin
        	for (i = 0; i < 256; i = i + 1)
            		BHT[i] = 2'b00;  // 預設所有分支都是 Not Taken
    	end

    	// 更新 BHT (每當分支指令執行後)
    	always @(posedge clk or posedge rst) begin
        	if (rst) begin
            		for (i = 0; i < 256; i = i + 1)
                		BHT[i] <= 2'b00;  // Reset 時將所有分支預測設為 Not Taken
        	end else if (branch) begin
            		if (branch_taken) begin
                		if (BHT[branch_index] != 2'b11)  // 避免超過 2'b11
                    			BHT[branch_index] <= BHT[branch_index] + 1;
            		end else begin
                		if (BHT[branch_index] != 2'b00)  // 避免超過 2'b00
                    			BHT[branch_index] <= BHT[branch_index] - 1;
			end
        	end
    	end
	endmodule

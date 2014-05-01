module cache_tb();

reg clk, rst_n, i_acc, d_rd_acc, d_wr_acc;
reg [15:0] i_addr, d_addr, d_wrt_data;

wire stall, instr_rdy, data_rdy;
wire [15:0] instr, data;

mem_hierarchy mem(clk, rst_n, i_acc, d_rd_acc, d_wr_acc, i_addr, d_addr, d_wrt_data, stall, instr_rdy, data_rdy, instr, data);

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	i_acc = 1'b0;
	d_rd_acc = 1'b0;
	d_wr_acc = 1'b0;
	
	#2;
	rst_n = 1'b1;
end

always #1 clk = ~clk;

initial begin
	d_wr_acc = 1'b1;
	d_addr = 16'h0004;
	d_wrt_data = 16'hB00B;
	@(data);
	//@(posedge clk);
	d_wr_acc = 1'b0;
	d_rd_acc = 1'b1;
	d_addr = 16'h5505;
	//d_wrt_data = 16'hcafe;
	@(data);
	//@(data);
	//i_acc = 1'b1;
	//d_wr_acc = 1'b0;
//	i_addr = 16'h0000;
end

endmodule

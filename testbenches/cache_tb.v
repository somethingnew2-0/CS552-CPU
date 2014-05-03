module cache_tb();

reg clk, rst_n, i_acc, d_rd_acc, d_wr_acc;
reg [15:0] i_addr, d_addr, d_wrt_data;

wire stall, instr_rdy, data_rdy;
wire [15:0] instr, data;

mem_hierarchy mem(clk, rst_n, i_acc, d_rd_acc, d_wr_acc, i_addr, d_addr, d_wrt_data, stall, instr, data);

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
	#2; // I Miss, D RD Miss
	i_acc = 1'b1;
	d_rd_acc = 1'b1;
	i_addr = 16'h5555;
	d_addr = 16'h0000;
	#19; // I Hit, D RD Hit 
	d_addr = 16'h0002;
	i_addr = 16'h5557;
	#2; // I Hit, D RD Miss 
	d_addr = 16'h0004; 
	i_addr = 16'h5557;
	#10; // I Miss, D WR Hit 
	d_addr = 16'h0005;
	d_rd_acc = 1'b0;
	d_wr_acc = 1'b1;
	d_wrt_data = 16'hB00B;
	i_addr = 16'h5558;
	#10;	// I Hit, D WR Miss (dirty!)
	d_addr = 16'h3305;
	#12; // I Hit, D RD Miss (clean)
	d_rd_acc = 1'b1;
	d_wr_acc = 1'b0;
	d_addr = 16'h0008;
	#10; // I Miss, D RD Miss (dirty!) (65 ns)
	i_addr = 16'h3333;
	d_addr = 16'h4405;
	//d_wr_acc = 1'b1;
	//d_rd_acc = 1'b0;
	//d_wrt_data = 16'hcafe;
	//#2;
	//d_wr_acc = 1'b0;
	//d_rd_acc = 1'b1;
	//d_addr = 16'h3355;
	//@(data);
	//@(data);
	//i_acc = 1'b1;
	//d_wr_acc = 1'b0;
//	i_addr = 16'h0000;
end

endmodule

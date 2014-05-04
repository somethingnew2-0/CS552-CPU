module CPU_tb();

reg clk, rst_n;
wire hlt;
wire [15:0] addr;

cpu iDUT(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(addr));

initial begin
	clk = 1'b1;

	rst_n = 1'b0;
	#1;
	rst_n = 1'b1;
end

always #1 clk = ~clk; 
 
endmodule

module CPU_tb();

reg clk, rst_n;
wire hlt;

CPU iDUT(.clk(clk), .rst_n(rst_n), .hlt(hlt));

initial begin
	clk = 1'b0;

	rst_n = 0;
	#1;
	rst_n = 1;
end

always #1 clk = ~clk; 
 
endmodule

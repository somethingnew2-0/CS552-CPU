module CPU_tb();

reg clk, rst_n;
wire hlt, Z, N, V;
wire [3:0] dst_addr;
wire [15:0] dst, addr;

CPU iDUT(.clk(clk), .rst_n(rst_n), .hlt(hlt), .dst(dst), .iaddr(addr), .N(N), .V(V), .Z(Z), .dst_addr(dst_addr));

initial begin
	clk = 1'b0;

	rst_n = 1'b1;
	#1;
	rst_n = 1'b0;
	#1;
	rst_n = 1'b1;
end

always #1 clk = ~clk; 
 
endmodule

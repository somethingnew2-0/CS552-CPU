module CPU_tb();

reg clk, rst_n;
wire hlt;

CPU iDUT(.clk(clk), .rst_n(rst_n), .hlt(hlt));


initial begin
	rst_n = 0;
	#20;
	rst_n = 1;
end

initial begin 
 clk = 1'b0; 
 forever #10 clk = !clk; 
end 

endmodule
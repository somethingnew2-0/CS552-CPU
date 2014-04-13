module PC(clk, rst_n, hlt, pc, nextPC);
  
	input [15:0] nextPC;
  input clk, rst_n, hlt;
  output reg [15:0] pc;

  always @(posedge clk or negedge rst_n)
    if(!rst_n)
      pc <= 16'h0000;
    else if (!hlt)
      pc <= nextPC;
	 	else
			pc <= pc;
endmodule  
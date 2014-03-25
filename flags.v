// Matthew Wiemer, Luke Brandl, Peter Collins

// Delays signals by one instruction
module flags (clk, rst_n, zr, ov, ne, Z, V, N);

	input clk, rst_n, zr, ov, ne;
	output reg Z, V, N;

  always @ (posedge clk or negedge rst_n)
  	if(!rst_n) begin
      Z <= 1'b0;
			V <= 1'b0;
			N <= 1'b0;
		end
   	else begin
      Z <= zr;
			V <= ov; // These go back to ID for the next instruction
			N <= ne;
		end

endmodule

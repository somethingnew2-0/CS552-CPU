// Peter Collins, Matthew Wiemer, Luke Brandl
// Delays signals by one instruction
module flags (clk, rst_n, zr, ov, ne, oldZr, oldOv, oldNe);

	input clk, rst_n, zr, ov, ne;
	output reg oldZr, oldOv, oldNe;

  always @ (posedge clk or negedge rst_n)
  	if(!rst_n) begin
      oldZr <= 1'b0;
			oldOv <= 1'b0;
			oldNe <= 1'b0;
		end
   	else begin
      oldZr <= zr;
			oldOv <= ov; // These go back to ID for the next instruction
			oldNe <= ne;
		end
endmodule

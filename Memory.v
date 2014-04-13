module Memory(clk,memaddr_EX_MEM,re_EX_MEM,we_EX_MEM,wrt_data_EX_MEM,rd_data_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM, instr_EX_MEM, flush, branch);
	input clk, re_EX_MEM, we_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM, flush, branch;
	input [15:0] memaddr_EX_MEM, wrt_data_EX_MEM, instr_EX_MEM;

	output [15:0] rd_data_MEM;	//output of data memory

	wire zr, ne, ov, finalwe;
	wire [15:0] instr;

	// Branch Codes, straight off the quick reference
	localparam neq 		= 3'b000;
	localparam eq 		= 3'b001;
	localparam gt 		= 3'b010;
	localparam lt 		= 3'b011;
	localparam gte 		= 3'b100;
	localparam lte 		= 3'b101;
	localparam ovfl 	= 3'b110;
	localparam uncond = 3'b111;

	assign finalwe = flush & we_EX_MEM; 

	assign zr = zr_EX_MEM;
	assign ne = ne_EX_MEM;
	assign ov = ov_EX_MEM;
	assign instr = instr_EX_MEM;

	DM dm(.clk(clk),
				.addr(memaddr_EX_MEM),
				.re(re_EX_MEM),
				.we(final_we),
				.wrt_data(wrt_data_EX_MEM),
				.rd_data(rd_data_MEM));

	assign branch =		  ( (instr[11:9] == uncond) |
  				((instr[11:9] == neq) && !zr) |
  				((instr[11:9] == eq) && zr) |
  				((instr[11:9] == gt) && !(zr || ne)) |
  				((instr[11:9] == lt) && ne) |
  				((instr[11:9] == gte) && !ne) |
  				((instr[11:9] == lte) && (ne || zr)) |
  				((instr[11:9] == ovfl) && ov) );		

endmodule

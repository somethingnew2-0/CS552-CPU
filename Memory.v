module Memory(clk,memAddr_EX_MEM,re_EX_MEM,we_EX_MEM,wrt_data_EX_MEM,rd_data_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM, branchOp_EX_MEM, flush, branch);
	input clk, re_EX_MEM, we_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM, flush, branch;
	input [15:0] memAddr_EX_MEM, wrt_data_EX_MEM;
	input [2:0] branchOp_EX_MEM;

	output [15:0] rd_data_MEM;	//output of data memory

	wire zr, ne, ov, finalWe;
	wire [15:0] branchOp;

	// Branch Codes, straight off the quick reference
	localparam neq 		= 3'b000;
	localparam eq 		= 3'b001;
	localparam gt 		= 3'b010;
	localparam lt 		= 3'b011;
	localparam gte 		= 3'b100;
	localparam lte 		= 3'b101;
	localparam ovfl 	= 3'b110;
	localparam uncond = 3'b111;

	assign finalWe = flush & we_EX_MEM; 

	assign zr = zr_EX_MEM;
	assign ne = ne_EX_MEM;
	assign ov = ov_EX_MEM;
	assign branchOp = branchOp_EX_MEM;

	DM dm(.clk(clk),
				.addr(memAddr_EX_MEM),
				.re(re_EX_MEM),
				.we(finalWe),
				.wrt_data(wrt_data_EX_MEM),
				.rd_data(rd_data_MEM));

	assign branch =		  ( (branchOp[11:9] == uncond) |
  				((branchOp[11:9] == neq) && !zr) |
  				((branchOp[11:9] == eq) && zr) |
  				((branchOp[11:9] == gt) && !(zr || ne)) |
  				((branchOp[11:9] == lt) && ne) |
  				((branchOp[11:9] == gte) && !ne) |
  				((branchOp[11:9] == lte) && (ne || zr)) |
  				((branchOp[11:9] == ovfl) && ov) );		

endmodule

module IF(pc, clk, instr, stall, baddr, branch, pcp1);

	input clk, branch, stall;
	input [15:0] pc, baddr;

	output [15:0] pcp1, instr; 

	wire [15:0] effectivepc;

	assign effectivepc = (branch)? baddr : pc;
	assign pcp1 = (stall)? effectivepc : effectivepc + 1;
	

  IM im(.addr(effectivepc),
				.clk(clk),
				.rd_en(1'b1),
 				
				.instr(instr));



endmodule


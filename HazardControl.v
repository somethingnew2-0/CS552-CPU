module HazardControl(branch, branchInit, forwardStall, flush, stall);
	input branch, branchInit, forwardStall;

	output flush, stall;

	assign flush = branchInit ? branch: 1'b0;

	assign stall = branchInit ? forwardStall : 1'b0;

endmodule

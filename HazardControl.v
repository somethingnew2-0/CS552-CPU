module HazardControl(branch, branchInit, flush);
	input branch, branchInit;

	output flush;

	assign flush = branchInit ? branch: 1'b0;

endmodule

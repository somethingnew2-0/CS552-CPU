module HazardControl(branch, flush)
	input branch;

	output flush;

	assign flush = branch;


endmodule

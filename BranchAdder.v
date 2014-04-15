// Peter Collins, Matthew Wiemer, Luke Brandl
module BranchAdder(pc, offset, result);
  input [15:0] pc;
  input [8:0] offset;

  output [15:0] result;

  // Set Result
  assign result = pc+{{7{offset[8]}},offset};
  
endmodule

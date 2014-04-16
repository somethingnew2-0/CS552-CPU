// Peter Collins, Matthew Wiemer, Luke Brandl
module BranchAdder(pcNext, offset, result);
  input [15:0] pcNext;
  input [8:0] offset;

  output [15:0] result;

  // Set Result
  assign result = pcNext+{{7{offset[8]}},offset};
  
endmodule

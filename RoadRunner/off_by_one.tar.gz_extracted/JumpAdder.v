// Peter Collins, Matthew Wiemer, Luke Brandl
module JumpAdder(pcNext, offset, result);
  input [15:0] pcNext;
  input [11:0] offset;

  output [15:0] result;

  // Set Result
  assign result = pcNext+{{4{offset[11]}},offset};
  
endmodule

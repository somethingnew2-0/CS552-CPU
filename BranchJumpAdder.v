// Peter Collins, Matthew Wiemer, Luke Brandl
module BranchJumpAdder(jal, pcNext, branchOffset, jumpOffset, result);
  input jal;
  input [15:0] pcNext;
  input [8:0] branchOffset;
  input [11:0] jumpOffset;

  output [15:0] result;

  // Set Result
  assign result = pcNext+(jal?{{4{jumpOffset[11]}},jumpOffset}:{{7{branchOffset[8]}},branchOffset});

endmodule

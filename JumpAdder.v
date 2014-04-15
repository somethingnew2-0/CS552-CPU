// Peter Collins, Matthew Wiemer, Luke Brandl
module JumpAdder(pc, offset, result);
  input [15:0] pc;
  input [11:0] offset;

  output [15:0] result;

  // Set Result
  assign result = pc+{{4{offset[11]}},offset};
  
endmodule

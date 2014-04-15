// Peter Collins, Matthew Wiemer, Luke Brandl
module JumpAdder(addr, offset, result);
  input [15:0] addr, offset;

  output [15:0] result;

  // Set Result
  assign result = addr+offset;
  
endmodule

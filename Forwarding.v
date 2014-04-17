module Forwarding(p0, p1, forwardP0, forwardP1);
  input [15:0] p0, p1;
  output [15:0] forwardP0, forwardP1;

  assign forwardP0 = p0;
  assign forwardP1 = p1;

endmodule

module HazardControl(clk, rst_n, branch, branchInit, forwardStall, flush, stall);
  input clk, rst_n, branch, branchInit, forwardStall;

  output flush;
  output reg stall;

  assign flush = branchInit ? branch: 1'b0;

  always @(negedge clk or negedge rst_n) begin
    if(!rst_n) 
      stall <= 1'b0;
    else if(branchInit)
      stall <= forwardStall;
    else 
      stall <= 1'b0;
  end

endmodule

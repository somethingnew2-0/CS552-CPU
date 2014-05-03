module HazardControl(clk, rst_n, branch, branchInit, forwardStall, flush, stall);
  input clk, rst_n, branch, branchInit, forwardStall;

  output flush;
  output reg stall;

  assign flush = branchInit ? branch: 1'b0;

  always @(negedge clk or negedge rst_n) begin
    if(!rst_n) begin
      stall <= 1'b0;
    end 
    else begin
      if(branchInit) begin
        stall <= forwardStall;
      end
      else  begin
        stall <= 1'b0;
      end
    end
  end

endmodule

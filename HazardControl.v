module HazardControl(clk, rst_n, branch, branchInit, forwardStall, cacheStall, flush, stall);
  input clk, rst_n, branch, branchInit, forwardStall, cacheStall;

  output flush;
  output reg stall;

  assign flush = branchInit ? branch: 1'b0;

  always @(negedge clk or negedge rst_n) begin
    if(!rst_n) begin
      stall <= 1'b0;
    end 
    else begin
      if(branchInit) begin
        stall <= forwardStall | cacheStall;
      end
      else  begin
        stall <= cacheStall;
      end
    end
  end

endmodule

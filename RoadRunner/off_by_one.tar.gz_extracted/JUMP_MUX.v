module JUMP_MUX(jr, p0, nextAddr, nextPC);
  input jr;
  input[15:0] p0, nextAddr;
  output[15:0] nextPC;
  
  assign nextPC = jr ? p0 : nextAddr;
  
endmodule

module SRC_MUX(p1, imm, src1sel, memOp, src1);
  input[15:0] p1;
  input[7:0] imm;
  input src1sel, memOp;
  output[15:0] src1;
  
  assign src1 = memOp ? {{12{imm[3]}},imm[3:0]} :
								src1sel ? {imm, 8'h00} :								 
								p1;
  
endmodule
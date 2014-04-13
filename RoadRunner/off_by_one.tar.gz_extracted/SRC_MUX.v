module SRC_MUX(p0, p1, imm, src0sel, memOp, src0, src1);
  input[15:0] p0, p1;
  input[7:0] imm;
  input src0sel, memOp;
  output[15:0] src0, src1;
  
  assign src0 = src0sel ? {{8{imm[7]}},imm[7:0]} :								 
								p0;
	assign src1 = memOp ? {{12{imm[3]}},imm[3:0]} :
								p1;
  
endmodule
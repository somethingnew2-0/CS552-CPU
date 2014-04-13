module WB_MUX(jal, memtoreg, pc, memdst, dst, finaldst);
  input jal, memtoreg;
  input[15:0] pc, memdst, dst;
  output[15:0] finaldst;

	assign finaldst = jal ? pc + 16'b1 : 
										memtoreg ? memdst: dst;  
  
endmodule

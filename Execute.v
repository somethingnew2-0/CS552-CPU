module Execute(p0, p1, imm, shamt, aluOp, aluSrc0, aluSrc1, aluOv, ov_EX, zr_EX, ne_EX, result);
  input[15:0] p0, p1;
  input[7:0] imm;
 	input [3:0] shamt;
  input [2:0] aluOp;
  
  // Control signals
  input aluSrc0, aluSrc1, aluOv;

	output oldOv, oldZr, oldNe;
  output [15:0] result;

  wire [15:0] src0, src1;

  SRC_MUX srcmux(.p0(p0),
                 .p1(p1), 
								 .imm(imm), 
         							 .aluSrc0(aluSrc0),
								 .aluSrc1(aluSrc1),
								 .src0(src0),
                 .src1(src1));

  ALU alu(.src0(src0), 
					.src1(src1), 
					.ctrl(func), 
					.shamt(shamt),
					.aluOp(aluOp),
					.result(result), 
					.ov(ov), 
					.ne(ne),
					.zr(zr)); 
					
	//BranchAdder()
	
	//JumpAdder()

/*	flags flags(.clk(clk),
							.rst_n(rst_n),
							.ov(ov),
							.ne(ne),
							.zr(zr),
							.oldOv(oldOv),				
							.oldNe(oldNe),
							.oldZr(oldZr));*/
endmodule

module Execute(p0, p1, imm, shamt, aluOp, aluSrc0, aluSrc1, aluOv, ov, zr, ne, aluResult, branchResult, jumpResult);
  input[15:0] p0, p1;
  input[7:0] imm;
 	input [3:0] shamt;
  input [2:0] aluOp;
  
  // Control signals
  input aluSrc0, aluSrc1, aluOv;

	output ov, zr, ne;
  output [15:0] aluResult, branchResult, jumpResult;

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
					.ctrl(aluOp), 
					.shamt(shamt),
					.result(aluResult), 
					.ov(ov), 
					.ne(ne),
					.zr(zr)); 
					
	BranchAdder branchadder(.result(branchResult));
	
	JumpAdder jumpadder(.result(jumpResult));

endmodule

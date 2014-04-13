module Execute(p0, p1, imm, src0sel, func, shamt, memOp, aluOp, oldOv, oldZr, oldNe, result);
  input[15:0] p0, p1;
  input[7:0] imm;
 	input [3:0] shamt;
  input [2:0] func;
  input src0sel, memOp, aluOp;

	output oldOv, oldZr, oldNe;
  output [15:0] result;

  wire [15:0] src0, src1;

  SRC_MUX srcmux(.p0(p0),
                 .p1(p1), 
								 .imm(imm), 
								 .src0sel(src0sel),
 								 .memOp(memOp),
								 .src0(src0),
                 .src1(src1));

  ALU alu(.src0(src0), 
					.src1(src1), 
					.ctrl(func), 
					.shamt(shamt),
					.aluOp(aluOp),
					.oldOv(oldOv),
					.oldNe(oldNe),
					.oldZr(oldZr), 
					.result(result), 
					.ov(ov), 
					.ne(ne),
					.zr(zr)); 

	flags flags(.clk(clk),
							.rst_n(rst_n),
							.ov(ov),
							.ne(ne),
							.zr(zr),
							.oldOv(oldOv),				
							.oldNe(oldNe),
							.oldZr(oldZr));
endmodule

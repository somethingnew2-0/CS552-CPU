module InstructionDecode(instr, clk, dstAddr, dst, dstWe, p0, p1, imm, regAddr, shamt, aluOp, branchOp, regWe, memRe, memWe, memToReg, jal, jr, hlt, aluSrc0, aluSrc1, ovEn, zrEn, neEn);
  input [15:0] instr;

  // For register writeback
  input clk;
  input [3:0] dstAddr;					// write address
  input [15:0] dst;						// dst bus
  input dstWe;

  output [15:0] p0, p1;
  output [11:0] imm;
  output [3:0] regAddr, shamt;
  output [2:0] aluOp, branchOp;

  // Control signals
  output regWe, memRe, memWe, memToReg, jal, jr, hlt, aluSrc0, aluSrc1, ovEn, zrEn, neEn;

  wire [3:0] p0Addr, p1Addr;

	ID id(.instr(instr),
	
        .imm(imm),
				.p0Addr(p0Addr), 
				.p1Addr(p1Addr), 
				.regAddr(regAddr), 
				.shamt(shamt),
				.aluOp(aluOp),
				.branchOp(branchOp),
				.regRe0(regRe0), 
				.regRe1(regRe1), 
				.regWe(regWe), 
				.memRe(memRe),
				.memWe(memWe),
				.memToReg(memToReg),
				.jal(jal),
				.jr(jr),
 				.hlt(hlt), 
			  .aluSrc0(aluSrc0),	
				.aluSrc1(aluSrc1),
				.ovEn(ovEn), 
				.zrEn(zrEn), 
				.neEn(neEn)
				);

  rf rf(.clk(clk), 
				.p0_addr(p0Addr), 
				.p1_addr(p1Addr), 
				.re0(regRe0), 
				.re1(regRe1), 
				.dst_addr(dstAddr), 
				.dst(dst), 
				.we(dstWe), 
				.hlt(hlt), 
				.p0(p0), 
				.p1(p1)
				);

endmodule;
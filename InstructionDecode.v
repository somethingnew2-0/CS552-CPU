module InstructionDecode(instr, imm, shamt, aluOp, branchOp, regWe, memRe, memWe, memToReg, jal, jr, hlt, aluSrc0, aluSrc1, ovEn, zrEn, neEn);
	ID id(.instr(instr),
	
        .imm(imm_ID_EX),
				.p0Addr(p0Addr), 
				.p1Addr(p1Addr), 
				.regAddr(regAddr), 
				.shamt(shamt_ID_EX),
				.aluOp(aluOp_ID_EX),
				.branchOp(branchOp_ID_EX),
				.regRe0(regRe0), 
				.regRe1(regRe1), 
				.regWe(regWe), 
				.memRe(memRe),
				.memWe(memWe),
				.memToReg(memToReg),
				.jal(jal),
				.jr(jr),
 				.hlt(hlt), 
			  .aluSrc0(aluSrc0_ID_EX),	
				.aluSrc1(aluSrc1_ID_EX),
				.ovEn(ovEn_ID_EX), 
				.zrEn(zrEn_ID_EX), 
				.neEn(neEn_ID_EX)
				);

  rf rf(.clk(clk), 
				.p0_addr(p0_addr), 
				.p1_addr(p1_addr), 
				.re0(regRe0), 
				.re1(regRe1), 
				.dst_addr(regAddr), 
				.dst(finaldst), 
				.we(regWe), 
				.hlt(hlt), 
				.p0(p0_ID_EX), 
				.p1(p1_ID_EX)
				);

endmodule;
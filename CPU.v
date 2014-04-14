module CPU(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
	output hlt; //Assuming these are current flag states
	output [15:0] pc;

  wire [15:0] instr, nextAddr, nextPC, memdst, finaldst, p0_ID_EX, p1_ID_EX, result_EX_DM;
  wire [3:0] p0Addr, p1Addr, regAddr, shamt_ID_EX;
  wire [2:0] aluOp_ID_EX, branchOp_ID_EX;

  assign rd_en = 1'b1; // When should this change?

/* The pipeline. Each blank line separates inputs from
		outputs of the module */

  PC programCounter(.clk(clk),  
				.hlt(hlt),
				.rst_n(rst_n),
				.nextPC(nextPC), 
				.pc(pc));

  IM im(.addr(pc),
				.clk(clk),
				.rd_en(rd_en),
 				
				.instr(instr));

	ID id(.instr(instr),
	
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
				.aluSrc1(aluSrc1_ID_EX)
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

	JUMP_MUX jumpmux(.jr(jr), .p0(IM_EX_p0), .nextAddr(nextAddr), .nextPC(nextPC));

	Execute execute(.p0(p0_ID_EX),
                  .p1(p1_ID_EX),
                  .imm(imm_ID_EX),
                  .shamt(shamt_ID_EX),
                  .aluOp(aluOp_ID_EX),
                  .aluSrc0(aluSrc0_ID_EX),
                  .aluSrc1(aluSrc1_ID_EX),
                  .aluOv(aluOv_ID_EX),
                  .ov_EX(ov_EX),
                  .zr_EX(zr_EX),
                  .ne_EX(ne_EX),
                  .result(result_EX_DM));

	DM dm(.clk(clk),
				.addr(EX_DM_dst),
				.re(memre),
				.we(memwe),
				.wrt_data(p1),
				.rd_data(memdst));

	WB_MUX wbmux(.jal(jal), 
							 .pc(pc),
							 .memtoreg(memtoreg),
							 .memdst(memdst),
							 .dst(dst),
							 .finaldst(finaldst));

endmodule

module CPU(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
	output hlt; //Assuming these are current flag states
	output [15:0] pc;

  wire [15:0] instr, nextAddr, nextPC, memdst, finaldst, IM_EX_p0, IM_EX_p1, EX_DM_result;
  wire [3:0] p0_addr, p1_addr, dst_addr, shamt;
  wire [2:0] func;
  wire ov, zr, ne, aluOp, rd_en, memwe, memre, memtoreg, memOp;
  wire re0, re1, we, jal, jr, hlt, src0sel;

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
				.addr(pc + 16'b1), /* Branch base is the current instruction + 1 */
				.zr(EX_ID_oldZr),
				.ne(EX_ID_oldNe),
				.ov(EX_ID_oldOv),
 
				.aluOp(ID_EX_aluOp),
				.nextAddr(nextAddr),
				.dst_addr(dst_addr), 
				.func(ID_EX_func),
				.jal(jal),
				.jr(jr),
 				.hlt(hlt), 
				.p0_addr(p0_addr), 
				.re0(re0), 
				.p1_addr(p1_addr), 
				.re1(re1), 
				.we(we), 
				.memwe(memwe),
				.memre(memre),
			  .memOp(ID_EX_memOp),	
				.src0sel(ID_EX_src0sel), 
				.shamt(ID_EX_shamt),
				.memtoreg(memtoreg)
				);

  rf rf(.clk(clk), 
				.p0_addr(p0_addr), 
				.p1_addr(p1_addr), 
				.re0(re0), 
				.re1(re1), 
				.dst_addr(dst_addr), 
				.dst(finaldst), 
				.we(we), 
				.hlt(hlt), 
				.p0(IM_EX_p0), 
				.p1(p1));

	JUMP_MUX jumpmux(.jr(jr), .p0(IM_EX_p0), .nextAddr(nextAddr), .nextPC(nextPC));

	Execute execute(.p0(ID_EX_p0),
                  .p1(ID_EX_p1),
                  .imm(ID_EX_imm),
                  .src0sel(ID_EX_src0sel),
                  .func(ID_EX_func),
                  .shamt(ID_EX_shamt),
                  .memOp(ID_EX_memOp),
                  .aluOp(ID_EX_aluOp),
                  .oldOv(EX_ID_oldOv),
                  .oldZr(EX_ID_oldZr),
                  .oldNe(EX_ID_oldNe),
                  .result(EX_DM_result));

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

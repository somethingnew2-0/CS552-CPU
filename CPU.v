module CPU(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
	output hlt; //Assuming these are current flag states
	output [15:0] pc;

  wire [15:0] instr, nextAddr, nextPC, memdst, finaldst, p0, p1, src0, src1, dst;
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
				.zr(Z),
				.ne(N),
				.ov(V),
 
				.aluOp(aluOp),
				.nextAddr(nextAddr),
				.dst_addr(dst_addr), 
				.func(func),
				.jal(jal),
				.jr(jr),
 				.hlt(hlt), 
				.p0_addr(p0_addr), 
				.re0(re0), 
				.p1_addr(p1_addr), 
				.re1(re1), 
				.memwe(memwe),
				.memre(memre),
			  .memOp(memOp),
				.we(we), 
				.src0sel(src0sel), 
				.shamt(shamt),
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
				.p0(p0), 
				.p1(p1));

	JUMP_MUX jumpmux(.jr(jr), .p0(p0), .nextAddr(nextAddr), .nextPC(nextPC));

  SRC_MUX srcmux(.p0(p0),
                 .p1(p1), 
								 .imm(instr[7:0]), 
								 .src0sel(src0sel),
 								 .memOp(memOp),
								 .src0(src0),
                 .src1(src1));

  ALU alu(.src0(src0), 
					.src1(src1), 
					.ctrl(func), 
					.shamt(shamt),
					.aluOp(aluOp),
					.old_ov(V),
					.old_ne(N),
					.old_zr(Z), 
					.dst(dst), 
					.ov(ov), 
					.ne(ne),
					.zr(zr)); 

	flags flags(.clk(clk),
							.rst_n(rst_n),
							.ov(ov),
							.ne(ne),
							.zr(zr),							
							.N(N),
							.V(V),
							.Z(Z));

	DM dm(.clk(clk),
				.addr(dst),
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

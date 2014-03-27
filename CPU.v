module CPU(clk, rst_n, hlt, iaddr, dst, dst_addr, Z, N, V);
  input clk; 
  input rst_n;
	output hlt, Z, N, V;
	output [3:0] dst_addr;
	output [15:0] iaddr, dst;

  wire [15:0] iaddr, instr, nextAddr, p1, src0, src1, dst;
  wire [3:0] p0_addr, p1_addr, dst_addr, shamt;
  wire [2:0] func;
  wire ov, zr, ne, aluOp, rd_en, memwe, memre, memtoreg;
  wire re0, re1, we, jal, jr, hlt, src1sel;

  assign rd_en = 1'b1; // When should this change?

/* The pipeline. Each blank line separates inputs from
		outputs of the module */

  PC pc(.clk(clk),  
				.hlt(hlt),
				.rst_n(rst_n),
				.nextAddr(nextAddr),
 
				.iaddr(iaddr));

  IM im(.addr(iaddr),
				.clk(clk),
				.rd_en(rd_en),
 				
				.instr(instr));

	ID id(.instr(instr),
				.addr(iaddr + 16'b1), /* Branch base is the current instruction + 1 */
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
				.we(we), 
				.src1sel(src1sel), 
				.shamt(shamt),
				.memtoreg(memtoreg)
				);

  SRC_MUX srcmux(.p1(p1), 
								 .imm(instr[7:0]), 
								 .src1sel(src1sel),
 
								 .src1(src1));

  rf rf(.clk(clk), 
				.p0_addr(p0_addr), 
				.p1_addr(p1_addr), 
				.re0(re0), 
				.re1(re1), 
				.dst_addr(dst_addr), 
				.dst(finaldst), 
				.we(we), 
				.hlt(hlt),
 
				.p0(src0), 
				.p1(p1));
  
  ALU alu(.src0(src0), 
					.src1(src1), 
					.ctrl(func), 
					.shamt(shamt),
					.aluOp(aluOp),
					.clk(clk),
					.rst_n(rst_n),
					.old_V(V),
					.old_Z(Z),
					.old_N(N),
 
					.dst(dst), 
					.V(V), 
					.N(N),
					.Z(Z)); 
	DM DM(.clk(clk),
				.addr(dst),
				.re(memre),
				.we(memwe),
				.wrt_data(src1),
				.rd_data(memdst));
	assign finaldst = jal ? iaddr + 16'b1 : 
										memtoreg ? memdst: dst;

endmodule

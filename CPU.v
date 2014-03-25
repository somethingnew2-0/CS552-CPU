module CPU(clk, rst_n, hlt);
  input clk; 
  input rst_n;
	output hlt;
  
  wire rd_en;  
  wire [15:0] iaddr, instr, p1, src0, src1, dst;
  wire ov, zr;

  wire [3:0] p0_addr, p1_addr, dst_addr, shamt;

  wire re0, re1, we, hlt, src1sel;
  wire [2:0] func;

	reg zreg;

  always @ (posedge clk or negedge rst_n)
  	if(!rst_n)
      zreg <= 1'b0;
   	else
      zreg <= zr;
    
  assign rd_en = 1'b1;

/* The pipeline. The blank line separates inputs from
		outputs of each stage */

  PC pc(.clk(clk),  
				.hlt(hlt),
				.rst_n(rst_n),
 
				.iaddr(iaddr));

  IM im(.addr(iaddr),
				.clk(clk),
				.rd_en(rd_en),
 
				.instr(instr));

	ID id(.instr(instr),
				.zr(zreg),
 
				.dst_addr(dst_addr), 
				.func(func),
 				.hlt(hlt), 
				.p0_addr(p0_addr), 
				.re0(re0), 
				.p1_addr(p1_addr), 
				.re1(re1), 
				.we(we), 
				.src1sel(src1sel), 
				.shamt(shamt));

  SRC_MUX srcmux(.p1(p1), 
								 .instr(instr[7:0]), 
								 .src1sel(src1sel),
 
								 .src1(src1));

  rf rf(.clk(clk), 
				.p0_addr(p0_addr), 
				.p1_addr(p1_addr), 
				.re0(re0), 
				.re1(re1), 
				.dst_addr(dst_addr), 
				.dst(dst), 
				.we(we), 
				.hlt(hlt),
 
				.p0(src0), 
				.p1(p1));
  
  ALU alu(.src0(src0), 
					.src1(src1), 
					.ctrl(func), 
					.shamt(shamt),
 
					.dst(dst), 
					.ov(ov), 
					.zr(zr)); 



endmodule

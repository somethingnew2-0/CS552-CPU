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

  PC pc(.clk(clk),  
				.hlt(hlt), 
				.iaddr(iaddr),
				.rst_n(rst_n));

  IM im(.addr(iaddr),
				.clk(clk), 
				.instr(instr),
				.rd_en(rd_en));

	ID id(.dst_addr(dst_addr), 
				.func(func),
 				.instr(instr), 
				.hlt(hlt), 
				.p0_addr(p0_addr), 
				.re0(re0), 
				.p1_addr(p1_addr), 
				.re1(re1), 
				.we(we), 
				.src1sel(src1sel), 
				.shamt(shamt),
				.zr(zreg),);

  rf rf(.clk(clk), 
				.p0_addr(p0_addr), 
				.p1_addr(p1_addr), 
				.p0(src0), 
				.p1(p1), 
				.re0(re0), 
				.re1(re1), 
				.dst_addr(dst_addr), 
				.dst(dst), 
				.we(we), 
				.hlt(hlt));
  
  ALU alu(.src0(src0), 
					.src1(src1), 
					.ctrl(func), 
					.shamt(shamt), 
					.dst(dst), 
					.ov(ov), 
					.zr(zr)); 

  SRC_MUX srcmux(.p1(p1), 
								 .instr(instr[7:0]), 
								 .src1sel(src1sel), 
								 .src1(src1));

endmodule

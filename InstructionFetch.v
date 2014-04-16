module InstructionFetch(clk, rst_n, hlt, branch, branchAddr, stall, rd_en, pc, instr, pcNext);

  input clk, rst_n, hlt, branch, stall, rd_en;
  input [15:0] branchAddr;

  output reg [15:0] pc;
  output [15:0] instr, pcNext; 

  wire [15:0] effectivePc;

  assign effectivePc = !rst_n ? 16'h0000 :
                       branch ? branchAddr:
                       pc;

  assign pcNext = stall ? effectivePc : effectivePc + 1; 

  always @(posedge clk or negedge rst_n)
    if(!rst_n)
      pc <= 16'h0000;
    else if (!hlt)
      pc <= pcNext;
    else
      pc <= pc;

  IM im(.addr(effectivePc),
        .clk(clk),
        .rd_en(rd_en),
        
        .instr(instr));

endmodule


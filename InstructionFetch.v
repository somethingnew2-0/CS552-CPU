module InstructionFetch(clk, branch, branchAddr, stall, rd_en, pc, instr, pcNext);

  input clk, branch, stall, rd_en;
  input [15:0] pc, branchAddr;

  output [15:0] instr, pcNext; 

  wire [15:0] effectivePc;

  assign effectivePc = branch ? branchAddr : pc;
  assign pcNext = stall ? effectivePc : effectivePc + 1;
  

  IM im(.addr(effectivePc),
        .clk(clk),
        .rd_en(rd_en),
        
        .instr(instr));

endmodule


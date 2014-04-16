module InstructionFetch(clk, branch, branchAddr, stall, pc, instr, pcNext);

  input clk, branch, stall;
  input [15:0] pc, branchAddr;

  output [15:0] instr, pcNext; 

  wire [15:0] effectivePc;

  assign effectivePc = branch ? branchAddr : pc;
  assign pcNext = stall ? effectivePc : effectivePc + 1;
  

  IM im(.addr(effectivePc),
        .clk(clk),
        .rd_en(1'b1),
        
        .instr(instr));

endmodule


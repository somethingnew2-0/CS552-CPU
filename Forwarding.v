module Forwarding(p0, p1, p0Addr, p1Addr, regAddr_EX_MEM, regWe_EX_MEM, aluResult_EX_MEM, jal_EX_MEM, pcNext_EX_MEM, forwardP0, forwardP1);
  input [15:0] p0, p1, aluResult_EX_MEM, pcNext_EX_MEM;
  input [3:0] p0Addr, p1Addr, regAddr_EX_MEM;
  input regWe_EX_MEM, jal_EX_MEM;
  output [15:0] forwardP0, forwardP1;

  assign forwardP0 = (regWe_EX_MEM && (p0Addr == regAddr_EX_MEM)) ? (jal_EX_MEM ? pcNext_EX_MEM : aluResult_EX_MEM) : p0;
  assign forwardP1 = (regWe_EX_MEM && (p1Addr == regAddr_EX_MEM)) ? (jal_EX_MEM ? pcNext_EX_MEM : aluResult_EX_MEM) : p1;

endmodule

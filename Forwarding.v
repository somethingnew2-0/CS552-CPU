module Forwarding(p0, p1, p0Addr, p1Addr, regAddr_EX_MEM, regWe_EX_MEM, aluResult_EX_MEM, jal_EX_MEM, pcNext_EX_MEM, regAddr_MEM_WB, regWe_MEM_WB, aluResult_MEM_WB, jal_MEM_WB, pcNext_MEM_WB, forwardP0, forwardP1);
  input [15:0] p0, p1, aluResult_EX_MEM, pcNext_EX_MEM, aluResult_MEM_WB, pcNext_MEM_WB;
  input [3:0] p0Addr, p1Addr, regAddr_EX_MEM, regAddr_MEM_WB;
  input regWe_EX_MEM, jal_EX_MEM, regWe_MEM_WB, jal_MEM_WB;
  output [15:0] forwardP0, forwardP1;

  assign forwardP0 = (p0Addr == 4'b0000) ? p0 : 
                     (regWe_EX_MEM && (p0Addr == regAddr_EX_MEM)) ? (jal_EX_MEM ? pcNext_EX_MEM : aluResult_EX_MEM) :
                     (regWe_MEM_WB && (p0Addr == regAddr_MEM_WB)) ? (jal_MEM_WB ? pcNext_MEM_WB : aluResult_MEM_WB) :
                      p0;
  assign forwardP1 = (p1Addr == 4'b0000) ? p1 : 
                     (regWe_EX_MEM && (p1Addr == regAddr_EX_MEM)) ? (jal_EX_MEM ? pcNext_EX_MEM : aluResult_EX_MEM) :
                     (regWe_MEM_WB && (p1Addr == regAddr_MEM_WB)) ? (jal_MEM_WB ? pcNext_MEM_WB : aluResult_MEM_WB) :
                      p1;

endmodule

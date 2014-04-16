module Writeback(flush, memToReg_MEM_WB, regWe_MEM_WB, regAddr_MEM_WB, memData_MEM_WB, aluResult_MEM_WB, writeData_WB, writeAddr_WB, writeEnable_WB);
  input flush, memToReg_MEM_WB, regWe_MEM_WB;
  input [3:0] regAddr_MEM_WB;
  input [15:0] memData_MEM_WB, aluResult_MEM_WB;

  output [15:0] writeData_WB;
  output [3:0] writeAddr_WB;
  output writeEnable_WB;  

  assign writeData_WB =  memToReg_MEM_WB ? memData_MEM_WB : aluResult_MEM_WB;

  assign writeAddr_WB = regAddr_MEM_WB;
  assign writeEnable_WB = !flush & regWe_MEM_WB;
  
endmodule

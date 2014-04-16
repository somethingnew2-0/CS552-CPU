module Writeback(flush, memToReg, regWe, regAddr, memData, aluResult, writeData, writeAddr, writeEnable);
  input flush, memToReg, regWe;
  input [3:0] regAddr;
  input [15:0] memData, aluResult;

  output [15:0] writeData;
  output [3:0] writeAddr;
  output writeEnable;  

  assign writeData =  memToReg ? memData : aluResult;

  assign writeAddr = regAddr;
  assign writeEnable = !flush & regWe;
  
endmodule

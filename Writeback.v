module Writeback(flush, jal, memToReg, regWe, regAddr, pcNext, memData, aluResult, writeData, writeAddr, writeEnable);
  input flush, jal, memToReg, regWe;
  input [3:0] regAddr;
  input [15:0] pcNext, memData, aluResult;

  output [15:0] writeData;
  output [3:0] writeAddr;
  output writeEnable;  

  assign writeData =  jal ? pcNext :
                      memToReg ? memData : 
                      aluResult;

  assign writeAddr = regAddr;
  assign writeEnable = !flush & regWe;
  
endmodule

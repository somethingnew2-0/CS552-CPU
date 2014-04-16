module Writeback(memData_MEM_WB, aluResult_MEM_WB, memToReg_MEM_WB, writeData_WB);
	input memToReg_MEM_WB;
	input [15:0] memData_MEM_WB, aluResult_MEM_WB;

	output [15:0] writeData_WB;

	assign writeData_WB =  memToReg_MEM_WB ? memData_MEM_WB : aluResult_MEM_WB;
	
endmodule

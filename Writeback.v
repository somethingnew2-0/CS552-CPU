module Writeback(memData_MEM_WB, result_MEM_WB, MemtoReg_MEM_WB, writeData_WB)
	input MemtoReg_MEM_WB;
	input [15:0] memData_MEM_WB, result_MEM_WB;

	output [15:0] writeData_WB;

	writeData_WB = (MemtoReg)?(memData_MEM_WB) : result_MEM_WB;
	

endmodule

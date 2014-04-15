module CPU(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
	output hlt; //Assuming these are current flag states
	output [15:0] pc;

  wire [15:0] instr, nextAddr, nextPC, memdst, finaldst, p0_ID_EX, p1_ID_EX, aluResult_EX_DM, branchResult_EX_DM, jumpResult_EX_DM;
  wire [11:0] imm_ID_EX;
  wire [3:0] regAddr, shamt_ID_EX;
  wire [2:0] aluOp_ID_EX, branchOp_ID_EX;
	wire flush, branch;

	assign flush = 0'b0;
	assign branch = 0'b0;
  assign rd_en = 1'b1; // When should this change?

/* The pipeline. Each blank line separates inputs from
		outputs of the module */


  IF IF(.addr(pc),
				.clk(clk),
				.rd_en(rd_en),
 				
				.instr(instr));

	InstructionDecode id(
				.instr(instr),
	
        .imm(imm_ID_EX), 
        .regAddr(regAddr_ID_EX),
				.shamt(shamt_ID_EX),
				.aluOp(aluOp_ID_EX),
				.branchOp(branchOp_ID_EX),
				.regWe(regWe), 
				.memRe(memRe),
				.memWe(memWe),
				.memToReg(memToReg),
				.jal(jal),
				.jr(jr),
 				.hlt(hlt), 
			  .aluSrc0(aluSrc0_ID_EX),	
				.aluSrc1(aluSrc1_ID_EX),
				.ovEn(ovEn_ID_EX), 
				.zrEn(zrEn_ID_EX), 
				.neEn(neEn_ID_EX),
				);

	Execute execute(.p0(p0_ID_EX),
                  .p1(p1_ID_EX),
                  .imm(imm_ID_EX),
                  .shamt(shamt_ID_EX),
                  .aluOp(aluOp_ID_EX),
                  .aluSrc0(aluSrc0_ID_EX),
                  .aluSrc1(aluSrc1_ID_EX),
                  .aluOv(aluOv_ID_EX),
                  .ov_EX(ov_EX),
                  .zr_EX(zr_EX),
                  .ne_EX(ne_EX),
                  .aluResult(aluResult_EX), // Luke corrected this one
                  .branchResult(branchResult_EX_DM),
                  .jumpResult(jumpResult_EX_DM));

wire 	[15:0] memaddr_EX_MEM, aluResult_EX_MEM, instr_EX_MEM; // Inputs to Memory from flops
wire		     re_EX_MEM, we_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM; 

wire  [15:0] rdData_MEM;						// Output From Memory

wire  	MemtoReg_EX_MEM;						// Just passing through signals
wire [3:0] regAddr_EX_MEM;				//Just passing through signals
wire 			 regWe_EX_MEM;

//******************************************************
// EX_MEM
//
// ID_EX/EX -> MEM
//
//******************************************************
always
	begin 
		memaddr_EX_MEM <= memaddr_EX; //Used in mem start
		re_EX_MEM <= re_ID_EX;
		we_EX_MEM <= we_ID_EX;
		aluResult_EX_MEM<=aluResult_EX; 
		zr_EX_MEM<=zr_EX; 
		ne_EX_MEM<=ne_EX; 
		ov_EX_MEM<=ov_EX; 	
		instr_EX_MEM<=instr_ID_EX; 	//Used in mem end

		
	
		//Just passing through mem start
		MemtoReg_EX_MEM<=MemtoReg_ID_EX;
		regAddr_EX_MEM<=regAddr_ID_EX;
		regWe_EX_MEM<=regWe_ID_EX;
		//Just passing through mem end

	end

	Memory(				
									.clk(clk),
									.memaddr_EX_MEM(memaddr_EX_MEM),
									.re_EX_MEM(re_EX_MEM),
									.we_EX_MEM(we_EX_MEM),
									.wrt_data_EX_MEM(aluResult_EX_MEM),
									.rd_data_MEM(rdData_MEM), 
									.zr_EX_MEM(zr_EX_MEM), 
									.ne_EX_MEM(ne_EX_MEM), 
									.ov_EX_MEM(ov_EX_MEM), 	
									.instr_EX_MEM(instr_EX_MEM), 
									.flush(flush), 
									.branch(branch));

	




	wire [15:0] rdData_MEM_WB, aluResult_MEM_WB;  // Inputs to writeback
	wire				MemtoReg_MEM_WB;

	wire [15:0] writeData_WB;					//Output of writeback

	wire [3:0] regAddr_MEM_WB;				//Just passing through signals
	wire 			 regWe_MEM_WB;
//*****************************************************
// MEM_WB
//
// EX_MEM/MEM -> WB
//
//*****************************************************
always
	begin
		rdData_MEM_WB<=rdData_MEM;
		aluResult_MEM_WB<=aluResult_EX_MEM;
		MemtoReg_MEM_WB<=MemtoReg_EX_MEM;

		regAddr_MEM_WB<=regAddr_EX_MEM;
		regWe_MEM_WB<=regWe_EX_MEM;
	
	end


Writeback writeback(
	.memData_MEM_WB(rdData_MEM_WB),
	.result_MEM_WB(aluResult_MEM_WB), 
	.MemtoReg_MEM_WB(MemtoReg_MEM_WB), 

	.writeData_WB(write_Data_WB));

	



endmodule

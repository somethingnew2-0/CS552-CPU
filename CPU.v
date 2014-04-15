module CPU(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
  output hlt; //Assuming these are current flag states
  output [15:0] pc;


  wire flush, branch;

  assign flush = 0'b0;
  assign branch = 0'b0;
  assign rd_en = 1'b1; // When should this change?

  /* The pipeline. Each blank line separates inputs from
    outputs of the module */

  wire [15:0] instr_IF;

  IF IF(.addr(pc),
        .clk(clk),
        .rd_en(rd_en),
        
        .instr(instr_IF));

  wire [15:0] instr_IF_ID;

  //******************************************************
  // IF_ID
  //
  // IF -> ID
  //
  //******************************************************
  always
    begin  
      //Used in id start
      //Used in id end
    
      //Just passing through id start

      //Just passing through id end
    end

  wire [15:0] p0_ID, p1_ID;
  wire [11:0] imm_ID;
  wire [3:0] regAddr_ID, shamt_ID;
  wire [2:0] aluOp_ID, branchOp_ID;
  wire regWe_ID, memRe_ID, memWe_ID, memToReg_ID, jal_ID, jr_ID, hlt_ID, aluSrc0_ID, aluSrc1_ID, ovEn_ID, zrEn_ID, neEn_ID;

  InstructionDecode id(
        .instr(instr_IF_ID),

        .clk(clk),
        .dstAddr(dstAddr),
        .dst(dst),
        .dstWe(dstWe),
  
        .p0(p0_ID),
        .p1(p1_ID),
        .imm(imm_ID), 
        .regAddr(regAddr_ID),
        .shamt(shamt_ID),
        .aluOp(aluOp_ID),
        .branchOp(branchOp_ID),
        .regWe(regWe_ID), 
        .memRe(memRe_ID),
        .memWe(memWe_ID),
        .memToReg(memToReg_ID),
        .jal(jal_ID),
        .jr(jr_ID),
        .hlt(hlt_ID), 
        .aluSrc0(aluSrc0_ID), 
        .aluSrc1(aluSrc1_ID),
        .ovEn(ovEn_ID), 
        .zrEn(zrEn_ID), 
        .neEn(neEn_ID)
        );

  wire [15:0] p0_ID_EX, p1_ID_EX;
  wire [11:0] imm_ID_EX;
  wire [3:0] shamt_ID_EX;
  wire [2:0] aluOp_ID_EX;
  wire aluSrc0_ID_EX, aluSrc1_ID_EX;

  // Just passing through signals
  wire [3:0] regAddr_ID_EX;
  wire [2:0] branchOp_ID_EX;
  wire regWe_ID_EX, memRe_ID_EX, memWe_ID_EX, memToReg_ID_EX, jal_ID_EX, jr_ID_EX, hlt_ID_EX, ovEn_ID_EX, zrEn_ID_EX, neEn_ID_EX;

  //******************************************************
  // ID_EX
  //
  // ID -> EX
  //
  //******************************************************
  always
    begin  
      //Used in ex start
      //Used in ex end
    
      //Just passing through ex start

      //Just passing through ex end
    end


  wire [15:0] aluResult_EX, branchResult_EX, jumpResult_EX;
  wire ov_EX, zr_EX, ne_EX;

  Execute execute(.p0(p0_ID_EX),
                  .p1(p1_ID_EX),
                  .pc(pc_ID_EX),
                  .imm(imm_ID_EX),
                  .shamt(shamt_ID_EX),
                  .aluOp(aluOp_ID_EX),
                  .aluSrc0(aluSrc0_ID_EX),
                  .aluSrc1(aluSrc1_ID_EX),
                  .ov_EX(ov_EX),
                  .zr_EX(zr_EX),
                  .ne_EX(ne_EX),
                  .aluResult(aluResult_EX),
                  .branchResult(branchResult_EX),
                  .jumpResult(jumpResult_EX));

  wire  [15:0] aluResult_EX_MEM, memAddr_EX_MEM, wrtData_EX_MEM, branchOp_EX_MEM; // Inputs to Memory from flops
  wire re_EX_MEM, we_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM; 

  // Just passing through signals
  wire memToReg_EX_MEM;     
  wire [3:0] regAddr_EX_MEM;
  wire regWe_EX_MEM;

  //******************************************************
  // EX_MEM
  //
  // ID_EX/EX -> MEM
  //
  //******************************************************
  always
    begin 
      //Used in mem start
      aluResult_EX_MEM <= aluResult_EX; 
      memAddr_EX_MEM <= aluResult_EX; 
      re_EX_MEM <= re_ID_EX;
      we_EX_MEM <= we_ID_EX;
      wrData_EX_MEM <= p0_ID_EX; 
      zr_EX_MEM <= zr_EX; 
      ne_EX_MEM <= ne_EX; 
      ov_EX_MEM <= ov_EX;   
      branchOp_EX_MEM <= branchOp_ID_EX;
      //Used in mem end    
    
      //Just passing through mem start
      memToReg_EX_MEM <= memToReg_ID_EX;
      regAddr_EX_MEM <= regAddr_ID_EX;
      regWe_EX_MEM <= regWe_ID_EX;
      //Just passing through mem end

    end

  wire  [15:0] rdData_MEM;            // Output From Memory

  Memory(       
        .clk(clk),
        .memAddr_EX_MEM(memAddr_EX_MEM),
        .re_EX_MEM(re_EX_MEM),
        .we_EX_MEM(we_EX_MEM),
        .wrt_data_EX_MEM(wrData_EX_MEM),
        .rd_data_MEM(rdData_MEM), 
        .zr_EX_MEM(zr_EX_MEM), 
        .ne_EX_MEM(ne_EX_MEM), 
        .ov_EX_MEM(ov_EX_MEM),  
        .branchOp_EX_MEM(branchOp_EX_MEM), 
        .flush(flush), 
        .branch(branch));

  wire [15:0] rdData_MEM_WB, aluResult_MEM_WB;  // Inputs to writeback
  wire        memToReg_MEM_WB;

  wire [15:0] writeData_WB;         //Output of writeback

  // Just passing through signals
  wire [3:0] regAddr_MEM_WB;
  wire       regWe_MEM_WB;

  //*****************************************************
  // MEM_WB
  //
  // EX_MEM/MEM -> WB
  //
  //*****************************************************
  always
    begin
      rdData_MEM_WB <= rdData_MEM;
      aluResult_MEM_WB <= aluResult_EX_MEM;
      memToReg_MEM_WB <= memToReg_EX_MEM;

      regAddr_MEM_WB <= regAddr_EX_MEM;
      regWe_MEM_WB <= regWe_EX_MEM;
    
    end


Writeback writeback(
  .memData_MEM_WB(rdData_MEM_WB),
  .result_MEM_WB(aluResult_MEM_WB), 
  .memToReg_MEM_WB(memToReg_MEM_WB), 

  .writeData_WB(write_Data_WB));

  



endmodule

module cpu(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
  output hlt; //Assuming these are current flag states
  output [15:0] pc;

  wire [15:0] branchAddr;
  wire flush, stall, branch;

  assign stall = 0'b0;
	assign flush = 0'b0;
  assign rd_en = 1'b1; // When should this change?

  /* The pipeline. Each blank line separates inputs from
    outputs of the module */

  wire [15:0] pcNext_IF, instr_IF;

  InstructionFetch instructionfetch(
                                    // Global inputs
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .branch(branch),
                                    .branchAddr(branchAddr),
                                    .stall(stall),
                                    .rd_en(rd_en),
                                    
                                    // Global outputs
                                    .pc(pc),
                                    .hlt(hlt),

                                    // Pipeline stage outputs 
                                    .pcNext(pcNext_IF),
                                    .instr(instr_IF));

  reg [15:0] instr_IF_ID, pcNext_IF_ID;

  //******************************************************
  // IF_ID
  //
  // IF -> ID
  //
  //******************************************************
  always @(posedge clk) begin  
    //Used in id start
    instr_IF_ID <= instr_IF;
    //Used in id end

    //Just passing through id start
    pcNext_IF_ID <= pcNext_IF;
    //Just passing through id end
  end

  wire [15:0] writeData;
  wire [3:0] writeAddr;
  wire writeEnable;

  wire [15:0] p0_ID, p1_ID;
  wire [11:0] imm_ID;
  wire [3:0] regAddr_ID, shamt_ID;
  wire [2:0] aluOp_ID, branchOp_ID;
  wire regWe_ID, memRe_ID, memWe_ID, memToReg_ID, addz_ID, branch_ID, jal_ID, jr_ID, aluSrc0_ID, aluSrc1_ID, ovEn_ID, zrEn_ID, neEn_ID;

  InstructionDecode instructiondecode(
        // Global inputs
        .clk(clk),
        .rst_n(rst_n),
        .hlt(hlt),
        .writeData(writeData),
        .writeAddr(writeAddr),        
        .writeEnable(writeEnable),

        // Pipeline stage inputs
        .instr(instr_IF_ID),

        // Pipeline stage outputs  
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
        .addz(addz_ID),
        .branch(branch_ID),
        .jal(jal_ID),
        .jr(jr_ID),
        .aluSrc0(aluSrc0_ID), 
        .aluSrc1(aluSrc1_ID),
        .ovEn(ovEn_ID), 
        .zrEn(zrEn_ID), 
        .neEn(neEn_ID)
        );

  reg [15:0] p0_ID_EX, p1_ID_EX, pcNext_ID_EX;
  reg [11:0] imm_ID_EX;
  reg [3:0] shamt_ID_EX;
  reg [2:0] aluOp_ID_EX;
  reg aluSrc0_ID_EX, aluSrc1_ID_EX;

  // Just passing through signals
  reg [3:0] regAddr_ID_EX;
  reg [2:0] branchOp_ID_EX;
  reg regWe_ID_EX, memRe_ID_EX, memWe_ID_EX, memToReg_ID_EX, addz_ID_EX, branch_ID_EX, jal_ID_EX, jr_ID_EX, ovEn_ID_EX, zrEn_ID_EX, neEn_ID_EX;

  //******************************************************
  // ID_EX
  //
  // ID -> EX
  //
  //******************************************************
  always @(posedge clk) begin 
    //Used in ex start
    p0_ID_EX <= p0_ID;
    p1_ID_EX <= p1_ID;
    pcNext_ID_EX <= pcNext_IF_ID;
    imm_ID_EX <= imm_ID;
    shamt_ID_EX <= shamt_ID;
    aluOp_ID_EX <= aluOp_ID;
    aluSrc0_ID_EX <= aluSrc0_ID;
    aluSrc1_ID_EX <= aluSrc1_ID;
    //Used in ex end
  
    //Just passing through ex start
    regAddr_ID_EX <= regAddr_ID;
    branchOp_ID_EX <= branchOp_ID;
    
    if(!flush) begin
      regWe_ID_EX <= regWe_ID;
      memWe_ID_EX <= memWe_ID;
      branch_ID_EX <= branch_ID;

      ovEn_ID_EX <= ovEn_ID;
      zrEn_ID_EX <= zrEn_ID;
      neEn_ID_EX <= neEn_ID;
    end
    else begin
      regWe_ID_EX <= 1'b0;
      memWe_ID_EX <= 1'b0;
      branch_ID_EX <= 1'b0;

      ovEn_ID_EX <= 1'b0;
      zrEn_ID_EX <= 1'b0;
      neEn_ID_EX <= 1'b0;
    end 

    memRe_ID_EX <= memRe_ID;      
    memToReg_ID_EX <= memToReg_ID;
    addz_ID_EX <= addz_ID;

    jal_ID_EX <= jal_ID;
    jr_ID_EX <= jr_ID;
    //Just passing through ex end
  end


  wire [15:0] aluResult_EX, branchResult_EX, jumpResult_EX;
  wire ov_EX, zr_EX, ne_EX;

  Execute execute(
                  // Pipeline stage inputs
                  .p0(p0_ID_EX),
                  .p1(p1_ID_EX),
                  .pcNext(pcNext_ID_EX),
                  .imm(imm_ID_EX),
                  .shamt(shamt_ID_EX),
                  .aluOp(aluOp_ID_EX),
                  .aluSrc0(aluSrc0_ID_EX),
                  .aluSrc1(aluSrc1_ID_EX),

                  // Pipeline stage outputs
                  .ov(ov_EX),
                  .zr(zr_EX),
                  .ne(ne_EX),
                  .aluResult(aluResult_EX),
                  .branchResult(branchResult_EX),
                  .jumpResult(jumpResult_EX));

  // Inputs to Memory from flops
  reg [15:0] aluResult_EX_MEM, branchResult_EX_MEM, jumpResult_EX_MEM, p0_EX_MEM, p1_EX_MEM, memAddr_EX_MEM;
  reg [2:0] branchOp_EX_MEM;
  reg memRe_EX_MEM, memWe_EX_MEM, addz_EX_MEM, branch_EX_MEM, jal_EX_MEM, jr_EX_MEM, ov_EX_MEM, zr_EX_MEM, ovEn_EX_MEM, ne_EX_MEM, zrEn_EX_MEM, neEn_EX_MEM; 
  // From the WB stage
  reg ov_MEM_WB, zr_MEM_WB, ne_MEM_WB;

  // Just passing through signals
  reg [15:0] pcNext_EX_MEM;
  reg [3:0] regAddr_EX_MEM;
  reg regWe_EX_MEM, memToReg_EX_MEM;

  //******************************************************
  // EX_MEM
  //
  // ID_EX/EX -> MEM
  //
  //******************************************************
  always @(posedge clk) begin 
    //Used in mem start
    aluResult_EX_MEM <= aluResult_EX; 
    branchResult_EX_MEM <= branchResult_EX;
    jumpResult_EX_MEM <= jumpResult_EX;
    memAddr_EX_MEM <= aluResult_EX; 
    p0_EX_MEM <= p0_ID_EX; 
    p1_EX_MEM <= p1_ID_EX; 
    branchOp_EX_MEM <= branchOp_ID_EX;
    memRe_EX_MEM <= memRe_ID_EX;

    if(!flush) begin
      memWe_EX_MEM <= memWe_ID_EX;
      branch_EX_MEM <= branch_ID_EX;
      regWe_EX_MEM <= regWe_ID_EX;

      ovEn_EX_MEM <= ovEn_ID_EX;
      zrEn_EX_MEM <= zrEn_ID_EX;
      neEn_EX_MEM <= neEn_ID_EX; 
    end
    else begin
      memWe_EX_MEM <= 1'b0;
      branch_EX_MEM <= 1'b0;
      regWe_EX_MEM <= 1'b0;

      ovEn_EX_MEM <= 1'b0;
      zrEn_EX_MEM <= 1'b0;
      neEn_EX_MEM <= 1'b0; 
    end

    addz_EX_MEM <= addz_ID_EX;
    jal_EX_MEM <= jal_ID_EX;
    jr_EX_MEM <= jr_ID_EX;
    //Used in mem end    
  
    //Just passing through mem start
    pcNext_EX_MEM <= pcNext_ID_EX;
    regAddr_EX_MEM <= regAddr_ID_EX;
    memToReg_EX_MEM <= memToReg_ID_EX;

    ov_EX_MEM <= ov_EX;
    zr_EX_MEM <= zr_EX;
    ne_EX_MEM <= ne_EX; 
    //Just passing through mem end
  end

  wire [15:0] memData_MEM; // Output From Memory
  wire regWe_MEM;

  Memory memory(
        // Global inputs       
        .clk(clk),

        // Pipeline stage inputs
        .memAddr(memAddr_EX_MEM),
        .memRe(memRe_EX_MEM),
        .memWe(memWe_EX_MEM),
        .regWe(regWe_EX_MEM),
        .wrtData(p1_EX_MEM),
        .zr(zr_MEM_WB), 
        .ne(ne_MEM_WB), 
        .ov(ov_MEM_WB),  
        .addz(addz_EX_MEM),
        .b(branch_EX_MEM),
        .jal(jal_EX_MEM),
        .jr(jr_EX_MEM),        
        .jalResult(jumpResult_EX_MEM),
        .jrResult(p0_EX_MEM),
        .branchResult(branchResult_EX_MEM),
        .branchOp(branchOp_EX_MEM), 
        .flush(flush),

        // Pipeline stage outputs
        .memData(memData_MEM),
        .regWriteEnable(regWe_MEM),

        // Global outputs
        .branchAddr(branchAddr),
        .branch(branch));

  reg [15:0] pcNext_MEM_WB, memData_MEM_WB, aluResult_MEM_WB;  // Inputs to writeback
  reg [3:0] regAddr_MEM_WB;
  reg jal_MEM_WB, memToReg_MEM_WB, regWe_MEM_WB, ovEn_MEM_WB, zrEn_MEM_WB, neEn_MEM_WB; 


  //*****************************************************
  // MEM_WB
  //
  // EX_MEM/MEM -> WB
  //
  //*****************************************************
  always @(posedge clk or negedge rst_n) begin
    pcNext_MEM_WB <= pcNext_EX_MEM;
    memData_MEM_WB <= memData_MEM;
    aluResult_MEM_WB <= aluResult_EX_MEM;
    regAddr_MEM_WB <= regAddr_EX_MEM;
    jal_MEM_WB <= jal_EX_MEM;
    memToReg_MEM_WB <= memToReg_EX_MEM;      
    regWe_MEM_WB <= regWe_MEM;    

    ovEn_MEM_WB <= ovEn_EX_MEM;
    zrEn_MEM_WB <= zrEn_EX_MEM;
    neEn_MEM_WB <= neEn_EX_MEM; 

    if(!rst_n) begin
      zr_MEM_WB <= 1'b0; 
      ne_MEM_WB <= 1'b0;  
      ov_MEM_WB <= 1'b0;  
    end
    else begin
      if(ovEn_MEM_WB)
        ov_MEM_WB <= ov_EX_MEM; 
      else
        ov_MEM_WB <= ov_MEM_WB;

      if (zrEn_MEM_WB)
        zr_MEM_WB <= zr_EX_MEM; 
      else
        zr_MEM_WB <= zr_MEM_WB;

      if (neEn_MEM_WB)
        ne_MEM_WB <= ne_EX_MEM; 
      else
        ne_MEM_WB <= ne_MEM_WB; 
    end
  end

  Writeback writeback(
    // Global inputs  
    .flush(flush),

    // Pipeline stage inputs
    .jal(jal_MEM_WB),
    .memToReg(memToReg_MEM_WB),
    .regWe(regWe_MEM_WB),
    .regAddr(regAddr_MEM_WB),
    .pcNext(pcNext_MEM_WB),
    .memData(memData_MEM_WB),
    .aluResult(aluResult_MEM_WB),     

    // Global outputs
    .writeData(writeData),
    .writeAddr(writeAddr),
    .writeEnable(writeEnable));

endmodule

module cpu(clk, rst_n, hlt, pc);
  input clk; 
  input rst_n;
  output reg hlt; //Assuming these are current flag states
  output [15:0] pc;

  wire [15:0] branchAddr;
  wire flush, stall, branch, branchInit, forwardStall;

  reg wasRst_N;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      wasRst_N <= 1'b0;
    else if (!wasRst_N)
      wasRst_N <= 1'b1;
  end

  HazardControl hazardcontrol(
                              // Global inputs
                              .clk(clk),
                              .rst_n(rst_n),
                              .branch(branch),
                              .branchInit(branchInit),
                              .forwardStall(forwardStall),
                              // Global outputs
                              .flush(flush),
                              .stall(stall));

  assign rd_en = 1'b1; // When should this change?

  /* The pipeline. Each blank line separates inputs from
    outputs of the module */

  wire hlt_IF;
  wire [15:0] instr_IF;

  InstructionFetch instructionfetch(
                                    // Global inputs
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .wasRst_N(wasRst_N),
                                    .branch(branch),
                                    .branchAddr(branchAddr),
                                    .stall(stall),
                                    .rd_en(rd_en),
                                    
                                    // Global outputs
                                    .pcNext(pc),
                                    .branchInit(branchInit),

                                    // Pipeline stage outputs 
                                    .instr(instr_IF),
                                    .hlt(hlt_IF));

  reg [15:0] instr_IF_ID, pcNext_IF_ID;
  reg hlt_IF_ID;

  //******************************************************
  // IF_ID
  //
  // IF -> ID
  //
  //******************************************************
  always @(posedge clk) begin  
    if(!stall) begin
      //Used in id start
      if(!flush) begin
        instr_IF_ID <= instr_IF;
      end else begin
        instr_IF_ID <= 16'hB0FF; // Send a NOP through the pipe
      end
      //Used in id end

      if(flush || !wasRst_N) begin
        hlt_IF_ID <= 1'b0;
      end else begin 
				hlt_IF_ID <= hlt_IF;
      end

      //Just passing through id start
      pcNext_IF_ID <= pc;
      //Just passing through id end
    end
  end

  wire [15:0] writeData;
  wire [3:0] writeAddr;
  wire writeEnable;

  wire [15:0] p0_ID, p1_ID;
  wire [11:0] imm_ID;
  wire [3:0] p0Addr_ID, p1Addr_ID, regAddr_ID, shamt_ID;
  wire [2:0] aluOp_ID, branchOp_ID;
  wire regWe_ID, memRe_ID, memWe_ID, memToReg_ID, addz_ID, branch_ID, jal_ID, jr_ID, aluSrc0_ID, aluSrc1_ID, ovEn_ID, zrEn_ID, neEn_ID;

  InstructionDecode instructiondecode(
        // Global inputs
        .clk(clk),
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
        .p0Addr(p0Addr_ID), 
        .p1Addr(p1Addr_ID),
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
  reg [3:0] p0Addr_ID_EX, p1Addr_ID_EX, shamt_ID_EX;
  reg [2:0] aluOp_ID_EX;
  reg aluSrc0_ID_EX, aluSrc1_ID_EX;

  // Just passing through signals
  reg [3:0] regAddr_ID_EX;
  reg [2:0] branchOp_ID_EX;
  reg regWe_ID_EX, memRe_ID_EX, memWe_ID_EX, memToReg_ID_EX, addz_ID_EX, branch_ID_EX, jal_ID_EX, jr_ID_EX, ovEn_ID_EX, zrEn_ID_EX, neEn_ID_EX, hlt_ID_EX;

  //******************************************************
  // ID_EX
  //
  // ID -> EX
  //
  //******************************************************
  always @(posedge clk) begin 
    if(!stall) begin
      //Used in ex start
      p0_ID_EX <= p0_ID;
      p1_ID_EX <= p1_ID;
      pcNext_ID_EX <= pcNext_IF_ID;
      imm_ID_EX <= imm_ID;
      p0Addr_ID_EX <= p0Addr_ID;
      p1Addr_ID_EX <= p1Addr_ID;
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
        jal_ID_EX <= jal_ID;
        jr_ID_EX <= jr_ID;

        ovEn_ID_EX <= ovEn_ID;
        zrEn_ID_EX <= zrEn_ID;
        neEn_ID_EX <= neEn_ID;
      end
      else begin
        regWe_ID_EX <= 1'b0;
        memWe_ID_EX <= 1'b0;
        branch_ID_EX <= 1'b0;
        jal_ID_EX <= 1'b0;
        jr_ID_EX <= 1'b0;

        ovEn_ID_EX <= 1'b0;
        zrEn_ID_EX <= 1'b0;
        neEn_ID_EX <= 1'b0;
      end 
      if(flush || !wasRst_N) begin
        hlt_ID_EX <= 1'b0;
      end else begin 
				hlt_ID_EX <= hlt_IF_ID;
      end

      memRe_ID_EX <= memRe_ID;      
      memToReg_ID_EX <= memToReg_ID;
      addz_ID_EX <= addz_ID;
      //Just passing through ex end
    end
  end

  // ExecuteForwarding signals
  wire [15:0] forwardP0_EX, forwardP1_EX;
  reg [15:0] aluResult_EX_MEM, pcNext_EX_MEM, aluResult_MEM_WB, pcNext_MEM_WB, memData_MEM_WB, writeData_WB;
  reg [3:0] regAddr_EX_MEM, regAddr_MEM_WB, writeAddr_WB;
  reg jal_EX_MEM, regWe_MEM_WB, jal_MEM_WB, memToReg_EX_MEM, memToReg_MEM_WB, writeEnable_WB, regWe_EX_MEM;

  ExecuteForwarding executeforwarding(
                  // Forwarding inputs
                  .p0(p0_ID_EX),
                  .p1(p1_ID_EX),
                  .p0Addr(p0Addr_ID_EX),
                  .p1Addr(p1Addr_ID_EX),
                  // Forwarding EX_MEM inputs
                  .regAddr_EX_MEM(regAddr_EX_MEM), 
                  .regWe_EX_MEM(regWe_EX_MEM),
                  .aluResult_EX_MEM(aluResult_EX_MEM),
                  .jal_EX_MEM(jal_EX_MEM),
                  .pcNext_EX_MEM(pcNext_EX_MEM),
                  .memToReg_EX_MEM(memToReg_EX_MEM),
                  // Forwarding MEM_WB inputs
                  .regAddr_MEM_WB(regAddr_MEM_WB), 
                  .regWe_MEM_WB(regWe_MEM_WB),
                  .aluResult_MEM_WB(aluResult_MEM_WB),
                  .jal_MEM_WB(jal_MEM_WB),
                  .pcNext_MEM_WB(pcNext_MEM_WB),
                  .memToReg_MEM_WB(memToReg_MEM_WB),
                  .memData_MEM_WB(memData_MEM_WB),
                  // Forwarding WB inputs
                  .writeData_WB(writeData_WB),
                  .writeAddr_WB(writeAddr_WB),
                  .writeEnable_WB(writeEnable_WB),

                  // Forwarding outputs
                  .forwardP0(forwardP0_EX),
                  .forwardP1(forwardP1_EX),

                  // Global forwarding output
                  .forwardStall(forwardStall));


  wire [15:0] aluResult_EX, branchResult_EX, jumpResult_EX;
  wire ov_EX, zr_EX, ne_EX, regWe_EX, memWe_EX;
  reg ov_EX_MEM, zr_EX_MEM, ne_EX_MEM;

  Execute execute(
                  // Pipeline stage inputs
                  .p0(forwardP0_EX),
                  .p1(forwardP1_EX),
                  .pcNext(pcNext_ID_EX),
                  .imm(imm_ID_EX),
                  .shamt(shamt_ID_EX),
                  .aluOp(aluOp_ID_EX),
                  .branchOp(branchOp_ID_EX),  
                  .aluSrc0(aluSrc0_ID_EX),
                  .aluSrc1(aluSrc1_ID_EX),
                  .regWe(regWe_ID_EX),
                  .memWe(memWe_ID_EX),
                  .addz(addz_ID_EX),
                  .b(branch_ID_EX),
                  .jal(jal_ID_EX),
                  .jr(jr_ID_EX),
                  .zr_EX_MEM(zr_EX_MEM),
                  .ne_EX_MEM(ne_EX_MEM), 
                  .ov_EX_MEM(ov_EX_MEM),                  

                  // Pipeline stage outputs
                  .ov_EX(ov_EX),
                  .zr_EX(zr_EX),
                  .ne_EX(ne_EX),
                  .aluResult(aluResult_EX),
                  .regWriteEnable(regWe_EX),
                  .memoryWriteEnable(memWe_EX),

                  // Global outputs
                  .branchAddr(branchAddr),
                  .branch(branch));

  // Inputs to Memory from flops
  reg [15:0] p0_EX_MEM, p1_EX_MEM, memAddr_EX_MEM;
  reg [3:0] p1Addr_EX_MEM;
  reg memRe_EX_MEM, memWe_EX_MEM, hlt_EX_MEM;

  //******************************************************
  // EX_MEM
  //
  // ID_EX/EX -> MEM
  //
  //******************************************************
  always @(posedge clk) begin 
    if(!stall) begin
      //Used in mem start
      aluResult_EX_MEM <= aluResult_EX; 
      memAddr_EX_MEM <= aluResult_EX; 
      p0_EX_MEM <= forwardP0_EX; 
      p1_EX_MEM <= forwardP1_EX; 
      p1Addr_EX_MEM <= p1Addr_ID_EX;
      memRe_EX_MEM <= memRe_ID_EX;

      if(ovEn_ID_EX) begin
        ov_EX_MEM <= ov_EX;
      end
      else begin
        ov_EX_MEM <= ov_EX_MEM;
      end

      if (zrEn_ID_EX) begin
        zr_EX_MEM <= zr_EX;
      end
      else begin
        zr_EX_MEM <= zr_EX_MEM;
      end

      if (neEn_ID_EX) begin
        ne_EX_MEM <= ne_EX; 
      end
      else begin
        ne_EX_MEM <= ne_EX_MEM;
      end

      memWe_EX_MEM <= memWe_EX;
      jal_EX_MEM <= jal_ID_EX;

      //Used in mem end    
    
      //Just passing through mem start
      pcNext_EX_MEM <= pcNext_ID_EX;
      regAddr_EX_MEM <= regAddr_ID_EX;
      memToReg_EX_MEM <= memToReg_ID_EX;
      regWe_EX_MEM <= regWe_EX;

      if(flush || !wasRst_N) begin
        hlt_EX_MEM <= 1'b0;
      end else begin 
				hlt_EX_MEM <= hlt_ID_EX;
      end
      //Just passing through mem end
    end
  end

  wire [15:0] forwardWrtData_MEM;

  MemoryForwarding memoryforwarding(
    // WB forwarding input
    .wrtData(p1_EX_MEM),
    .p1Addr(p1Addr_EX_MEM),
    .regAddr_MEM_WB(regAddr_MEM_WB), 
    .regWe_MEM_WB(regWe_MEM_WB),
    .aluResult_MEM_WB(aluResult_MEM_WB),
    .jal_MEM_WB(jal_MEM_WB),
    .pcNext_MEM_WB(pcNext_MEM_WB),
    .memToReg_MEM_WB(memToReg_MEM_WB),
    .memData_MEM_WB(memData_MEM_WB),

    // Forwarding output
    .forwardWrtData(forwardWrtData_MEM)
  );

  wire [15:0] memData_MEM; // Output From Memory

  Memory memory(
        // Global inputs       
        .clk(clk),

        // Pipeline stage inputs
        .memAddr(memAddr_EX_MEM),
        .memRe(memRe_EX_MEM),
        .memWe(memWe_EX_MEM),
        .wrtData(forwardWrtData_MEM),

        // Pipeline stage outputs
        .memData(memData_MEM));

  //*****************************************************
  // MEM_WB
  //
  // EX_MEM/MEM -> WB
  //
  //*****************************************************
  always @(posedge clk) begin
    pcNext_MEM_WB <= pcNext_EX_MEM;
    memData_MEM_WB <= memData_MEM;
    aluResult_MEM_WB <= aluResult_EX_MEM;
    regAddr_MEM_WB <= regAddr_EX_MEM;
    jal_MEM_WB <= jal_EX_MEM;
    memToReg_MEM_WB <= memToReg_EX_MEM;      
    regWe_MEM_WB <= regWe_EX_MEM;      

    if(flush || !wasRst_N) begin
      hlt <= 1'b0;
    end else begin 
			hlt <= hlt_EX_MEM;
    end
  end

  Writeback writeback(
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

  always @(posedge clk) begin
    writeData_WB <= writeData;
    writeAddr_WB <= writeAddr;
    writeEnable_WB <= writeEnable;
  end  

endmodule

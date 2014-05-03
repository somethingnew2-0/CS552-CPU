module Execute(p0, p1, pcNext, imm, shamt, aluOp, branchOp, aluSrc0, aluSrc1, regWe, memWe, addz, b, jal, jr, ov_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX, zr_EX, ne_EX, aluResult, branchAddr, branch, regWriteEnable, memoryWriteEnable);
  input[15:0] p0, p1, pcNext;
  input[11:0] imm;
  input [3:0] shamt;
  input [2:0] aluOp, branchOp;
  
  // Control signals
  input aluSrc0, aluSrc1, regWe, memWe, addz, b, jal, jr;
  // Flags
  input ov_EX_MEM, zr_EX_MEM, ne_EX_MEM;

  output ov_EX, zr_EX, ne_EX;
  output [15:0] aluResult, branchAddr;
  output branch, regWriteEnable, memoryWriteEnable;

  wire [15:0] src0, src1, branchResult, jumpResult;

  SRC_MUX srcmux(.p0(p0),
                 .p1(p1), 
                 .imm(imm[7:0]), 
                 .aluSrc0(aluSrc0),
                 .aluSrc1(aluSrc1),
                 .src0(src0),
                 .src1(src1));

  ALU alu(.src0(src0), 
          .src1(src1), 
          .ctrl(aluOp), 
          .shamt(shamt),
          .result(aluResult), 
          .ov(ov_EX),           
          .zr(zr_EX),
          .ne(ne_EX)); 

  BranchAdder branchadder(.pcNext(pcNext),
                          .offset(imm[8:0]),
                          .result(branchResult));

  JumpAdder jumpadder(.pcNext(pcNext),
                      .offset(imm),
                      .result(jumpResult));


  // Branch Codes, straight off the quick reference
  localparam neq    = 3'b000;
  localparam eq     = 3'b001;
  localparam gt     = 3'b010;
  localparam lt     = 3'b011;
  localparam gte    = 3'b100;
  localparam lte    = 3'b101;
  localparam ovfl   = 3'b110;
  localparam uncond = 3'b111; 

  assign branchAddr = jal ? jumpResult:
                      jr ? p0: // Set to P0
                      branchResult; 

  assign branch = jal | jr |
                    (b &
                      ((branchOp == uncond) |
                      ((branchOp == neq) & !zr_EX_MEM) |
                      ((branchOp == eq) & zr_EX_MEM) |
                      ((branchOp == gt) & !(zr_EX_MEM | ne_EX_MEM)) |
                      ((branchOp == lt) & ne_EX_MEM) |
                      ((branchOp == gte) & !ne_EX_MEM) |
                      ((branchOp == lte) & (ne_EX_MEM | zr_EX_MEM)) |
                      ((branchOp == ovfl) & ov_EX_MEM)));  

  assign regWriteEnable = (!branch || jal) && (regWe || (addz && zr_EX_MEM));

  assign memoryWriteEnable = !branch & memWe; 
  
endmodule

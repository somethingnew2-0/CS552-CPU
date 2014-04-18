module Memory(clk, flush, memAddr, memRe, memWe, regWe, wrtData, zr, ne, ov, zrEn_EX_MEM, neEn_EX_MEM, ovEn_EX_MEM, addz, b, jal, jr, jalResult, jrResult, branchResult, branchOp, memData, branchAddr, regWriteEnable, ovEn_MEM, zrEn_MEM, neEn_MEM, branch);
  input clk, flush,  memRe, memWe, regWe, zr, ne, ov, zrEn_EX_MEM, neEn_EX_MEM, ovEn_EX_MEM, addz, b, jal, jr;
  input [15:0] memAddr, wrtData, jalResult, jrResult, branchResult;
  input [2:0] branchOp;

  output [15:0] memData, branchAddr;  //output of data memory
  output regWriteEnable, ovEn_MEM, zrEn_MEM, neEn_MEM, branch;

  // Branch Codes, straight off the quick reference
  localparam neq    = 3'b000;
  localparam eq     = 3'b001;
  localparam gt     = 3'b010;
  localparam lt     = 3'b011;
  localparam gte    = 3'b100;
  localparam lte    = 3'b101;
  localparam ovfl   = 3'b110;
  localparam uncond = 3'b111;

  assign finalWe = !flush & memWe; 

  DM dm(.clk(clk),
        .addr(memAddr),
        .re(memRe),
        .we(finalWe),
        .wrt_data(wrtData),
        .rd_data(memData));

  assign regWriteEnable = !flush & (regWe || (addz & zr));

  assign ovEn_MEM = addz ? (zr ? ovEn_EX_MEM : 0'b0): ovEn_EX_MEM;
  assign zrEn_MEM = addz ? (zr ? zrEn_EX_MEM : 0'b0): zrEn_EX_MEM;
  assign neEn_MEM = addz ? (zr ? neEn_EX_MEM : 0'b0): neEn_EX_MEM;

  assign branchAddr = jal ? jalResult:
                      jr ? jrResult: // Set to P0
                      branchResult; 

  assign branch = jal | jr |
                    (b &
                      ((branchOp == uncond) |
                      ((branchOp == neq) & !zr) |
                      ((branchOp == eq) & zr) |
                      ((branchOp == gt) & !(zr | ne)) |
                      ((branchOp == lt) & ne) |
                      ((branchOp == gte) & !ne) |
                      ((branchOp == lte) & (ne | zr)) |
                      ((branchOp == ovfl) & ov)));   

endmodule

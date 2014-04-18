module Memory(clk, memAddr, memRe, memWe, regWe, wrtData, zr, ne, ov, addz, b, jal, jr, jalResult, jrResult, branchResult, branchOp, memData, branchAddr, flush, regWriteEnable, branch);
  input clk, memRe, memWe, regWe, zr, ne, ov, addz, b, jal, jr, flush;
  input [15:0] memAddr, wrtData, jalResult, jrResult, branchResult;
  input [2:0] branchOp;

  output [15:0] memData, branchAddr;  //output of data memory
  output regWriteEnable, branch;

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

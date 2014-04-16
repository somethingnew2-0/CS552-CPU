module Memory(clk, memAddr_EX_MEM, memRe_EX_MEM, memWe_EX_MEM, wrtData_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM, branch_EX_MEM, jal_EX_MEM, jr_EX_MEM, jalResult_EX_MEM, jrResult_EX_MEM, branchResult_EX_MEM, branchOp_EX_MEM, memData_MEM, branchAddr, flush, branch);
  input clk, memRe_EX_MEM, memWe_EX_MEM, zr_EX_MEM, ne_EX_MEM, ov_EX_MEM, branch_EX_MEM, jal_EX_MEM, jr_EX_MEM;
  input [15:0] memAddr_EX_MEM, wrtData_EX_MEM, jalResult_EX_MEM, jrResult_EX_MEM, branchResult_EX_MEM;
  input [2:0] branchOp_EX_MEM;

  output [15:0] memData_MEM, branchAddr;  //output of data memory
  output flush, branch;

  wire zr, ne, ov, finalWe;
  wire [2:0] branchOp;

  // Branch Codes, straight off the quick reference
  localparam neq    = 3'b000;
  localparam eq     = 3'b001;
  localparam gt     = 3'b010;
  localparam lt     = 3'b011;
  localparam gte    = 3'b100;
  localparam lte    = 3'b101;
  localparam ovfl   = 3'b110;
  localparam uncond = 3'b111;

  assign flush = 0'b0;

  assign finalWe = !flush & memWe_EX_MEM; 

  assign zr = zr_EX_MEM;
  assign ne = ne_EX_MEM;
  assign ov = ov_EX_MEM;
  assign branchOp = branchOp_EX_MEM;

  DM dm(.clk(clk),
        .addr(memAddr_EX_MEM),
        .re(memRe_EX_MEM),
        .we(finalWe),
        .wrt_data(wrtData_EX_MEM),
        .rd_data(memData_MEM));

  assign branchAddr = jal_EX_MEM ? jalResult_EX_MEM:
                      jr_EX_MEM ? jrResult_EX_MEM: // Set to P0
                      branchResult_EX_MEM; 

  assign branch = jal_EX_MEM || jr_EX_MEM || 
                    (branch_EX_MEM &&
                      ((branchOp == uncond) ||
                      ((branchOp == neq) && !zr) ||
                      ((branchOp == eq) && zr) ||
                      ((branchOp == gt) && !(zr || ne)) ||
                      ((branchOp == lt) && ne) ||
                      ((branchOp == gte) && !ne) ||
                      ((branchOp == lte) && (ne || zr)) ||
                      ((branchOp == ovfl) && ov)));   

endmodule

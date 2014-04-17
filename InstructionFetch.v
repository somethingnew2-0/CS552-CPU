module InstructionFetch(clk, rst_n, hlt, branch, branchAddr, stall, rd_en, instr, pcNext);

  input clk, rst_n, hlt, branch, stall, rd_en;
  input [15:0] branchAddr;
  
  output [15:0] instr, pcNext; 

  reg [15:0] pc;
  wire [15:0] effectivePc;

  assign pcNext = stall ? pc : pc + 1; 

  assign effectivePc = branch ? branchAddr:
                       pcNext;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      pc <= 16'h0000;
    else if (!hlt)
      pc <= effectivePc;
    else
      pc <= pc;
  end

  IM im(.addr(pc),
        .clk(clk),
        .rd_en(rd_en),
        
        .instr(instr));

endmodule


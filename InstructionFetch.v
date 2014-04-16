module InstructionFetch(clk, rst_n, hlt, branch, branchAddr, stall, rd_en, pc, pcNext, instr);

  input clk, rst_n, hlt, branch, stall, rd_en;
  input [15:0] branchAddr;

  output reg [15:0] pc, pcNext;
  output [15:0] instr; 

  wire [15:0] effectivePc;

  assign effectivePc = branch ? branchAddr :
                       pc + 1;

  always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
      pc <= 16'h0000;
      pcNext <= effectivePc;
    end
    else if (!hlt && !stall) begin
      pcNext <= effectivePc;
      pc <= pcNext;
    end
    else begin
      pcNext <= pcNext;
      pc <= pc;
    end

  IM im(.addr(pc),
        .clk(clk),
        .rd_en(rd_en),
        
        .instr(instr));

endmodule


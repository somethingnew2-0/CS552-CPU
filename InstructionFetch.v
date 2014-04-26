module InstructionFetch(clk, rst_n, branch, branchAddr, stall, rd_en, instr, pcNext, hlt, branchInit);

  input clk, rst_n, branch, stall, rd_en;
  input [15:0] branchAddr;
  
  output [15:0] instr, pcNext;   
  output hlt, branchInit;

  reg [15:0] pc;
  reg wasRst_N;

  wire [15:0] effectivePc, instrFetched;

  assign branchInit = !((pc == 16'h0000) || (pc == 16'h0001) || (pc == 16'h0002));

  assign hlt = (instr[15:12] == 4'b1111) && ((!(branch)) | !branchInit) & rst_n;

  assign pcNext = !wasRst_N ? 16'h0000 : 
                  stall ? pc : 
                  pc + 1; 

  assign effectivePc = (branchInit && branch) ? branchAddr:
                       pcNext;

  // Send a NOP through the pipe on empty instruction
  assign instr = (instrFetched === 16'hXXXX) ? 16'hB0FF : instrFetched;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      pc <= 16'h0000;
    else if (!hlt)
      pc <= effectivePc;
    else
      pc <= pc;
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      wasRst_N <= 1'b0;
    else if (!wasRst_N)
      wasRst_N <= 1'b1;
  end

  IM im(.addr(pc),
        .clk(clk),
        .rd_en(rd_en),
        
        .instr(instrFetched));

endmodule


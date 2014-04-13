// Peter Collins, Matthew Wiemer, Luke Brandl
module ALU(src0, src1, ctrl, shamt, aluOp, result, ov_EX, zr_EX, ne_EX, ov, zr, ne);
  input [15:0] src0, src1;
  input [2:0] ctrl;
  input [3:0] shamt;
	input aluOp, ov_EX, zr_EX, ne_EX;
	
  output [15:0] result;
	output ov, zr, ne;

  wire [15:0] unsat, op1;

  localparam add = 3'b000; // Accounts for both add and addz
  localparam lhb = 3'b001;
  localparam sub = 3'b010;
  localparam andy = 3'b011;
  localparam nory = 3'b100;
  localparam sll = 3'b101;
  localparam srl = 3'b110;
  localparam sra = 3'b111;

  assign unsat = (ctrl==add) ? src0+src1:
                 (ctrl==lhb) ? {src0[7:0], src1[7:0]}:
                 (ctrl==sub) ? src0-src1:
                 (ctrl==andy)? src0&src1:
                 (ctrl==nory)? ~(src0|src1):
                 (ctrl==sll) ? src0<<shamt:
                 (ctrl==srl) ? src0>>shamt:
		             (ctrl==sra) ? {$signed(src0) >>> shamt}:
                 17'h00000; // It will never reach here logically

 	// When checking msbs for overflow, we need the actual bits operated on
	assign op1 = ctrl==sub ? ~src1 + 1'b1 : src1;          

  // Positive operands; Negative result
	assign negativeOverflow =(src0[15] && op1[15] && !unsat[15]);
  // Negative operands; Positive result
	assign positiveOverflow = (!src0[15] && !op1[15] && unsat[15]);

  // Set Result
  assign result = (positiveOverflow && (ctrl==add || ctrl==sub)) ? 16'h7fff :
               (negativeOverflow && (ctrl==add || ctrl==sub)) ? 16'h8000 : unsat;

  // Only set overflow for add, addz, sub
  assign ov = (ctrl==add || ctrl==sub) ? (positiveOverflow || negativeOverflow) : oldOv;

  assign zr = aluOp ? ~|result : oldZr;

  // Only set negative for add, addz, sub 
  assign ne = (ctrl==add || ctrl==sub) ? result[15] : oldNe;
  
endmodule

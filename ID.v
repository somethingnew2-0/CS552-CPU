module ID(instr, zr, p0_addr, re0, p1_addr, re1, dst_addr, we, shamt, hlt, src1sel, func);
  input [15:0] instr;
  input zr;
  output [3:0] p0_addr, p1_addr, dst_addr, shamt;
  output re0, re1, we, hlt, src1sel;
  output [2:0] func;
  
  // Opcode for specified load byte
  localparam oplhb = 3'b010;
  localparam opllb = 3'b011;  
  // Opcode for ADDZ
  localparam opaddz = 4'b0001;
  
  // ALU func for ADD
  localparam funcadd = 3'b000;
  // ALU func for specified load byte
  localparam funclhb = 3'b001;
  // llb should use the sra from the ALU with shamt 8
  localparam funcllb = 3'b111;  
  
  // Set src0 register address as normal unless it's LHB                                                 
  assign p0_addr = (instr[15:12] == 4'b1010) ? instr[11:8] : instr[7:4];

  // Set the src1 as normal for normal alu ops, however if it is SLL, SRL, or SRA set src1 to the src0 register addr
  // That way the LLB works properly since those operations are actually hooked up to src1 for input in the ALU
  assign p1_addr = (instr[15:13] == 3'b011 || instr[15:12] == 4'b0101) ? instr[7:4] : instr[3:0];
  
  // Set dst addr from instruction if instr is ADDZ and zr is asserted, else set dst addr to R0
  assign dst_addr = (!(instr[15:12] == opaddz)) ? instr[11:8] : 
										(zr) ? instr[11:8] : 4'b0000;
  
  // For SLL, SRL, and SRA use the immediate bits as normallly, for LLB shift by 8 bits with SRA
  assign shamt = !instr[15] ? instr[3:0] : 4'h8;
  
  // Enable all reads and writes unless it's a HLT
  assign {re0, re1, we} = {!hlt, !hlt, !hlt};
  
  // If it's the HLT instruction then HALT!
  assign hlt = &instr[15:12];

  // src1 for LLB and LHB should come from the immediate bits
  assign src1sel = instr[15];
   
  // Set ALU function to instruction function if opcodes start with 0, else set it to SRA for load low byte
  // Also check if opcode is ADDZ change it to ADD if it is
  assign func = (!instr[15]) ? ((instr[15:12] == opaddz) ?  funcadd : instr[14:12]) :                                                 
               								 ((instr[14:12] == oplhb) ?  funclhb : 
																													 (instr[14:12] == opllb) ?  funcllb : 
																																											 3'b000); // lw and sw should go here eventually
  

  
endmodule

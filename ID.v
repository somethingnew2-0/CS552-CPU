module ID(instr, addr, nextAddr, zr, ne, ov, p0_addr, re0, p1_addr, re1, memre, dst_addr, we, memwe, aluOp, shamt, jal, jr, hlt, src1sel, func, memtoreg);

  input [15:0] instr, addr;
  input zr, ne, ov;

  output [15:0] nextAddr;
  output [3:0] p0_addr, p1_addr, dst_addr, shamt;
  output re0, re1, memre, we, memwe, jal, jr, hlt, aluOp, src1sel, memtoreg;
  output [2:0] func;

  wire [15:0] nextBranchAddr;
  
  // Opcode for specified byte load
  localparam oplhb = 3'b010;
  localparam opllb = 3'b011;  

	// Opcode for loads and stores
	localparam oplw = 3'b000;
	localparam opsw = 3'b001;

  // Opcode for ADDZ
  localparam opaddz = 4'b0001;
  
  // ALU func for ADD
  localparam funcadd = 3'b000;
  // ALU func for specified load byte
  localparam funclhb = 3'b001;
  // llb should use the sra from the ALU with shamt 8
  localparam funcllb = 3'b111;
	// ALU func needed for loading and storing(add offset)
	localparam funclwsw = 3'b000;

	// Branch Codes, straight off the quick reference
	localparam neq 		= 3'b000;
	localparam eq 		= 3'b001;
	localparam gt 		= 3'b010;
	localparam lt 		= 3'b011;
	localparam gte 		= 3'b100;
	localparam lte 		= 3'b101;
	localparam ovfl 	= 3'b110;

 
	// Control instruction signals; ALU independant signals
	assign b = &instr[15:14] && ~|instr[13:12];
	assign jal = &instr[15:14] && ~instr[13] && instr[12];
	assign jr = &instr[15:13] && ~instr[12];
  assign hlt = &instr[15:12];

	assign nextBranchAddr = 
										(instr[11:9] == neq && !zr) ? addr + instr[8:0] :
										(instr[11:9] == eq && zr) ? addr + instr[8:0] : 
										(instr[11:9] == gt && !(zr || ne)) ? addr + instr[8:0] :
										(instr[11:9] == lt && ne) ? addr + instr[8:0] :
										(instr[11:9] == gte && !ne) ? addr + instr[8:0] :
										(instr[11:9] == lte && (ne || zr)) ? addr + instr[8:0] :
										(instr[11:9] == ovfl && ov) ? addr + instr[8:0] : 
										addr + instr[8:0];
										/* The check for uncond is implicit; if none of the other combinations are 
												true, it must be an unconditional branch */
	assign nextAddr = b   ? nextBranchAddr:
										jal ? $signed(instr[11:0]) + addr: 
										addr;


	// Let the Alu know if this is a typical aluOp or special (loading, storing, branching, jumping)
	assign aluOp = !instr[15];

  // Set src0 register address as normal unless it's LHB                                                 
  assign p0_addr = (instr[15:12] == 4'b1010) ? instr[11:8] : instr[7:4];

  // Set the src1 as normal for normal alu ops, however if it is SLL, SRL, or SRA set src1 to the src0 register addr
  // That way the LLB works properly since those operations are actually hooked up to src1 for input in the ALU
  assign p1_addr = (instr[15:13] == 3'b011 || instr[15:12] == 4'b0101) ? instr[7:4] : instr[3:0];
  
  // Set dst addr from instruction if instr is ADDZ and zr is asserted, else set dst addr to R0
  assign dst_addr = jal ? 4'hf:
										(!(instr[15:12] == opaddz)) ? instr[11:8] : 
										(zr) ? instr[11:8] : 4'h0;
  
  // For SLL, SRL, and SRA use the immediate bits normallly, for LLB shift by 8 bits with SRA
  assign shamt = !instr[15] ? instr[3:0] : 4'h8;
  
  // All re are always on
  assign {re0, re1, memre} = {!hlt, !hlt, !hlt};
  
	// Set we and memwe
	assign we = (aluOp | (instr[15] & ((instr[14:12] == oplw) | (instr[14:12] == opllb) | (instr[14:12] == oplhb))));
	
	assign memwe = (instr[15] & (instr[14:12] == opsw));

	// Set memtoreg
	assign memtoreg = (instr[15] & (instr[14:12] == oplw));

  // If it's the HLT instruction then HALT!


  // src1 for LLB,LHB, lw, and sw should come from the immediate bits
  assign src1sel = instr[15];
   
  /* Sets ALU function: 
			
			if(instruction starts with zero)
				if(func is opaddz)
					change to add (same alu operation)
				else
					pass the bitmask from the instruction through
			else if(func is lhb)
				pass through lhb bitmask
			else if(func is llb)
				pass through llb bitmask
			else
				pass through 000 (lw, sw)
	*/
  assign func = (!instr[15]) ? ((instr[15:12] == opaddz) ?  funcadd : instr[14:12]) : 
								((instr[14:12] == oplhb) ?  funclhb : 
								(instr[14:12] == opllb) ?  funcllb : 
								3'b000); // lw and sw are included in this, as they use add op
  
endmodule

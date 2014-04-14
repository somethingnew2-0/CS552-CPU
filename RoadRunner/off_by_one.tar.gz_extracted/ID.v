module ID(instr, addr, nextAddr, zr, ne, ov, p0_addr, re0, p1_addr, re1, memre, dst_addr, we, memwe, memOp, aluOp, shamt, jal, jr, hlt, src0sel, func, memtoreg);

  input [15:0] instr, addr;
  input zr, ne, ov;

  output [15:0] nextAddr;
  output [3:0] p0_addr, p1_addr, dst_addr, shamt;
  output re0, re1, memre, we, memwe, memOp, jal, jr, hlt, aluOp, src0sel, memtoreg;
  output [2:0] func;

  wire [15:0] nextBranchAddr;
  
  // ALU func for ADD
  localparam funcadd = 3'b000;
  // ALU func for specified load byte
  localparam funclhb = 3'b001;
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
	localparam uncond = 3'b111;

	assign check = instr[11:9]; // Which branch type?
 
	// Control instruction signals; ALU independant signals
  assign addz = instr[15:12] == 4'b0001;
  assign lw = instr[15:12] == 4'b1000;
  assign sw = instr[15:12] == 4'b1001;
  assign lhb = instr[15:12] == 4'b1001;
  assign llb = instr[15:12] == 4'b1011;
  assign b = instr[15:12] == 4'b1100;
  assign jal = instr[15:12] == 4'b1101;
  assign jr = instr[15:12] == 4'b1110;
  assign hlt = instr[15:12] == 4'b1111;

	assign nextBranchAddr = 
										(instr[11:9] == uncond) ? addr + {{7{instr[8]}},instr[8:0]} :
										((instr[11:9] == neq) && !zr) ? addr + {{7{instr[8]}},instr[8:0]} :
										((instr[11:9] == eq) && zr) ? addr + {{7{instr[8]}},instr[8:0]} : 
										((instr[11:9] == gt) && !(zr || ne)) ? addr + {{7{instr[8]}},instr[8:0]} :
										((instr[11:9] == lt) && ne) ? addr + {{7{instr[8]}},instr[8:0]} :
										((instr[11:9] == gte) && !ne) ? addr + {{7{instr[8]}},instr[8:0]} :
										((instr[11:9] == lte) && (ne || zr)) ? addr + {{7{instr[8]}},instr[8:0]} :
										((instr[11:9] == ovfl) && ov) ? addr  +{{7{instr[8]}},instr[8:0]} : addr;														
										/* If it falls all the way to the bottom, the branch wasn't taken */

	assign nextAddr = b   ? nextBranchAddr :
										jal ? $signed(instr[11:0]) + addr : 
										addr;


	// Let the Alu know if this is a typical aluOp or special (loading, storing, branching, jumping)
	assign aluOp = !instr[15];

	assign memOp = lw | sw;

  // Set src0 register address as normal unless it's LHB                                                 
  assign p0_addr = lhb ? instr[11:8] : instr[7:4];

	// For LW and SW p1 addr is different, but for ALU Ops it should be the last 4 bits
  assign p1_addr = (sw | lhb) ? instr[11:8] : (lw ? instr[7:4] : (llb ? 4'h0: instr[3:0]));
  
  /*
		if(jal)
			R15
		else if(b)
			R0
		else if(!addz)
			Grab from instruction
		else if(Z)
			Grab from instruction
		else
			R0
	*/
  assign dst_addr = jal ? 4'hf:
										b ? 4'h0 :
										(!addz) ? instr[11:8] : 
										(zr) ? instr[11:8] : 4'h0;
  
  // For SLL, SRL, and SRA use the immediate bits normallly
  assign shamt = instr[3:0];
  
  // All re are always on
  assign {re0, re1} = {!hlt, !hlt};

  // src1 for LLB and LHB should come from the immediate bits
  assign src0sel = llb | lhb;

	// Set we and memwe
	assign we = jal | aluOp | lw | llb | lhb;

	assign memwe = sw;
	assign memre = !memwe;

	// Set memtoreg
	assign memtoreg = lw;
   
  /* Sets ALU function: 
			
			if(instruction starts with zero)
				if(func is addz)
					change to add (same alu operation)
				else
					pass the bitmask from the instruction through
			else if(func is lhb)
				pass through lhb bitmask
			else if(func is llb)
				pass through llb bitmask
			else if(branch)
				anything that isn't add or sub (so it won't set flags), 
				doesn't matter what because it will be written to R0		
			else
				pass through 000 (lw, sw)
	*/
  assign func = !instr[15] ? (addz ? funcadd : instr[14:12]) : 
								lhb ?  funclhb : 
								llb ?  funcadd : 
								b ? 3'b111 :
								3'b000; // lw and sw are included in this, as they use add op
  
endmodule

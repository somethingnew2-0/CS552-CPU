module ID(instr, rst_n, imm, p0Addr, p1Addr, regAddr, shamt, aluOp, branchOp, regRe0, regRe1, regWe, memRe, memWe, memToReg, addz, branch, jal, jr, aluSrc0, aluSrc1, ovEn, zrEn, neEn);

  input [15:0] instr;
  input rst_n;

  output [11:0] imm;
  output [3:0] p0Addr, p1Addr, regAddr, shamt;
  output [2:0] aluOp, branchOp;

  // Control signals
  output regRe0, regRe1, regWe, memRe, memWe, memToReg, addz, branch, jal, jr, aluSrc0, aluSrc1, ovEn, zrEn, neEn;
  
  // ALU func for ADD
  localparam aluAdd = 3'b000;
  // ALU func for specified load byte
  localparam aluLhb = 3'b001;
  // ALU func needed for loading and storing(add offset)
  localparam aluLwSw = 3'b000;

  // Control instruction signals; ALU independant signals
  assign add = instr[15:12] == 4'b0000;
  assign addz = instr[15:12] == 4'b0001;
  assign sub = instr[15:12] == 4'b0010;
  assign lw = instr[15:12] == 4'b1000;
  assign sw = instr[15:12] == 4'b1001;
  assign lhb = instr[15:12] == 4'b1010;
  assign llb = instr[15:12] == 4'b1011;
  assign branch = instr[15:12] == 4'b1100;
  assign jal = instr[15:12] == 4'b1101;
  assign jr = instr[15:12] == 4'b1110;

  assign imm = instr[11:0];

  // Set src0 register address as normal unless it's LHB                                                 
  assign p0Addr = lhb ? instr[11:8] : instr[7:4];

  // For LW and SW p1 addr is different, but for ALU Ops it should be the last 4 bits
  assign p1Addr = (sw | lhb) ? instr[11:8] : (lw ? instr[7:4] : (llb ? 4'h0: instr[3:0]));
  
  /*
    if(jal)
      R15
    else if(branch)
      R0
    else
      Grab from instruction
  */
  assign regAddr = jal ? 4'hf:
                   instr[11:8];
  
  // For SLL, SRL, and SRA use the immediate bits normallly
  assign shamt = instr[3:0];
  
  // All re are always on
  assign {regRe0, regRe1} = {1'b1, 1'b1};
  
  // Set we and memwe
  assign regWe = !addz & !sw & !branch & !jr;  // Everything except these
  
  assign memRe = !memWe;
  assign memWe = sw;
  
  // Set memToReg
  assign memToReg = lw;

  // Should the flags be updated after EX
  assign ovEn = add | addz | sub;
  assign zrEn = !instr[15];
  assign neEn = ovEn;

  // src1 for LLB and LHB should come from the immediate bits
  assign aluSrc0 = llb | lhb; 
  assign aluSrc1 = lw | sw;
   
  assign branchOp = instr[11:9]; // Which branch type?
   
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
  assign aluOp = !instr[15] ? (addz ? aluAdd : instr[14:12]) : 
                lhb ?  aluLhb : 
                llb ?  aluAdd :
                3'b000; // lw and sw are included in this, as they use add op
  
endmodule

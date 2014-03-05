module SRC_MUX(p1, instr, src1sel, src1);
  input[15:0] p1;
  input[7:0] instr;
  input src1sel;
  output[15:0] src1;
  
  assign src1 = src1sel ? {instr, 8'h00} : p1;
  
endmodule
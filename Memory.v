module Memory(clk, memRe, memWe, memAddr, wrtData, memData);
  input clk, memRe, memWe;
  input [15:0] memAddr, wrtData;

  output [15:0] memData;  //output of data memory

  DM dm(.clk(clk),
        .addr(memAddr),
        .re(memRe),
        .we(memWe),
        .wrt_data(wrtData),
        .rd_data(memData));

endmodule

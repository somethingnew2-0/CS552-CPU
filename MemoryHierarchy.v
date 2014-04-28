module mem_hierarchy (i_addr, instr, i_rdy, clk, rst_n, d_rdy, d_addr, re, we, wrt_data, rd_data);

input clk, rst_n, re, we;
input [15:0] i_addr, d_addr, wrt_data;

output i_rdy, d_rdy;
output [15:0] instr, rd_data;

reg i_we, i_re, d_dirt_in, d_we, d_re, m_we, m_re;
reg [13:0] m_addr;
reg [63:0] i_data, d_data, m_line_in;

wire i_hit, d_hit, d_dirt_out;
wire [7:0] i_tag, d_tag;
wire [63:0] i_line, d_line, m_line_out;

/* Instruction Cache */
cache icache(.clk(clk), 
						 .rst_n(rst_n), 
						 .addr(i_addr), 
						 .wr_data(i_data),
						 .wdirty(1'b0), /* ignore dirty bit for icache */
						 .we(i_we),
						 .re(i_re),

						 .hit(i_hit),
						 .dirty(1'b0),  /* ignore dirty bit for icache */
						 .rd_data(i_line),
						 .tag_out(i_tag));

/* Data Cache */
cache dcache(.clk(clk),
						 .rst_n(rst_n),
						 .addr(d_addr),
						 .wr_data(d_data),
						 .wdirty(d_dirt_in),
						 .we(d_we),
						 .re(d_re),

						 .hit(d_hit),
						 .dirty(d_dirt_out),
						 .rd_data(d_line),
						 .tag_out(d_tag));

/* Main Memory */
unified_mem main_mem(.clk(clk),
										 .rst_n(rst_n),
										 .re(m_re),
										 .we(m_we),
										 .addr(m_addr), /* Line address */
										 .wdata(m_data),

										 .rd_data(m_line),
										 .rdy(m_rdy_n)); /* Active low */

cache_controller controller(.clk(clk),
														.rst_n(rst_n),
														.i_hit(i_hit),
														.d_hit(d_hit),
														.d_dirt_out(d_dirt_out),
														.m_rdy_n(m_rdy_n),
														.i_tag(i_tag),
														.d_tag(d_tag),
														.i_line(i_line),
														.d_line(d_line),
														.m_line(m_line),

														.i_we(i_we),
														.i_re(i_re),
														.d_we(d_we),
														.d_re(d_re),
														.m_we(m_we),
														.m_re(m_re),
														.d_dirt_in(d_dirt_in),
														.i_addr(i_addr),
														.d_addr(d_addr),
														.m_addr(m_addr),
														.i_data(i_data),
														.d_data(d_data),
														.m_data(m_data));

endmodule

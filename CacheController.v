module cache_controller(clk, rst_n, i_hit, d_hit, d_dirt_out, m_rdy_n, i_tag, d_tag, i_line, d_line, m_line, i_addr, i_data, i_we, i_re, d_addr, d_data, d_dirt_in, d_we, d_re, m_re, m_we, m_addr, m_data);

/* Outputs from the memories */
input clk, rst_n, i_hit, d_hit, d_dirt_out, m_rdy_n;
input [7:0] i_tag, d_tag;
input [63:0] i_line, d_line, m_line;

/* Inputs to the memories */
output i_we, i_re, d_we, d_re, m_we, m_re, d_dirt_in;
output [13:0] i_addr, d_addr, m_addr;
output [63:0] i_data, d_data, m_data;



endmodule

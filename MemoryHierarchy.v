module mem_hierarchy (clk, rst_n, i_acc, d_rd_acc, d_wr_acc, i_addr, d_addr, d_wrt_data, stall, i_rdy, d_rdy, instr, data);

input clk, rst_n, i_acc, d_rd_acc, d_wr_acc; // Instruction accesses are assumed read
input [15:0] i_addr, d_addr, d_wrt_data;

output i_rdy, d_rdy;
output reg stall;
output [15:0] instr, data;

reg rd, wr, access_d, access_i;
reg [1:0] offset;
reg [15:0] wr_data, addr;

wire i_hit, d_hit, d_dirt_out, d_dirt_in, m_we, m_re;
wire [7:0] i_tag, d_tag;
wire [13:0] m_addr, i_addr_ctrl, d_addr_ctrl;
wire [63:0] i_line, d_line, m_line, i_data, d_data, m_data;

/* Instruction Cache */
cache icache(.clk(clk),
						 .rst_n(rst_n), 
						 .addr(i_addr_ctrl),
						 .wr_data(i_data),
						 .we(i_we),
						 .re(i_re),
						 .wdirty(),

						 .hit(i_hit),
						 .dirty(),
						 .rd_data(i_line),
						 .tag_out(i_tag));

/* Data Cache */
cache dcache(.clk(clk),
						 .rst_n(rst_n),
						 .addr(d_addr_ctrl),
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
										 .rdy(m_rdy_n));

cache_controller controller(.clk(clk),
														.rst_n(rst_n),
														.i_hit(i_hit),
														.d_hit(d_hit),
														.d_dirt_out(d_dirt_out),
														.mem_rdy(m_rdy_n),
														.i_tag(i_tag),
														.d_tag(d_tag),
														.i_line(i_line),
														.d_line(d_line),
														.m_line(m_line),
														.addr(addr),
														.wr_data(wr_data),
														.i_acc(access_i),
														.d_acc(access_d),
														.read(rd),
														.write(wr),

														.i_we(i_we),
														.i_re(i_re),
														.d_we(d_we),
														.d_re(d_re),
														.m_we(m_we),
														.m_re(m_re),
														.d_dirt_in(d_dirt_in),
														.i_addr(i_addr_ctrl),
														.d_addr(d_addr_ctrl),
														.m_addr(m_addr),
														.i_data(i_data),
														.d_data(d_data),
														.m_data(m_data),
														.i_rdy(i_rdy),
														.d_rdy(d_rdy));

/* Top Level Routing Logic */
always @(i_addr, d_addr, i_rdy, d_rdy, rst_n) begin

	// Check for completion (instr_rdy && data_rdy)
	if(!d_rdy & !i_rdy)
		stall = 1'b1;
	else
		stall = 1'b0;

	// Choose what input we are currently dealing with
	if((d_rd_acc | d_wr_acc) & !d_rdy) begin
		addr = d_addr;
		access_d = 1'b1;
		access_i = 1'b0;
		stall = 1'b1;
		
		if(d_wr_acc) begin
			wr_data = d_wrt_data;
			rd = 1'b0;
			wr = 1'b1;
		end else begin
			wr_data = 16'h0000;
			rd = 1'b1;
			wr = 1'b0;
		end
	end else if(!i_rdy) begin
		addr = i_addr;
		access_d = 1'b0;
		access_i = 1'b1;
		wr = 1'b0;
		rd = 1'b1;
		stall = 1'b1;
	end else begin
		stall = 1'b0; // Ready for more accesses
	end
end

/* Pick off instruction word
	if(offset[1])
		if(offset[0])
			select 3rd word
		else
			select 2nd word
	else
		if(offset[0])
			select 1st word
		else
			select 0th word
*/
assign instr = i_addr[1] ? (i_addr[0] ? i_line[63:48] : i_line[47:32]) : (i_addr[0] ? i_line[31:16] : i_line[15:0]);

/* Pick off data word
	if(offset[1])
		if(offset[0])
			select 3rd word
		else
			select 2nd word
	else
		if(offset[0])
			select 1st word
		else
			select 0th word
*/
assign data = d_addr[1] ? (d_addr[0] ? d_line[63:48] : d_line[47:32]) : (d_addr[0] ? d_line[31:16] : d_line[15:0]);

endmodule

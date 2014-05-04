module cache_controller(clk, rst_n, i_addr, d_addr, wr_data, i_acc, d_acc, read, write, i_hit, d_hit, dirty, mem_rdy, d_tag, d_line, m_line, i_data, i_we, d_data, d_dirt_in, d_we, d_re, m_re, m_we, m_addr, m_data, rdy);

/* Outputs from the memories */
input clk, rst_n, i_hit, d_hit, dirty, mem_rdy, i_acc, d_acc, read, write;
input [7:0] d_tag;
input [15:0] i_addr, d_addr, wr_data;
input [63:0] d_line, m_line;

/* Inputs to the memories */
output reg i_we, d_we, d_re, m_we, m_re, d_dirt_in, rdy;
output reg [13:0] m_addr;
output reg [63:0] i_data, d_data, m_data;

/* Variables */
reg [1:0] state, nextState;
reg [63:0] wiped;

localparam empty = 16'hFFFF; // Gets shifted in and then all 64 bits are flipped to create masks

/* State Definitions*/
localparam START = 2'b00;
localparam EXTRA = 2'b01;
localparam SERVICE_MISS = 2'b10;
localparam WRITE_BACK = 2'b11;

/* Clock state changes and handle reset */
always @(posedge clk, negedge rst_n)
	if(!rst_n) begin
		state <= START;
	end else
		state <= nextState;

/* FSM Logic */
always @(*) begin // Combinational

	/* Default output values */
	i_we = 1'b0;
	d_we = 1'b0;
	m_we = 1'b0;
	d_re = 1'b0;
	m_re = 1'b0;
	m_addr = 14'd0;
	i_data = 64'd0;
	d_data = 64'd0;
	m_data = d_line;
	d_dirt_in = 1'b0;
	rdy = 1'b0;
	nextState = START;
	
	case(state)
		START: 
			begin
				if(d_acc & !d_hit) begin // Prioritize data accesses
					if(dirty) begin
						m_addr = {d_tag, d_addr[7:2]};
						m_we = 1'b1;

						nextState = WRITE_BACK;
					end else begin // clean
						m_addr = d_addr[15:2];
						m_re = 1'b1;

						nextState = SERVICE_MISS;
					end
				end else if(i_acc & !i_hit) begin
					m_addr = i_addr[15:2];
					m_re = 1'b1;

					nextState = SERVICE_MISS;
				end else begin // Both caches are hitting
					if(write)
						begin // Our clean line is d_line
							d_we = 1'b1;
							wiped = d_line & ~(empty << 16 * d_addr[1:0]); // Wipe off word that is there
							d_data = wiped | (wr_data << 16 * d_addr[1:0]); // Mask in new data 
							d_dirt_in = 1'b1; // mark dirty
						end

					rdy = 1'b1;
				end
			end

		SERVICE_MISS: 
			begin
				if(mem_rdy) begin // Wait for the data

					if(d_acc & !d_hit) begin // If data isn't hitting, we must be servicing that request
						if(write) begin // mark dirty and mask in new data
							d_we = 1'b1;
							wiped = m_line & ~(empty << 16 * d_addr[1:0]); // Wipe off word that is there
							d_data = wiped | (wr_data << 16 * d_addr[1:0]); // Mask in new data 
							d_dirt_in = 1'b1;
						end else begin // leave clean and write straight back to d-cache
							d_we = 1'b1;
							d_data = m_line;
						end
					end else begin // data is hitting so we are servicing the instrution request
						i_we = 1'b1;
						i_data = m_line;
					end

					nextState = START; // cache should hit after it's written
				end else if(d_acc & !d_hit) begin // Hold the inputs to unified mem
					m_addr = d_addr[15:2];
					m_re = 1'b1;

					nextState = SERVICE_MISS;
				end else if(i_acc & !i_hit) begin // Hold the inputs to unified mem
					m_addr = i_addr[15:2];
					m_re = 1'b1;

					nextState = SERVICE_MISS;
				end
			end

		WRITE_BACK: // Only on dirty data misses
			begin 
 				// Hold the inputs to unified mem
				m_addr = {d_tag, d_addr[7:2]}; // addr of data currently in cache
				m_we = 1'b1;

				if(mem_rdy) begin
					nextState = EXTRA;
				end else begin
					nextState = WRITE_BACK;
				end
			end

		/* Only come here for starting mem read after a write back 
		(otherwise mem_rdy is already high and the wrong line gets
		written to the d-cache) */
		EXTRA:
			begin
				m_re = 1'b1;
				m_addr = d_addr[15:2];

				nextState = SERVICE_MISS;
			end

		default: 
			begin 
				// Leave everything at their defaults (see top)
			end
	endcase
end

endmodule

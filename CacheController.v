module cache_controller(clk, rst_n, i_addr, d_addr, wr_data, i_acc, d_acc, read, write, i_hit, d_hit, dirty, mem_rdy, i_tag, d_tag, i_line, d_line, m_line, i_addr, i_data, i_we, i_re, d_addr, d_data, d_dirt_in, d_we, d_re, m_re, m_we, m_addr, m_data, rdy);

/* Outputs from the memories */
input clk, rst_n, i_hit, d_hit, dirty, mem_rdy, i_acc, d_acc, read, write;
input [7:0] i_tag, d_tag;
input [15:0] i_addr, d_addr, wr_data;
input [63:0] i_line, d_line, m_line;

/* Inputs to the memories */
output reg i_we, i_re, d_we, d_re, m_we, m_re, d_dirt_in, rdy;
output reg [15:0] m_addr;
output reg [63:0] i_data, d_data, m_data;

/* Variables */
reg [1:0] state, nextState;
reg [63:0] wiped;

//wire [1:0] offset;
//wire [5:0] index;
//wire [7:0] tag;

localparam empty = 16'hFFFF; // Gets shifted in and then all 64 bits are flipped to create masks

//assign tag = addr[15:8];
//assign index = addr[7:2];
//assign offset = addr[1:0];

/* State Definitions*/
localparam START = 2'b00;
localparam WRITE_RETURN = 2'b01;
localparam SERVICE_MISS = 2'b10;
localparam WRITE_BACK = 2'b11;

/* Clock state changes and handle reset */
always @(posedge clk, negedge rst_n)
	if(!rst_n) begin
		state = START;
		nextState = START;
	end else
		state = nextState;

/* FSM Logic */
always @(*) begin // Combinational

	/* Default output values */
	i_we = 1'b0;
	d_we = 1'b0;
	m_we = 1'b0;
	i_re = 1'b0;
	d_re = 1'b0;
	m_re = 1'b0;
	m_addr = 14'd0;
	i_data = 64'd0;
	d_data = 64'd0;
	m_data = 64'd0;
	d_dirt_in = 1'b0;
	rdy = 1'b0;
	
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
					m_addr = i_addr;
					m_re = 1'b1;

					nextState = SERVICE_MISS;
				end else begin // Both caches are hitting
					if(write) begin 
						d_we = 1'b1;
						wiped = m_line & ~(empty << 16 * d_addr[1:0]); // Wipe off word that is there
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
				m_data = d_line;	// current data from d-cache
				m_we = 1'b1;

				if(mem_rdy) begin
					nextState = SERVICE_MISS;
				end else begin
					nextState = WRITE_BACK;
				end
			end
		default: 
			begin 
				// Leave everything at their defaults (see top)
			end
	endcase
end

endmodule

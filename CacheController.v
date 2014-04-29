module cache_controller(clk, rst_n, addr, wr_data, instr, data, read, write, i_hit, d_hit, d_dirt_out, mem_rdy, i_tag, d_tag, i_line, d_line, m_line, i_addr, i_data, i_we, i_re, d_addr, d_data, d_dirt_in, d_we, d_re, m_re, m_we, m_addr, m_data, rdy);

/* Outputs from the memories */
input clk, rst_n, i_hit, d_hit, d_dirt_out, mem_rdy, instr, data, read, write;
input [7:0] i_tag, d_tag;
input [15:0] addr, wr_data;
input [63:0] i_line, d_line, m_line;

/* Inputs to the memories */
output reg i_we, i_re, d_we, d_re, m_we, m_re, d_dirt_in, rdy;
output reg [13:0] i_addr, d_addr, m_addr;
output reg [63:0] i_data, d_data, m_data;

/* Variables */
reg state, nextState;
reg [15:0] wiped, dirty_data;

wire [1:0] offset;
wire [13:0] index;

localparam empty = 16'h0000;

assign index = addr[15:2];
assign offset = addr[1:0];

/* State Definitions*/
localparam START = 2'b00;
localparam WRITE_RETURN = 2'b01;
localparam SERVICE_MISS = 2'b10;
localparam WRITE_BACK = 2'b11;

/* Clock state changes and handle reset */
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		state = START;
	else
		state = nextState;

/* FSM Logic */
always @(state, i_hit, d_hit, d_dirt_out, mem_rdy, i_tag, d_tag, i_line, d_line, m_line) begin
	/* Default output values */
	i_we = 1'b0;
	d_we = 1'b0;
	m_we = 1'b0;
	i_re = 1'b0;
	d_re = 1'b0;
	m_re = 1'b0;
	i_addr = 14'd0;
	d_addr = 14'd0;
	m_addr = 14'd0;
	i_data = 64'd0;
	d_data = 64'd0;
	m_data = 64'd0;
	d_dirt_in = 1'b0;
	rdy = 1'b0;
	
	case(state)
		START: 
			begin
				// Apply inputs to caches
				i_re = instr & read;
				d_re = data & read;
				i_addr = index;
				d_addr = index;

				if(instr & i_hit) begin
					rdy = 1'b1; // Outputs of caches are relevant
					nextState = START; // Immediately move to next request
				end	else if(instr & !i_hit) begin
					// Apply inputs to main mem
					m_addr = index;
					m_re = 1'b1;
					// Go wait until it's done
					nextState = SERVICE_MISS;
				end else if(data & read & d_hit) begin
					rdy = 1'b1; // Outputs of caches are relevant
					nextState = START; // Immediately move to next request
				end else if(data & write & d_hit) begin
					// Write dirty data to d-cache
					d_we = 1'b1;
					d_addr = index;
					wiped = d_line & (empty << 16* offset);  // Mask off current word
					dirty_data = wiped | (wr_data << 16 * offset); // Mask in new word
					d_data = dirty_data;
					d_dirt_in = 1'b1; // Mark as dirty

					rdy = 1'b1; // Outputs of caches are relevant
					nextState = START; // Immediately move to next request
				end else if(data & !d_hit & d_dirt_out) begin // Read or Write
					// Write dirty data to main mem
					m_we = 1'b1;
					m_data = d_line;
					m_addr = index;

					nextState = WRITE_BACK;
				end else if(data & !d_hit & !d_dirt_out) begin // Read or Write
					nextState = SERVICE_MISS;
				end else if(data & d_hit) begin
					rdy = 1'b1; // Outputs of caches are relevant
					nextState = START; // Immediately move to next request
				end
			end
		WRITE_RETURN: // Can this be morphed with SERVICE_MISS to save a cycle? Maybe...
			begin
				d_re = 1'b1;
				d_addr = index;
				
				rdy = 1'b1;
				nextState = START;
			end
		SERVICE_MISS: 
			begin
				if(mem_rdy) begin // Wait for the data
					if(instr) begin
						// Write back to i-cache
						i_we = 1'b1;
						i_data = m_line;
						i_addr = index;

						rdy = 1'b1;
						nextState = START;
					end	else if(data & read) begin
						// Write clean data to d-cache
						d_we = 1'b1;
						d_data = m_line;
						d_addr = index;
		
						nextState = WRITE_RETURN; // Data Read Miss done
					end else if(data & write) begin
						// Write dirty data to d-cache
						d_we = 1'b1;
						wiped = d_line & (empty << 16* offset);  // Mask off current word
						dirty_data = wiped | (wr_data << 16 * offset); // Mask in new word
						d_data = dirty_data;
						d_addr = index;
						d_dirt_in = 1'b1;

						rdy = 1'b1;
						nextState = START; // Data Write Miss done
					end else
						nextState = START; // Don't forget the else case
				end else begin
					// Make sure to hold the inputs
					m_re = 1'b1;
					m_addr = index;

					nextState = SERVICE_MISS;
				end
			end
		WRITE_BACK: 
			begin
				if(mem_rdy)
					if(data & !d_hit & d_dirt_out) begin
						// Read out fresh data
						m_re = 1'b1;
						m_addr = index;

						nextState = SERVICE_MISS;
					end else
						nextState = START; // Don't forget the else case
				else
					nextState = WRITE_BACK;
			end
		default: begin end
	endcase
end

endmodule

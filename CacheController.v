module cache_controller(clk, rst_n, addr, wr_data, i_acc, d_acc, read, write, i_hit, d_hit, d_dirt_out, mem_rdy, i_tag, d_tag, i_line, d_line, m_line, i_addr, i_data, i_we, i_re, d_addr, d_data, d_dirt_in, d_we, d_re, m_re, m_we, m_addr, m_data, i_rdy, d_rdy);

/* Outputs from the memories */
input clk, rst_n, i_hit, d_hit, d_dirt_out, mem_rdy, i_acc, d_acc, read, write;
input [7:0] i_tag, d_tag;
input [15:0] addr, wr_data;
input [63:0] i_line, d_line, m_line;

/* Inputs to the memories */
output reg i_we, i_re, d_we, d_re, m_we, m_re, d_dirt_in, i_rdy, d_rdy;
output reg [13:0] i_addr, d_addr, m_addr;
output reg [63:0] i_data, d_data, m_data;

/* Variables */
reg [1:0] state, nextState;
reg [63:0] wiped, dirty_data;

wire [1:0] offset;
wire [5:0] index;
wire [7:0] tag;

localparam empty = 16'hFFFF; // Gets shifted in and then all 64 bits are flipped to create masks

assign tag = addr[15:8];
assign index = addr[7:2];
assign offset = addr[1:0];

/* State Definitions*/
localparam START = 2'b00;
localparam WRITE_RETURN = 2'b01;
localparam SERVICE_MISS = 2'b10;
localparam WRITE_BACK = 2'b11;

/* Clock state changes and handle reset */
always @(posedge clk, negedge rst_n)
	if(!rst_n) begin
		state = START;
	end else
		state = nextState;

/* FSM Logic */
always @(state, addr, wr_data, i_hit, d_hit, d_dirt_out, mem_rdy, i_tag, d_tag, i_line, d_line, m_line) begin
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
	i_rdy = 1'b0;
	d_rdy = 1'b0;
	
	case(state)
		START: 
			begin
				// Apply inputs to caches
				i_re = i_acc;
				d_re = d_acc;
				i_addr = {tag, index};
				d_addr = {tag, index};

				if(!d_acc) // We aren't asking for data, so we are 'done' fetching it
					d_rdy = 1'b1;

				if(i_acc & i_hit) begin
					i_rdy = 1'b1; // Outputs of caches are relevant
					nextState = START; // Immediately move to next request
				end	else if(i_acc & !i_hit) begin
					// Apply inputs to main mem
					m_addr = {tag, index};
					m_re = 1'b1;
					// Go wait until it's done
					nextState = SERVICE_MISS;
				end else if(d_acc & read & d_hit) begin
					d_rdy = 1'b1; // Outputs of caches are relevant
					nextState = START; // Immediately move to next request
				end else if(d_acc & write & d_hit) begin
					// Write dirty data to d-cache
					d_we = 1'b1;
					d_addr = {tag, index};
					wiped = d_line & ~(empty << 16 * offset);  // Mask off current word
					d_data = wiped | (wr_data << 16 * offset); // Mask in new word
					d_dirt_in = 1'b1; // Mark as dirty

					d_rdy = 1'b1;
					nextState = START;
				end else if(d_acc & !d_hit & d_dirt_out) begin // Read or Write (Dirty Miss)
					// Write dirty data to main mem
					m_we = 1'b1;
					m_data = d_line;
					m_addr = {d_tag, index};

					nextState = WRITE_BACK;
				end else if(d_acc & !d_hit & !d_dirt_out) begin // Read or Write (Clean Miss)
					m_re = 1'b1;
					m_addr = {tag, index};

					nextState = SERVICE_MISS;
				end
			end
		WRITE_RETURN: // Can this be morphed with SERVICE_MISS to save a cycle? Maybe...
			begin
				if(!d_acc) begin // We aren't asking for data, so we are 'done' fetching it
					d_rdy = 1'b1;
					i_rdy = 1'b1;
				end else /* d_acc */ begin
					i_rdy = 1'b0;
					d_rdy = 1'b1;
				end

				nextState = START;
			end
		SERVICE_MISS: 
			begin
				if(!d_acc) // We aren't asking for data, so we are 'done' fetching it
					d_rdy = 1'b1;

				if(mem_rdy) begin // Wait for the data
					if(i_acc) begin
						// Write back to and read from i-cache
						i_we = 1'b1;
						i_re = 1'b1;
						i_data = m_line;
						i_addr = {tag, index};

						nextState = WRITE_RETURN; // Instruction read miss done
					end	else if(d_acc & read) begin
						// Write clean data to and read from d-cache
						d_we = 1'b1;
						d_re = 1'b1;
						d_data = m_line;
						d_addr = {tag, index};
		
						nextState = WRITE_RETURN; // Data Read Miss done
					end else if(d_acc & write) begin
						// Write dirty data to d-cache
						d_we = 1'b1;
						wiped = m_line & ~(empty << 16 * offset);  // Mask off current word
						d_data = wiped | (wr_data << 16 * offset); // Mask in new word
						d_addr = {tag, index};
						d_dirt_in = 1'b1;

						d_rdy = 1'b1;
						nextState = START; // Data Write Miss done
					end else
						nextState = START; // Don't forget the else case
				end else begin
					// Make sure to hold the inputs
					m_re = 1'b1;
					m_addr = {tag, index};
/*
					if(d_acc & !d_hit & d_dirt_out)
						m_addr = {d_tag, index};
					else
						m_addr = {tag, index};
*/
					nextState = SERVICE_MISS;
				end
			end
		WRITE_BACK:
			begin 
				if(!d_acc) // We aren't asking for data, so we are 'done' fetching it
					d_rdy = 1'b1;

				if(mem_rdy)
					if(d_acc & !d_hit & d_dirt_out) begin
						// Read out fresh data
						m_re = 1'b1;
						m_addr = {tag, index};

						nextState = SERVICE_MISS;
					end else
						nextState = START; // Don't forget the else case
				else begin
					// Hold inputs until mem is ready
					d_re = d_acc; // So we continue to have access to tag bits
					d_addr = {tag, index};
					m_we = 1'b1;
					m_data = d_line;
					m_addr = {d_tag, index};

					nextState = WRITE_BACK;
				end
			end
		default: begin end
	endcase
end

endmodule

module interrupt(
	clk,
	rst,
	status,
	oping,
	intreg
);
input clk;
input rst;
input [7:0] status;
input oping;
output [7:0] intreg;
reg [7:0] intregtemp;
reg [7:0] statustemp;
reg [7:0] intgen;
reg [7:0] intreg;
reg [1:0] current_state;
reg [1:0] next_state;

parameter IDLE=2'b00;
parameter READING=2'b01;
parameter CLEAR=2'b10;
parameter POS_CLEAR=2'b11;
parameter TRUE=1'b1;
parameter FALSE=1'b0;

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		statustemp <= 8'hff;
		intgen <= 8'hff;
	end
	else
	begin
		statustemp <= status;
		intgen <= status ^~ statustemp;
	end
end

always @(current_state or oping)
begin
	case(current_state)
		IDLE:
		begin
			if(oping==TRUE)
			begin
				next_state=READING;
			end
			else
			begin
				next_state=IDLE;
			end
		end

		READING:
		begin
			if(oping==FALSE)
			begin
				next_state=CLEAR;
			end
			else
				next_state=READING;
		end

		CLEAR:
		begin
			next_state=POS_CLEAR;
		end

		POS_CLEAR:
		begin
			next_state=IDLE;
		end

		default:
		begin
			next_state=IDLE;
		end
	endcase
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		intreg<=8'hff;
		intregtemp<=8'hff;
	end
	else
	begin
		case(current_state)
			IDLE:
			begin
				intregtemp<=8'hff;
				intreg<=intreg&intgen;
			end

			READING:
			begin
				intregtemp<=intregtemp&intgen;
			end

			CLEAR:
			begin
				intreg<=8'hff;
				intregtemp<=intregtemp&intgen;
			end

			POS_CLEAR:
			begin
				intreg<=intgen&intregtemp;
			end

			default:
				;
		endcase
	end
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		current_state<=IDLE;
	end
	else
	begin
		current_state<=next_state;
	end
end

endmodule

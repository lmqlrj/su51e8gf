module interrupt(
        clk,
        rst_n,
        status,
        reading_int,
	int_mask,
        intreg,
	int_bit
);
input clk;
input rst_n;
input [7:0] status;
input reading_int;
input int_mask;
output [7:0] intreg;
output int_bit;
reg [7:0] intregtemp;
reg [7:0] status_delay;
reg [7:0] intgen;
reg [7:0] intreg;
reg int_bit;
reg [1:0] current_state;
reg [1:0] next_state;

parameter IDLE=2'b00;
parameter READING=2'b01;
parameter CLEAR=2'b10;
parameter POS_CLEAR=2'b11;
parameter TRUE=1'b1;
parameter FALSE=1'b0;

always @(posedge clk or negedge rst_n)
begin
        if(~rst_n)
        begin
                status_delay <= 8'hff;
                intgen <= 8'hff;
        end
        else
        begin
                status_delay <= status;
                intgen <= status ^~ status_delay;
        end
end

always @(current_state or reading_int)
begin
        case(current_state)
                IDLE:
                begin
                        if(reading_int==TRUE)
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
                        if(reading_int==FALSE)
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

always @(posedge clk or negedge rst_n)
begin
        if(~rst_n)
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

always @(posedge clk or negedge rst_n)
begin
        if(~rst_n)
        begin
                current_state<=IDLE;
        end
        else
        begin
                current_state<=next_state;
        end
end

always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		int_bit<=1'b0;
	end
	else if((intreg!=8'hff)&&(int_mask==1'b0))
	begin
		int_bit<=1'b1;
	end
	else
	begin
		int_bit<=1'b0;
	end
end

endmodule

module clk_gen(
                clk,
                rst_n,
		counter_5us,
                clk_100hz,
                clk_6hz
                );
input clk;
input rst_n;
output counter_5us;
output clk_6hz;
output clk_100hz;
reg [8:0] counter_100k;
reg  [14:0]     counter;
reg            clk_100hz;
reg counter_5us;
assign clk_6hz = counter[14];

always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		counter <= 0;
	else if(counter_5us==1'b1)
		counter<=counter+1;
	else
		;
end

always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		clk_100hz<=1'b0;
	else if(counter[10:0]==0)
		clk_100hz<=1'b1;
	else
		clk_100hz<=1'b0;
end

always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==1'b0)
		  begin
			  counter_100k<=9'b000000000;
			  counter_5us<=1'b0;
		  end
		else if (counter_100k==9'b101001101)
			begin
			  counter_100k<=9'b000000000;
			  counter_5us<=1'b1;
			end
		else
		begin
			counter_100k<=counter_100k+9'b000000001;
			counter_5us<=1'b0;
		end
	end
endmodule

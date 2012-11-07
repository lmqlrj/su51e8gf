module counter(
                clk,
                rst,
                clk_100hz,
                clk_6hz
                );
input clk;
input rst;
output clk_6hz;
output clk_100hz;
reg  [15:0]     counter;
wire            clk_100hz;
wire            clk_6hz;
assign clk_100hz = counter[9];
assign clk_6hz = counter[13];

always @(posedge clk or negedge rst)
begin
	if(rst == 1'b0)
	begin
		counter <= 16'h0000;
	end
	else
	begin
		counter<=counter+16'h0001;
	end
end
endmodule

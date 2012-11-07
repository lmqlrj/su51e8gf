module four_hz_timer (
	clk,
	rst_n,
	timer
);
input	clk;
input	rst_n;
output	timer;
reg	timer;
reg	[23:0]	counter;
always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		counter <= 24'h000000;
		timer <= 1'b0;
	end
	else
	begin
		counter <= counter + 1'b1;
		timer <= counter[23];
	end
end
endmodule

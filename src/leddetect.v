module leddetect (
	clk,
	rst_n,
	link,
	act,
	blink,
	led0,
	led1,
	led2,
	led3,
	led4,
	led5,
	led6,
	led7
);
input clk;
input rst_n;
input blink;
input [7:0] link;
input [7:0] act;
output led0;
output led1;
output led2;
output led3;
output led4;
output led5;
output led6;
output led7;
leddriver led_out0 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[0]),
	.act(act[0]),
	.ledout(led0)
);
leddriver led_out1 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[1]),
	.act(act[1]),
	.ledout(led1)
);
leddriver led_out2 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[2]),
	.act(act[2]),
	.ledout(led2)
);
leddriver led_out3 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[3]),
	.act(act[3]),
	.ledout(led3)
);
leddriver led_out4 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[4]),
	.act(act[4]),
	.ledout(led4)
);
leddriver led_out5 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[5]),
	.act(act[5]),
	.ledout(led5)
);
leddriver led_out6 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[6]),
	.act(act[6]),
	.ledout(led6)
);
leddriver led_out7 (
	.clk(clk),
	.rst_n(rst_n),
	.blink(blink),
	.link(link[7]),
	.act(act[7]),
	.ledout(led7)
);
endmodule
module leddriver (
	clk,
	rst_n,
	blink,
	link,
	act,
	ledout
);
input	clk;
input	rst_n;
input	blink;
input	link;
input	act;
output	ledout;
reg	ledout;
always @(posedge clk or negedge rst_n)
begin
	if(~rst_n)
	begin
		ledout <= 1'b1;
	end
	else if(link==1'b1)
	begin
		ledout <= 1'b1;
	end
	else if(act==1'b1)
	begin
		ledout <= 1'b0;
	end
	else
	begin
		ledout <= blink;
	end
end
endmodule
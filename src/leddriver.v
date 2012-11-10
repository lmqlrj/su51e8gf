module leddriver (
	blink,
	link,
	act,
	ledout0,
	ledout1,
	ledout2,
	ledout3,
	ledout4,
	ledout5,
	ledout6,
	ledout7
);
input	blink;
input [7:0] link;
input [7:0] act;
output ledout0;
output ledout1;
output ledout2;
output ledout3;
output ledout4;
output ledout5;
output ledout6;
output ledout7;
wire led_sw0;
wire led_sw1;
wire led_sw2;
wire led_sw3;
wire led_sw4;
wire led_sw5;
wire led_sw6;
wire led_sw7;
assign ledout0=(link[0]==1'b0)?led_sw0:1'bz;
assign ledout1=(link[1]==1'b0)?led_sw1:1'bz;
assign ledout2=(link[2]==1'b0)?led_sw2:1'bz;
assign ledout3=(link[3]==1'b0)?led_sw3:1'bz;
assign ledout4=(link[4]==1'b0)?led_sw4:1'bz;
assign ledout5=(link[5]==1'b0)?led_sw5:1'bz;
assign ledout6=(link[6]==1'b0)?led_sw6:1'bz;
assign ledout7=(link[7]==1'b0)?led_sw7:1'bz;
assign led_sw0=(act[0]==1'b0)?blink:1'b0;
assign led_sw1=(act[1]==1'b0)?blink:1'b0;
assign led_sw2=(act[2]==1'b0)?blink:1'b0;
assign led_sw3=(act[3]==1'b0)?blink:1'b0;
assign led_sw4=(act[4]==1'b0)?blink:1'b0;
assign led_sw5=(act[5]==1'b0)?blink:1'b0;
assign led_sw6=(act[6]==1'b0)?blink:1'b0;
assign led_sw7=(act[7]==1'b0)?blink:1'b0;
endmodule

module leddriver (
	blink,
	link,
	act,
	ledout
);
input	blink;
input	link;
input	act;
output	ledout;
reg	ledout;
always @(link or act or blink)
  begin
    case({link,act})
      2'b00:
        ledout=blink;
      2'b01:
        ledout=1'b0;
      default:
        ledout=1'b1;
    endcase
  end
endmodule

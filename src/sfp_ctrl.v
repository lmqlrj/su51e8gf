module sfp_ctrl(
                clk,
                clk_100hz,
                rst_n,
                
                sfp_only_pin,
                sfp_los_pin,
                
                sfp_only_reg,
                sfp_los_reg
                );
                
input clk;
input clk_100hz;
input rst_n;
                
input [7:0] sfp_only_pin;
input [7:0] sfp_los_pin;
                
output [7:0] sfp_only_reg;
output [7:0] sfp_los_reg;

reg [7:0]       sfp_only_reg;          //sfp online status register, R status
reg [7:0]       sfp_only_pad;          //sfp online status filter temp, R status

reg [7:0]       sfp_los_reg;           //sfp los status register, R status
reg [7:0]       sfp_los_pad;           //sfp los status filter temp, R status

//----------------------------sfp online status filter---------------
always @ (posedge clk or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		sfp_only_reg <= 8'hff;
		sfp_only_pad <= 8'hff;
	end
	else if(clk_100hz==1'b1)
	begin
		if(sfp_only_pin == sfp_only_pad)
		begin
			sfp_only_reg <= sfp_only_pad;
		end
		else
		begin
			sfp_only_pad <= sfp_only_pin;
		end
	end
	else
		;
end
//----------------------------sfp los status filter------------------
always @ (posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		sfp_los_reg <= 8'hff;
		sfp_los_pad <= 8'hff;
	end
	else if(clk_100hz==1'b1)
	begin
		if(sfp_los_pin == sfp_los_pad)
		begin
			sfp_los_reg <= sfp_los_pad;
		end
		else
		begin
			sfp_los_pad <= sfp_los_pin;
		end
	end
	else
		;
end
endmodule

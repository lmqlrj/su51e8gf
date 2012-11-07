/*=======================================*\
Filename: iic.v
Author: Donghao	
Description: iic controll 
Called by: KW51ESPU  
Revision History:07_05_26
Revision 1.0
Email:dhcoffee@huawei.com
Company: Huawei Technology .Inc
Copyright(c) 1999, Huawei Technology Inc, All right reserved
\*=======================================*/

module iic(
	command,	//read or write command register
	fail,		//1 mean IIC operate fail
	busy,		//1 mean IIC controller busy
	data_in,	//data read from IIC device
	data_out,	//data write to IIC device
	add,		//address of IIC device
	dev_id,
	clk,		//globle clk net
	rst_n,		//globle asynchronous reset signal
	//clk1m,
	sda,		//IIC1 sda signal
	scl,		//IIC1 scl signal
	software_wp     //eeprom write protect signal
	);

input	clk;
//input   clk1m;
input	rst_n;
input	[6:0] dev_id;
input	[1:0] command;
input	[7:0] add;
input	[7:0] data_out;
input	software_wp;
output	fail;
output	busy;
output	[7:0] data_in;

output	scl;
inout	sda;


wire	sda;
wire	scl;
wire	[7:0] data_out;
wire	iic_sda_in;		//read in signal

reg	[7:0] data_in;
reg	read_command;
reg	write_command;
reg	flag_iic_fail;
reg	fail;
reg	fail2;
reg	[9:0] cnt_20us;		//statement change recycle
reg	iic_sda_out;
reg	iic_scl_out;
reg	[2:0] iic_cnt;		//iic timer,use to clock out&in data(8 bits data)
reg	iic_restart;		//use by read operate,1 active
reg	command_over;		//command operation finish signal,1 active
reg	sda_delay;
reg	[5:0] next_state;
reg	[5:0] current_state;
reg [4:0] prescl_cnt;


parameter	YES=1'b1;
parameter	NO=1'b0;
parameter	LOW=1'b0;
parameter	HIGH_Z=1'b1;
parameter	ZERO=0;


//state machine define
parameter	START=5'h16;

parameter   PRESTART_WL=5'h17;
parameter	PRESTART_WH=5'h18;

parameter	CHIPADDR_WL=5'h00;		//L mean scl to be 0;
parameter	CHIPADDR_WH=5'h01;		//H mean scl to be 1;
parameter	CHIPACK_WL=5'h02;
parameter	CHIPACK_WH=5'h03;

parameter	WORDADDR_WL=5'h04;		//memory address inside eeprom
parameter	WORDADDR_WH=5'h05;
parameter	WORDACK_WL=5'h06;
parameter	WORDACK_WH=5'h07;

parameter	WDATA_WL=5'h08;			//write data to memory
parameter	WDATA_WH=5'h09;
parameter	WDATAACK_WL=5'h0a;
parameter	WDATAACK_WH=5'h0b;
parameter	OPERATE_OVER=5'h0c;


parameter	READ=5'h0d;
parameter	READ_TEMP=5'h0e;
parameter	RESTART=5'h0f;			//follow the chip address signal over,judge read from device or write

parameter	RDATA_WL=5'h10;			//read data from iic device
parameter	RDATA_WH=5'h11;
parameter	RDATAACK_WL=5'h12;
parameter	RDATAACK_WH=5'h13;

parameter	PAUSE=5'h14;
parameter	IDLE=5'h15;			//send the end signal




assign	busy=write_command | read_command | command_over;
assign	sda=(sda_delay==LOW) ? LOW : 1'bz;
assign	scl=(iic_scl_out==LOW) ? LOW : 1'b1;
assign	iic_sda_in = sda;



//**********************************
//******command judge***************
//**********************************
//judge the write command 
always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
			begin
				write_command<=NO;
				fail2<=NO;
			end

		else if (command[1]==YES)
			begin
				if (software_wp==NO)
					begin
						write_command<=YES;
						fail2<=NO;
					end
				else
					begin
						fail2<=YES;
					end
			end
		else if (command_over==YES && write_command==YES)
			write_command<=NO;
	end

//judge the read command
always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
			read_command<=NO;
		else if (command[0]==YES)
			read_command<=YES;
		else if (command_over==YES && read_command==YES)
			read_command<=NO;
	end
							
		

//**********************************
//******timer***********************
//**********************************

//20us counter,use by the state change of state machine
always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
			cnt_20us<=ZERO;
		else if (cnt_20us==10'b1010011010)
			cnt_20us<=ZERO;
		else
			cnt_20us<=cnt_20us+1'b1;
	end



//*************************************
//******iic state controll*************
//*************************************			
always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
				current_state<=PRESTART_WL;
		else if (cnt_20us==ZERO)
				current_state<=next_state;
	end


always @ (current_state or read_command or write_command or iic_cnt or iic_restart or iic_sda_in or command
			or prescl_cnt)
	begin
		case (current_state)
			PRESTART_WL:
				begin
					if (read_command==YES || write_command==YES)
						next_state = PRESTART_WH;
					else
						next_state = PRESTART_WL;
				end
			
			PRESTART_WH:
				begin
					if (prescl_cnt==4'b1111)
						next_state = START;
					else
						next_state = PRESTART_WL;
				end
			START:
				begin
					next_state = CHIPADDR_WL;
				end

			CHIPADDR_WL:
				begin
					next_state=CHIPADDR_WH;		//write the chip address
				end

			CHIPADDR_WH:
				begin
					if (iic_cnt==3'b111)
						next_state=CHIPACK_WL;		//if the 8-bits address not finish,go back to CHIPADDR_WL
					else
						next_state=CHIPADDR_WL;
				end

			CHIPACK_WL:
				begin
					next_state=CHIPACK_WH;
				end
			
			CHIPACK_WH:
				begin
					if (iic_restart==NO)
						next_state=WORDADDR_WL;
					else
						next_state=RDATA_WL;
				end
				

			WORDADDR_WL:
				begin
					case (iic_cnt)
						5'h00:	
							begin
								if(iic_sda_in==LOW)
									next_state=WORDADDR_WH;
								else
									next_state=PAUSE;
							end
						5'h01:	next_state=WORDADDR_WH;
						5'h02:	next_state=WORDADDR_WH;
						5'h03:	next_state=WORDADDR_WH;
						5'h04:	next_state=WORDADDR_WH;
						5'h05:	next_state=WORDADDR_WH;
						5'h06:	next_state=WORDADDR_WH;
						5'h07:	next_state=WORDADDR_WH;
						default:	next_state=PAUSE;
					endcase
				end

			WORDADDR_WH:
				begin
					if (iic_cnt==3'b111)
						next_state=WORDACK_WL;
					else
						next_state=WORDADDR_WL;
				end

			WORDACK_WL:
				begin
					next_state=WORDACK_WH;
				end

			WORDACK_WH:
				begin
					if (write_command==YES)
						next_state=WDATA_WL;
					else	next_state=READ;
				end

			WDATA_WL:
				begin
					case (iic_cnt)
						3'b000:	
							begin
								if (iic_sda_in==LOW)
									next_state=WDATA_WH;
								else
									next_state=PAUSE;
							end
						3'b001:	next_state=WDATA_WH;
						3'b010:	next_state=WDATA_WH;
						3'b011:	next_state=WDATA_WH;
						3'b100:	next_state=WDATA_WH;
						3'b101:	next_state=WDATA_WH;
						3'b110:	next_state=WDATA_WH;
						3'b111:	next_state=WDATA_WH;
						default:;
					endcase
				end

			WDATA_WH:
				begin
					if (iic_cnt==3'b111)
						next_state=WDATAACK_WL;
					else
						next_state=WDATA_WL;
				end

			WDATAACK_WL:
				begin
					next_state=WDATAACK_WH;
				end

			WDATAACK_WH:
				begin
					next_state=OPERATE_OVER;
				end

			OPERATE_OVER:
				begin
					next_state=PAUSE;
				end

			READ:
				begin
					if (iic_sda_in==LOW)
						next_state=READ_TEMP;
					else
						next_state=PAUSE;
				end

			READ_TEMP:
				begin
					next_state=RESTART;
				end

			RESTART:
				begin
					next_state = START;
				end

			RDATA_WL:
				begin
					case (iic_cnt)
						3'b000:	
							begin
								if(iic_sda_in==LOW)
									next_state=RDATA_WH;
								else
									next_state=PAUSE;
							end
						3'b001:	next_state=RDATA_WH;
						3'b010:	next_state=RDATA_WH;
						3'b011:	next_state=RDATA_WH;
						3'b100:	next_state=RDATA_WH;
						3'b101:	next_state=RDATA_WH;
						3'b110:	next_state=RDATA_WH;
						3'b111:	next_state=RDATA_WH;
						default:;
					endcase
				end

			RDATA_WH:
				begin
					if (iic_cnt==3'b111)
						next_state=RDATAACK_WL;
					else
						next_state=RDATA_WL;
				end

			RDATAACK_WL:
				begin
					next_state=RDATAACK_WH;
				end

			RDATAACK_WH:
				begin
					next_state=OPERATE_OVER;
				end

			PAUSE:
				begin
					next_state=IDLE;
				end

			IDLE:
				begin
					if (command == 2'b0)				//donghao 2007-7-11 15:50
						next_state=PRESTART_WL;
					else
						next_state=IDLE;
				end


			default:
				begin
					next_state=PRESTART_WL;
				end
		endcase
	end

always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
			begin
				data_in<=ZERO;
				iic_sda_out<=HIGH_Z;
				iic_scl_out<=HIGH_Z;
				iic_cnt<=ZERO;
				command_over<=NO;
				flag_iic_fail<=NO;
				iic_restart<=NO;
				prescl_cnt<=ZERO;
			end
		else if (cnt_20us==ZERO)
			begin
				case (current_state)
					PRESTART_WL:
						begin
							command_over<=NO;
							if (write_command==YES || read_command==YES)
								begin
									iic_sda_out<=HIGH_Z;
									flag_iic_fail<=NO;
									iic_scl_out<=LOW;
								end
							else
								 ;
						end
						
					PRESTART_WH:
						begin
							iic_scl_out<=HIGH_Z;
							if (prescl_cnt==4'b1111)
								prescl_cnt<=4'b0;
							else
								prescl_cnt<=prescl_cnt+1'b1;
				      end
				
					START:
						begin
							iic_sda_out<=LOW;
						end

					CHIPADDR_WL:
						begin
							iic_scl_out<=LOW;
							case (iic_cnt)
								3'b000:	iic_sda_out<= dev_id [6];
								3'b001:	iic_sda_out<= dev_id [5];
								3'b010:	iic_sda_out<= dev_id [4];
								3'b011:	iic_sda_out<= dev_id [3];
								3'b100:	iic_sda_out<= dev_id [2];
								3'b101:	iic_sda_out<= dev_id [1];
								3'b110:	iic_sda_out<= dev_id [0];
								3'b111:	iic_sda_out<=iic_restart;
								default:;
							endcase
						end

					CHIPADDR_WH:
						begin
							iic_scl_out<=HIGH_Z;
							if (iic_cnt==3'b111)
								iic_cnt<=3'b000;
							else
								iic_cnt<=iic_cnt+1'b1;

						end

					CHIPACK_WL:
						begin
							iic_scl_out<=LOW;
							iic_sda_out<=HIGH_Z;
						end

					CHIPACK_WH:
						begin
							iic_scl_out<=HIGH_Z;
							if (iic_restart==NO)
								 ;
							else	iic_restart<=NO;
						end
							
					WORDADDR_WL:
						begin
							iic_scl_out<=LOW;
							case (iic_cnt)
								5'h00:
									begin
										if (iic_sda_in==LOW)
											iic_sda_out <= add [7];
										else
											begin
												flag_iic_fail<=YES;
												iic_cnt<=ZERO;
												iic_sda_out<=LOW;
											end
									end
								5'h01:	iic_sda_out <= add [6];
								5'h02:	iic_sda_out <= add [5];
								5'h03:	iic_sda_out <= add [4];
								5'h04:	iic_sda_out <= add [3];
								5'h05:	iic_sda_out <= add [2];
								5'h06:	iic_sda_out <= add [1];
								5'h07:	iic_sda_out <= add [0];
								default:
									begin
										flag_iic_fail<=YES;
										iic_sda_out<=LOW;
									end
							endcase
						end

					WORDADDR_WH:
						begin
							iic_scl_out<=HIGH_Z;
							if (iic_cnt==3'b111)
								iic_cnt<=3'b000;
							else
								iic_cnt<=iic_cnt+1'b1;
						end
								
					WORDACK_WL:
						begin
							iic_scl_out<=LOW;
							iic_sda_out<=HIGH_Z;
						end

					WORDACK_WH:
						begin
							iic_scl_out<=HIGH_Z;
						end

					WDATA_WL:
						begin
							iic_scl_out<=LOW;
							case (iic_cnt)
								3'b000:
									begin
										if (iic_sda_in==LOW)
											begin
												iic_sda_out<=data_out[7];
											end
										else
											begin
												iic_sda_out<=LOW;
												flag_iic_fail<=YES;
											end
									end
								3'b001:	iic_sda_out<=data_out[6];
								3'b010:	iic_sda_out<=data_out[5];
								3'b011:	iic_sda_out<=data_out[4];
								3'b100:	iic_sda_out<=data_out[3];
								3'b101:	iic_sda_out<=data_out[2];
								3'b110:	iic_sda_out<=data_out[1];
								3'b111:	iic_sda_out<=data_out[0];
								default:;
							endcase
						end
										
					WDATA_WH:
						begin
							iic_scl_out<=HIGH_Z;
							if (iic_cnt==3'b111)
								iic_cnt<=3'b000;
							else
								iic_cnt<=iic_cnt+1'b1;
						end
							
					WDATAACK_WL:
						begin
							iic_scl_out<=LOW;
							iic_sda_out<=HIGH_Z;
						end

					WDATAACK_WH:
						begin
							iic_scl_out<=HIGH_Z;
						end

					OPERATE_OVER:
						begin
							iic_scl_out<=LOW;
							iic_sda_out<=LOW;
							if (write_command==YES)
								begin
									if (iic_sda_in==LOW)
										flag_iic_fail<=NO;
									else
										flag_iic_fail<=YES;
								end
						end
										
								
					READ:
						begin
							if (iic_sda_in==LOW)
							 	iic_scl_out<=LOW;
							else
								begin
									iic_sda_out<=LOW;
									iic_scl_out<=LOW;
								end
						end

					READ_TEMP:
						begin
							iic_sda_out<=LOW;
							iic_scl_out<=HIGH_Z;							
						end

					RESTART:
						begin
							iic_sda_out<=HIGH_Z;
							iic_scl_out<=HIGH_Z;
							iic_restart<=YES;
						end


					RDATA_WL:
						begin
							case (iic_cnt)
								3'b000:
									begin
										if (iic_sda_in==LOW)
											 ;
										else
											begin
												flag_iic_fail<=YES;
												iic_sda_out<=LOW;
											end
									end
								3'b001:	data_in[7]<=iic_sda_in;
								3'b010:	data_in[6]<=iic_sda_in;
								3'b011:	data_in[5]<=iic_sda_in;
								3'b100:	data_in[4]<=iic_sda_in;
								3'b101:	data_in[3]<=iic_sda_in;
								3'b110:	data_in[2]<=iic_sda_in;
								3'b111:	data_in[1]<=iic_sda_in;
							endcase
							iic_scl_out<=LOW;
						end
									
					RDATA_WH:
						begin
							iic_scl_out<=HIGH_Z;
							if (iic_cnt==3'b111)
								iic_cnt<=ZERO;
							else
								iic_cnt<=iic_cnt+1'b1;
						end
							
					RDATAACK_WL:
						begin
							iic_scl_out<=LOW;
							data_in[0]<=iic_sda_in;
						end

					RDATAACK_WH:
						begin
							iic_scl_out<=HIGH_Z;
						end

					PAUSE:
						begin
							iic_scl_out<=HIGH_Z;
						end

					IDLE:
						begin
							iic_sda_out<=HIGH_Z;
							iic_restart<=NO;
							command_over<=YES;
						end

					default:
						begin
							iic_sda_out<=HIGH_Z;
							iic_scl_out<=HIGH_Z;
							iic_cnt<=ZERO;
							command_over<=YES;
							flag_iic_fail<=YES;
							iic_restart<=NO;
						end
				endcase
			end
	end

//*************************************
//****** SDA signal *******************
//*************************************		

always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
			sda_delay<=HIGH_Z;
		else
			sda_delay<=iic_sda_out;
	end

//*************************************
//****** fail signal ******************
//*************************************	

always @ (posedge clk or negedge rst_n)
	begin
		if (rst_n==0)
			fail<=NO;
		else
			fail<=flag_iic_fail & fail2;
	end

endmodule


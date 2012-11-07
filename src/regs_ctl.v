//************************************************************************************
//                           Design Information
//------------------------------------------------------------------------------------
//
//           Copyright(c) 2007, Huawei Technologies Co., Ltd.
//                        All rights reserved
//
// Project      : SPU3SPCA
// File         : regs_ctl.v
// Author       : s90003029
// Email        : 
// Version      : 1.0 
// Module       : regs_ctl
// Called by    : spu3spca_cpld.V
// Created      : 2008/12/04
// Last Modified: 2007/12/xx
//------------------------------------------------------------------------------------
//                           Revision History
//------------------------------------------------------------------------------------
// Version      Date(yyyy/mm/dd)   Change Author          Log                             
//  1.0         2008/12/04         s90003029             create
//  
//------------------------------------------------------------------------------------
//                           Description 
//------------------------------------------------------------------------------------
//   main function:
//   1.0  : realize the internal Registers and Control Logic of  CPLD
//   2.0  : .......................
//   3.0  : .......................
//************************************************************************************
module regs_ctl( 
                rst_n,                     //Global Reset
                clk,                       //Core Clock
                
                cplda_lbus_a,           
                cplda_lbus_d,           
                cplda_lbus_cs_n,    
                cplda_lbus_wr_n,     
                cplda_lbus_rd_n,     
                cplda_lbus_rdy_n,  
                cplda_lbus_int_n, 
                
		lm80,
		adt75,
		lm80_reset_n,

		led_test0,
		led_test1,
		led_test2,
		led_test3,

		sfp_only_pin,
		sfp_los_pin,
		txdis,
		tx_fault,

		sda_in,
		scl0,
		scl1,
		scl2,
		scl3,
		scl4,
		scl5,
		scl6,
		scl7,
		sda,

		led0,
		led1,
		led2,
		led3,
		led4,
		led5,
		led6,
		led7,

		jtag_con,
		jtag_sys,
		tck,
		tdi,
		tms,
		tdo,

		board_online_status
                );            
              
input           rst_n; 
input           clk; 

input  [9:0]    cplda_lbus_a;           
inout  [7:0]    cplda_lbus_d;           
input           cplda_lbus_cs_n;    
input           cplda_lbus_wr_n;     
input           cplda_lbus_rd_n;     
output          cplda_lbus_rdy_n;  
output          cplda_lbus_int_n;  
                
inout	sda_in;
input	lm80;
input	adt75;
output	lm80_reset_n;

output	led_test0;
output	led_test1;
output	led_test2;
output	led_test3;

input	board_online_status;

input	[7:0]	sfp_only_pin;//sfp ABS pin
input	[7:0]	sfp_los_pin;//sfp LOS pin
input	[7:0]	tx_fault;//sfp tx_fault pin
output	[7:0]	txdis;//sfp txdis pin

output	led0;
output	led1;
output	led2;
output	led3;
output	led4;
output	led5;
output	led6;
output	led7;

output	scl0;
output	scl1;
output	scl2;
output	scl3;
output	scl4;
output	scl5;
output	scl6;
output	scl7;
inout	sda;

output	jtag_con;
output	jtag_sys;
output	tck;
output	tdi;
output	tms;
input	tdo;


reg     [7:0]   cplda_reg_rdata ;
reg     [7:0]   cplda_reg_wdata;
reg     [7:0]   cplda_reg_wdata_dly;                      
                

reg	[7:0]	data_width;//local bus data width register, read only
reg	[7:0]	cpld_version;//cpld version register, read only
reg	[7:0]	cpld_test;//cpld test register, read and write
reg	[7:0]	compiling_month;//cpld compiling month register, read only
reg	[7:0]	compiling_date;//cpld compiling date register, read only
reg	[7:0]	pcb_version;//board pcb version register, read only
reg	[7:0]	board_version;//board version register, read only
reg	[7:0]	board_config;//board configuration register, read only
reg	[7:0]	board_online;//board online status register, read only
reg	[7:0]	int_source;//int source register, read only, [7:0] reserved reserved reserved LOS ABS LM75 LM80
reg	[7:0]	int_mask;//int mask register, read and write
reg	[7:0]	debugging_led;//debugging led control register, read and write
reg	[7:0]	test_mode;//test mode selection register, read and write
reg	[7:0]	cpld_tck;//cpld tck register, write only
reg	[7:0]	cpld_tdi;//cpld tdi register, write only
reg	[7:0]	cpld_tdo;//cpld tdo register, read only
reg	[7:0]	cpld_tms;//cpld tms register, write only
reg	[7:0]	txdis;//sfp tx disable register, read and write
reg	[7:0]	led_link;//link led register, read and write
reg	[7:0]	led_act;//act led register, read and write
reg	[7:0]	jtag_sel;//JTAG loading mode selection register, read and write
reg	[7:0]	iic_sel;//SFP IIC selection register, write only
reg [7:0]	txfault;

reg	[6:0]	dev_id;
reg	[7:0]	add;
reg	[1:0]	command;
reg	[7:0]	data_out;
reg	software_wp;
reg	iic_dir;//1:CPLD->SFP;0:SFP->CPLD
reg	sda_temp;
                
reg     [7:0]   sfp_only_reg;//sfp online status register
reg	[7:0]	sfp_only_pad;//sfp online status filter temp
reg     [7:0]   sfp_only_reg_pad;
reg     [7:0]   sfp_inout_int;//sfp inout neg pulse
reg     [7:0]   sfp_los_reg;//sfp los status register
reg	[7:0]	sfp_los_pad;//sfp los status filter temp
reg     [7:0]   sfp_los_reg_pad; 
reg     [7:0]   fiber_inout_int;//link updown neg pulse
reg	sfp0_inout_n;
reg	sfp1_inout_n;
reg	sfp2_inout_n;
reg	sfp3_inout_n;
reg	sfp4_inout_n;
reg	sfp5_inout_n;
reg	sfp6_inout_n;
reg	sfp7_inout_n;
reg	sfp0_inout_pad1;
reg	sfp0_inout_pad2;
reg	sfp1_inout_pad1;
reg	sfp1_inout_pad2;
reg	sfp2_inout_pad1;
reg	sfp2_inout_pad2;
reg	sfp3_inout_pad1;
reg	sfp3_inout_pad2;
reg	sfp4_inout_pad1;
reg	sfp4_inout_pad2;
reg	sfp5_inout_pad1;
reg	sfp5_inout_pad2;
reg	sfp6_inout_pad1;
reg	sfp6_inout_pad2;
reg	sfp7_inout_pad1;
reg	sfp7_inout_pad2;
reg	sfp0_updown_n;
reg	sfp1_updown_n;
reg	sfp2_updown_n;
reg	sfp3_updown_n;
reg	sfp4_updown_n;
reg	sfp5_updown_n;
reg	sfp6_updown_n;
reg	sfp7_updown_n;
reg	sfp0_updown_pad1;
reg	sfp0_updown_pad2;
reg	sfp1_updown_pad1;
reg	sfp1_updown_pad2;
reg	sfp2_updown_pad1;
reg	sfp2_updown_pad2;
reg	sfp3_updown_pad1;
reg	sfp3_updown_pad2;
reg	sfp4_updown_pad1;
reg	sfp4_updown_pad2;
reg	sfp5_updown_pad1;
reg	sfp5_updown_pad2;
reg	sfp6_updown_pad1;
reg	sfp6_updown_pad2;
reg	sfp7_updown_pad1;
reg	sfp7_updown_pad2;
reg	[7:0]	abs_int_n_reg;
reg	[7:0]	los_int_n_reg;
reg	sfp_abs_n;
reg	sfp_los_n;
reg sfp_abs_rc;
reg	sfp_los_rc;
                

/*reg	[23:0]	led_timer;*/
/*reg	led_clk;*/
wire	led_counter;
reg	led0;
reg	led1;
reg	led2;
reg	led3;
reg	led4;
reg	led5;
reg	led6;
reg	led7;
reg             int_spca_reg_rc0;

reg          cplda_lbus_int_n;  
reg	lm80_int_n;
reg	adt75_os_n;

reg led_test1;
reg	led_test2;
reg	led_test3;

wire            lbus_reg_rd_n;
wire            lbus_reg_we_n;
wire	cplda_lbus_rdy_n;
                
wire	rst_n;
wire	lm80_reset_n;

wire	jtag_con;
wire	jtag_sys;

wire	fail;
wire	busy;
wire	[7:0]	data_in;
wire	scl;

parameter   LOGIC_VERSION = 8'h01;   //Logic Version Number
parameter   LOGIC_DATA_WIDTH = 8'h00;   //Data Width
parameter   LOGIC_COMPILING_MONTH = 8'ha4;   //Compiling Year and Month
parameter   LOGIC_COMPILING_DATE = 8'h0f;   //Compiling Date
parameter   PCB_BOARD_VERSION = 8'h01;   //Pcb Version Number
parameter   BOARD_MAN_VERSION = 8'h01;   //Board Version Number

assign  lbus_reg_rd_n = cplda_lbus_cs_n || cplda_lbus_rd_n;
assign  lbus_reg_we_n = cplda_lbus_cs_n || cplda_lbus_wr_n;
assign	cplda_lbus_rdy_n = (lbus_reg_rd_n && lbus_reg_we_n)?1'bz:0;
assign	lm80_reset_n = rst_n;
assign	led_test0 = (debugging_led[7:0] == 8'h01)?led_counter:debugging_led[0];
assign	jtag_con = jtag_sel[0];
assign	jtag_sys = ~jtag_con;
assign	tck = cpld_tck[0];
assign	tdi = cpld_tdi[0];
assign	tms = cpld_tms[0];
assign	scl0 = (iic_sel == 8'h01)?scl:1'bz;
assign	scl1 = (iic_sel == 8'h02)?scl:1'bz;
assign	scl2 = (iic_sel == 8'h03)?scl:1'bz;
assign	scl3 = (iic_sel == 8'h04)?scl:1'bz;
assign	scl4 = (iic_sel == 8'h05)?scl:1'bz;
assign	scl5 = (iic_sel == 8'h06)?scl:1'bz;
assign	scl6 = (iic_sel == 8'h07)?scl:1'bz;
assign	scl7 = (iic_sel == 8'h08)?scl:1'bz;
assign	sda = (iic_dir == 1'b1)?sda_temp:1'bz;//CPLD->SFP
assign	sda_in = (iic_dir == 1'b0)?sda_temp:1'bz;//SFP->CPLD


/*********************************************************************
------------------------------Local bus Read   ----------------------
*********************************************************************/ 

assign  cplda_lbus_d = (lbus_reg_rd_n)?8'hzz:cplda_reg_rdata;

always @(posedge clk or negedge rst_n)
    if(~rst_n)
        begin
            cplda_reg_rdata <= 8'h00;
        end
    else if(!lbus_reg_rd_n)
        begin
            case(cplda_lbus_a[9:0])
                 10'b0000000000:
                      cplda_reg_rdata <= cpld_test;//read cpld test register 
                 10'b0000000001:
                      cplda_reg_rdata <= data_width;//read data width register
                 10'b0000000010:
                      cplda_reg_rdata <= cpld_version;//read cpld version register
                 10'b0000000011:
                      cplda_reg_rdata <= compiling_month;//read cpld compiling month register
                 10'b0000000100:
                      cplda_reg_rdata <= compiling_date;//read cpld compiling date register
                 10'b0000000101:
                      cplda_reg_rdata <= pcb_version;//read pcb version register
                 10'b0000000110:
                      cplda_reg_rdata <= board_version;//read board version register
                 10'b0000000111:
                      cplda_reg_rdata <= board_config;//read board configuration register
                 10'b0000001010:
                      cplda_reg_rdata <= board_online;//read board online status register
                 10'b0000001101:
                      cplda_reg_rdata <= test_mode;//read cpld test mode selection register
                 10'b0000100111:
                      cplda_reg_rdata <= int_source;//read int source register
                 10'b0000101000:
                      cplda_reg_rdata <= int_mask;//read int mask register
                 10'b0000101111:
                      cplda_reg_rdata <= debugging_led;//read debugging led control register
	         10'b0000111000:
			 cplda_reg_rdata <= cpld_tdo;//read cpld tdo register
	         10'b0001000000:
			 cplda_reg_rdata <= txdis;//read cpld txdis register
	         10'b0001000001:
			 cplda_reg_rdata <= led_link;//read led link register
	         10'b0001000010:
			 cplda_reg_rdata <= led_act;//read led act register
	         10'b0001000011:
			 cplda_reg_rdata <= jtag_sel;//read jtag loading mode selection register
                 10'b0001001000:                                                                
			 cplda_reg_rdata <= data_in;//read IIC data input register
                 10'b0001001011:                                                                
			 cplda_reg_rdata <= {7'b0000000,fail};//read IIC fail flag
                 10'b0001001100:                                                                
			 cplda_reg_rdata <= {7'b0000000,busy};//read IIC busy flag
                 10'b0001010000: 
			 cplda_reg_rdata <= sfp_only_reg;
                 10'b0001010001: 
			 cplda_reg_rdata <= sfp_los_reg;
                 10'b0001010010: 
			 cplda_reg_rdata <= abs_int_n_reg;
                 10'b0001010011: 
			 cplda_reg_rdata <= los_int_n_reg;
                 default:
                      cplda_reg_rdata <= 8'h00;
            endcase
        end
                
/*********************************************************************
------------------------------Local bus Write   ----------------------
*********************************************************************/ 
                
always @(posedge clk or negedge rst_n)
    if(~rst_n)  
        begin   
            cplda_reg_wdata_dly <= 8'h00;
        end     
    else        
        begin
            cplda_reg_wdata_dly <= cplda_lbus_d;
        end
always @(posedge clk or negedge rst_n)
    if(~rst_n)
        begin
            cplda_reg_wdata     <= 8'h00;
        end
    else if(!lbus_reg_we_n)
        begin
            cplda_reg_wdata     <= cplda_reg_wdata_dly;
        end
    else
        begin
            cplda_reg_wdata     <= cplda_reg_wdata;
        end 
        
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        begin
		data_width <= LOGIC_DATA_WIDTH;
		cpld_version <= LOGIC_VERSION;
		compiling_month <= LOGIC_COMPILING_MONTH;
		compiling_date <= LOGIC_COMPILING_DATE;
		pcb_version <= PCB_BOARD_VERSION;
		board_version <= BOARD_MAN_VERSION;
		board_config <= 8'hff;
		test_mode <= 8'b00000011;
		cpld_test <= 8'b00000000;
		debugging_led <= 8'b00000001;
		cpld_tck <= 8'h00;
		cpld_tdi <= 8'hff;
		cpld_tms <= 8'hff;
		int_mask <= 8'hff;
		led_link <= 8'hff;
		led_act <= 8'hff;
		txdis <= 8'hff;
		jtag_sel <= 8'h00;
		iic_sel <= 8'h00;
		dev_id <= 7'b0000000;
		add <= 8'h00;
		command <= 2'b00;
		data_out <= 8'h00;
		software_wp <= 1'b0;
		iic_dir <= 1'b0;
		txfault <= 8'h00;
        end
    else if(!lbus_reg_we_n)
        begin
            case(cplda_lbus_a[9:0])
                10'b0000000000: 
			cpld_test <= ~cplda_reg_wdata;//write cpld test regigster
                10'b0000001101:                                                                
			test_mode <= cplda_reg_wdata;//write test mode selection register
		10'b0000101000:
			int_mask <= cplda_reg_wdata;//write int mask register
                10'b0000101111:                                                                
			debugging_led <= cplda_reg_wdata;//write debugging led register
                10'b0000111001:                                                                
			cpld_tdi <= cplda_reg_wdata;//write cpld tdi register
                10'b0000111011:                                                                
			cpld_tms <= cplda_reg_wdata;//write cpld tms register
                10'b0000111100:                                                                
			cpld_tck <= cplda_reg_wdata;//write cpld tck register
                10'b0001000000:                                                                
			txdis <= cplda_reg_wdata;//write sfp tx disable register
                10'b0001000001:                                                                
			led_link <= cplda_reg_wdata;//write led link register
                10'b0001000010:                                                                
			led_act <= cplda_reg_wdata;//write led act register
                10'b0001000011:                                                                
			jtag_sel <= cplda_reg_wdata;//write jtag loading selection register
                10'b0001000100:                                                                
			iic_sel <= cplda_reg_wdata;//write SFP IIC selection register
                10'b0001000101:                                                                
			dev_id <= cplda_reg_wdata[6:0];//write IIC device ID register
                10'b0001000110:                                                                
			add <= cplda_reg_wdata;//write IIC device internal address register
                10'b0001000111:                                                                
			command <= cplda_reg_wdata[1:0];//write IIC command register
                10'b0001001001:                                                                
			data_out <= cplda_reg_wdata;//write IIC data output register
                10'b0001001010:                                                                
			software_wp <= cplda_reg_wdata[0];//write IIC controller protection register
		10'b0001001101:
			iic_dir <= cplda_reg_wdata[0];//write IIC data direction register
                default:
                    begin
                        ;                        
                    end                      
            endcase
        end 
    else
        begin
		txfault <= tx_fault;
        end                                                    	
end                                                                    

//----------------------------sfp online status filter---------------
always @ (posedge led_counter or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		sfp_only_reg <= 8'hff;
		sfp_only_pad <= 8'hff;
	end
	else
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
end
//----------------------------sfp online status filter end------------

//----------------------------sfp los status filter------------------
always @ (posedge led_counter or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		sfp_los_reg <= 8'hff;
		sfp_los_pad <= 8'hff;
	end
	else
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
end
//----------------------------sfp los status filter end---------------
/*********************************************************************
------------------ SFP insert or pull signal   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp_only_reg_pad <= 8'hff;
    			sfp_inout_int<= 8'hff;
    		end
    	else
    		begin												
    			sfp_only_reg_pad <= sfp_only_reg;
    			sfp_inout_int<=sfp_only_reg_pad^~sfp_only_reg;				
    	        end		    				    
    end
/*********************************************************************
------------------ fiber insert or pull out signal   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp_los_reg_pad <= 8'hff;
    			fiber_inout_int <= 8'hff;				
    		end
    	else
    		begin												
    			sfp_los_reg_pad <= sfp_los_reg;
    			fiber_inout_int <= sfp_los_reg_pad^~sfp_los_reg;				
    	        end		    				    
    end
/*********************************************************************
------------------ SFP0 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp0_inout_n   <= 1'b1;			
    			sfp0_inout_pad1 <= 1'b1;				
    			sfp0_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp0_inout_pad1<=sfp_inout_int[0];
    			sfp0_inout_pad2 <= sfp0_inout_pad1;  
    			if((sfp0_inout_pad2==1'b1)&&(sfp0_inout_pad1==1'b0))
    			    begin
    			        sfp0_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp0_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP1 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp1_inout_n   <= 1'b1;			
    			sfp1_inout_pad1 <= 1'b1;				
    			sfp1_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp1_inout_pad1<=sfp_inout_int[1];
    			sfp1_inout_pad2 <= sfp1_inout_pad1;  
    			if((sfp1_inout_pad2==1'b1)&&(sfp1_inout_pad1==1'b0))
    			    begin
    			        sfp1_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp1_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP2 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp2_inout_n   <= 1'b1;			
    			sfp2_inout_pad1 <= 1'b1;				
    			sfp2_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp2_inout_pad1<=sfp_inout_int[2];
    			sfp2_inout_pad2 <= sfp2_inout_pad1;  
    			if((sfp2_inout_pad2==1'b1)&&(sfp2_inout_pad1==1'b0))
    			    begin
    			        sfp2_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp2_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP3 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp3_inout_n   <= 1'b1;			
    			sfp3_inout_pad1 <= 1'b1;				
    			sfp3_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp3_inout_pad1<=sfp_inout_int[3];
    			sfp3_inout_pad2 <= sfp3_inout_pad1;  
    			if((sfp3_inout_pad2==1'b1)&&(sfp3_inout_pad1==1'b0))
    			    begin
    			        sfp3_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp3_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP4 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp4_inout_n   <= 1'b1;			
    			sfp4_inout_pad1 <= 1'b1;				
    			sfp4_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp4_inout_pad1<=sfp_inout_int[4];
    			sfp4_inout_pad2 <= sfp4_inout_pad1;  
    			if((sfp4_inout_pad2==1'b1)&&(sfp4_inout_pad1==1'b0))
    			    begin
    			        sfp4_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp4_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP5 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp5_inout_n   <= 1'b1;			
    			sfp5_inout_pad1 <= 1'b1;				
    			sfp5_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp5_inout_pad1<=sfp_inout_int[5];
    			sfp5_inout_pad2 <= sfp5_inout_pad1;  
    			if((sfp5_inout_pad2==1'b1)&&(sfp5_inout_pad1==1'b0))
    			    begin
    			        sfp5_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp5_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP6 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp6_inout_n   <= 1'b1;			
    			sfp6_inout_pad1 <= 1'b1;				
    			sfp6_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp6_inout_pad1<=sfp_inout_int[6];
    			sfp6_inout_pad2 <= sfp6_inout_pad1;  
    			if((sfp6_inout_pad2==1'b1)&&(sfp6_inout_pad1==1'b0))
    			    begin
    			        sfp6_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp6_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP7 insert or pull out interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp7_inout_n   <= 1'b1;			
    			sfp7_inout_pad1 <= 1'b1;				
    			sfp7_inout_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp7_inout_pad1<=sfp_inout_int[7];
    			sfp7_inout_pad2 <= sfp7_inout_pad1;  
    			if((sfp7_inout_pad2==1'b1)&&(sfp7_inout_pad1==1'b0))
    			    begin
    			        sfp7_inout_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp7_inout_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP0 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp0_updown_n   <= 1'b1;			
    			sfp0_updown_pad1 <= 1'b1;				
    			sfp0_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp0_updown_pad1<=fiber_inout_int[0];
    			sfp0_updown_pad2 <= sfp0_updown_pad1;  
    			if((sfp0_updown_pad2==1'b1)&&(sfp0_updown_pad1==1'b0))
    			    begin
    			        sfp0_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp0_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP1 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp1_updown_n   <= 1'b1;			
    			sfp1_updown_pad1 <= 1'b1;				
    			sfp1_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp1_updown_pad1<=fiber_inout_int[1];
    			sfp1_updown_pad2 <= sfp1_updown_pad1;  
    			if((sfp1_updown_pad2==1'b1)&&(sfp1_updown_pad1==1'b0))
    			    begin
    			        sfp1_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp1_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP2 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp2_updown_n   <= 1'b1;			
    			sfp2_updown_pad1 <= 1'b1;				
    			sfp2_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp2_updown_pad1<=fiber_inout_int[2];
    			sfp2_updown_pad2 <= sfp2_updown_pad1;  
    			if((sfp2_updown_pad2==1'b1)&&(sfp2_updown_pad1==1'b0))
    			    begin
    			        sfp2_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp2_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP3 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp3_updown_n   <= 1'b1;			
    			sfp3_updown_pad1 <= 1'b1;				
    			sfp3_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp3_updown_pad1<=fiber_inout_int[3];
    			sfp3_updown_pad2 <= sfp3_updown_pad1;  
    			if((sfp3_updown_pad2==1'b1)&&(sfp3_updown_pad1==1'b0))
    			    begin
    			        sfp3_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp3_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP4 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp4_updown_n   <= 1'b1;			
    			sfp4_updown_pad1 <= 1'b1;				
    			sfp4_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp4_updown_pad1<=fiber_inout_int[4];
    			sfp4_updown_pad2 <= sfp4_updown_pad1;  
    			if((sfp4_updown_pad2==1'b1)&&(sfp4_updown_pad1==1'b0))
    			    begin
    			        sfp4_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp4_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP5 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp5_updown_n   <= 1'b1;			
    			sfp5_updown_pad1 <= 1'b1;				
    			sfp5_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp5_updown_pad1<=fiber_inout_int[5];
    			sfp5_updown_pad2 <= sfp5_updown_pad1;  
    			if((sfp5_updown_pad2==1'b1)&&(sfp5_updown_pad1==1'b0))
    			    begin
    			        sfp5_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp5_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP6 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp6_updown_n   <= 1'b1;			
    			sfp6_updown_pad1 <= 1'b1;				
    			sfp6_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp6_updown_pad1<=fiber_inout_int[6];
    			sfp6_updown_pad2 <= sfp6_updown_pad1;  
    			if((sfp6_updown_pad2==1'b1)&&(sfp6_updown_pad1==1'b0))
    			    begin
    			        sfp6_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp6_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
/*********************************************************************
------------------ SFP7 link up or down interrupt   ----------------
*********************************************************************/
always @(posedge clk or negedge rst_n)
    begin
    	if (rst_n == 1'b0)
    		begin
    			sfp7_updown_n   <= 1'b1;			
    			sfp7_updown_pad1 <= 1'b1;				
    			sfp7_updown_pad2 <= 1'b1;				
    		end
    	else
    		begin												
    			sfp7_updown_pad1<=fiber_inout_int[7];
    			sfp7_updown_pad2 <= sfp7_updown_pad1;  
    			if((sfp7_updown_pad2==1'b1)&&(sfp7_updown_pad1==1'b0))
    			    begin
    			        sfp7_updown_n<=1'b0;
    			    end
    			else if ((int_spca_reg_rc0 ==1'b1)&&(lbus_reg_rd_n == 1'b1))
    			    begin
    			    	sfp7_updown_n<=1'b1;
    			    end       									    	            
    	        end		    				    
    end
//----------------------SFP ABS interrupt------------------
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		abs_int_n_reg <= 8'hff;
		sfp_abs_n <= 1'b1;
		sfp_abs_rc <= 1'b0;
	end
	else if((cplda_lbus_a[9:0]==10'b0001010010)&&(lbus_reg_rd_n == 1'b0))
	begin
		sfp_abs_rc <= 1'b1;
	end
	else if((sfp_abs_rc==1'b1)&&(lbus_reg_rd_n == 1'b1))
	begin
		sfp_abs_rc <= 1'b0;
		abs_int_n_reg <= 8'hff;
	end
	else
	begin
		abs_int_n_reg[0] <= sfp0_inout_n;
		abs_int_n_reg[1] <= sfp1_inout_n;
		abs_int_n_reg[2] <= sfp2_inout_n;
		abs_int_n_reg[3] <= sfp3_inout_n;
		abs_int_n_reg[4] <= sfp4_inout_n;
		abs_int_n_reg[5] <= sfp5_inout_n;
		abs_int_n_reg[6] <= sfp6_inout_n;
		abs_int_n_reg[7] <= sfp7_inout_n;
		if(abs_int_n_reg != 8'hff)
		begin
			sfp_abs_n <= 0;
		end
	end
end
//----------------------SFP LOS interrupt------------------
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		los_int_n_reg <= 8'hff;
		sfp_los_n <= 1'b1;
		sfp_los_rc <= 1'b0;
	end
	else if((cplda_lbus_a[9:0]==10'b0001010011)&&(lbus_reg_rd_n == 1'b0))
	begin
		sfp_los_rc <= 1'b1;
	end
	else if((sfp_los_rc==1'b1)&&(lbus_reg_rd_n == 1'b1))
	begin
		sfp_los_rc <= 1'b0;
		los_int_n_reg <= 8'hff;
	end
	else
	begin
		los_int_n_reg[0] <= sfp0_updown_n;
		los_int_n_reg[1] <= sfp1_updown_n;
		los_int_n_reg[2] <= sfp2_updown_n;
		los_int_n_reg[3] <= sfp3_updown_n;
		los_int_n_reg[4] <= sfp4_updown_n;
		los_int_n_reg[5] <= sfp5_updown_n;
		los_int_n_reg[6] <= sfp6_updown_n;
		los_int_n_reg[0] <= sfp7_updown_n;
		if(los_int_n_reg != 8'hff)
		begin
			sfp_los_n <= 0;
		end
	end
end
//------------------------LM80 and ADT75 interrupt---------------
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		lm80_int_n <= 1'b1;
		adt75_os_n <= 1'b1;
	end
	else
	begin
		lm80_int_n <= lm80;
		adt75_os_n <= adt75;
	end
end
//---------------------Board online status----------------
always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		board_online <= 8'h01;
	end
	else if(board_online_status == 1'b0)
	begin
		board_online <= 8'h00;
	end
end

//--------------------int_reg read clear --------------------
always @(posedge clk or negedge rst_n)
    begin
        if (rst_n==1'b0) 
            begin
                int_source  <= 8'hff;
                int_spca_reg_rc0<=1'b0;
		cplda_lbus_int_n <= 1'b1;
            end
        else
            begin                     
                if((cplda_lbus_a[9:0]==10'b0000100111)&&(lbus_reg_rd_n == 1'b0))
		begin
                        int_spca_reg_rc0 <=1'b1;
		end
                else if((int_spca_reg_rc0==1'b1)&&(lbus_reg_rd_n==1'b1))
                    begin
                        int_source <= 8'hff;
                        int_spca_reg_rc0<= 1'b0;
                    end
                else
                    begin 
                        int_source [0]  <= (int_mask [0] == 1'b1)? lm80_int_n:1'b1; 
                        int_source [1]  <= (int_mask [1] == 1'b1)? adt75_os_n:1'b1; 
                        int_source [2]  <= (int_mask [2] == 1'b1)? sfp_abs_n:1'b1; 
                        int_source [3]  <= (int_mask [3] == 1'b1)? sfp_los_n:1'b1; 
                        int_source [4]  <= int_source [4];    
                        int_source [5]  <= int_source [5];    
                        int_source [6]  <= int_source [6];    
                        int_source [7]  <= int_source [7];            
                        int_spca_reg_rc0<= int_spca_reg_rc0;  
			cplda_lbus_int_n <= (int_source[0] && int_source[1]) && (int_source[2] && int_source[3]);
                    end            
            end
    end                                 

//-------------------------timer------------------------------------------
/*always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led_timer <= 24'h000000;
		led_clk <= 1'b0;
	end
	else
	begin
		led_clk <= led_timer[22];
		led_timer <= led_timer + 1'd1;
	end
end*/
//------------------------SFP0 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led0 <= 1'b1;
	end
	else if (led_link[0] == 1'b1)
	begin
		led0 <= 1'b1;
	end
	else if (led_act[0] == 1'b1)
	begin
		led0 <= 1'b0;
	end
	else
	begin
		led0 <= led_counter;
	end
end
//------------------------SFP1 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led1 <= 1'b1;
	end
	else if (led_link[1] == 1'b1)
	begin
		led1 <= 1'b1;
	end
	else if (led_act[1] == 1'b1)
	begin
		led1 <= 1'b0;
	end
	else
	begin
		led1 <= led_counter;
	end
end
//------------------------SFP2 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led2 <= 1'b1;
	end
	else if (led_link[2] == 1'b1)
	begin
		led2 <= 1'b1;
	end
	else if (led_act[2] == 1'b1)
	begin
		led2 <= 1'b0;
	end
	else
	begin
		led2 <= led_counter;
	end
end
//------------------------SFP3 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led3 <= 1'b1;
	end
	else if (led_link[3] == 1'b1)
	begin
		led3 <= 1'b1;
	end
	else if (led_act[3] == 1'b1)
	begin
		led3 <= 1'b0;
	end
	else
	begin
		led3 <= led_counter;
	end
end
//------------------------SFP4 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led4 <= 1'b1;
	end
	else if (led_link[4] == 1'b1)
	begin
		led4 <= 1'b1;
	end
	else if (led_act[4] == 1'b1)
	begin
		led4 <= 1'b0;
	end
	else
	begin
		led4 <= led_counter;
	end
end
//------------------------SFP5 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led5 <= 1'b1;
	end
	else if (led_link[5] == 1'b1)
	begin
		led5 <= 1'b1;
	end
	else if (led_act[5] == 1'b1)
	begin
		led5 <= 1'b0;
	end
	else
	begin
		led5 <= led_counter;
	end
end
//------------------------SFP6 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led6 <= 1'b1;
	end
	else if (led_link[6] == 1'b1)
	begin
		led6 <= 1'b1;
	end
	else if (led_act[6] == 1'b1)
	begin
		led6 <= 1'b0;
	end
	else
	begin
		led6 <= led_counter;
	end
end
//------------------------SFP7 LED control--------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led7 <= 1'b1;
	end
	else if (led_link[7] == 1'b1)
	begin
		led7 <= 1'b1;
	end
	else if (led_act[7] == 1'b1)
	begin
		led7 <= 1'b0;
	end
	else
	begin
		led7 <= led_counter;
	end
end
//-----------------------JTAG Mode---------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		cpld_tdo <= 8'b0;
	end
	else if (jtag_sel[0] == 1'b1)
	begin
		cpld_tdo[0] <= tdo;
	end
end
//-----------------------Led test----------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led_test1 <= 1'b1;
		led_test2 <= 1'b1;
		led_test3 <= sfp_abs_n;//test sfp abs int
	end
	else if (sfp_abs_n == 1'b0)
	begin
		led_test1 <= led_counter;
	end
	else if (sfp_los_n == 1'b0)
	begin
		led_test2 <= led_counter;
	end
/*	else if (txfault != 8'h00)
	begin
		led_test3 <= led_counter;
	end*/
end
//-----------------------IIC Controller----------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		sda_temp <= 1'b0;
	end	
	else if(iic_dir == 1'b1)
	begin
		sda_temp <= sda_in;
	end
	else
	begin
		sda_temp <= sda;
	end
end
iic i2c(
        .command(command),
        .fail(fail),
	.busy(busy),
	.data_in(data_in),
	.data_out(data_out),
	.add(add),
	.dev_id(dev_id),
	.clk(clk),
	.rst_n(rst_n),
	.sda(sda_in),
	.scl(scl),
	.software_wp(software_wp)
	);
bit22timer ledcounter(
	.clk(clk),
	.rst_n(rst_n),
	.timer(led_counter)
	);
endmodule

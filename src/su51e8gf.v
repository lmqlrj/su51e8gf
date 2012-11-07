//************************************************************************************
//                           Design Information
//------------------------------------------------------------------------------------
//
//           Copyright(c) 2007, Huawei Technologies Co., Ltd.
//                        All rights reserved
//
// Project      : SU51E8GF
// File         : su51e8gf.v
// Author       : l90003046
// Email        : 
// Version      : 1.0 
// Module       : su51e8gf
// Called by    : 
// Created      : 2010/05/01
// Last Modified: 2010/08/17
//------------------------------------------------------------------------------------
//                           Revision History
//------------------------------------------------------------------------------------
// Version      Date(yyyy/mm/dd)   Change Author          Log                             
//  1.0         2010/05/01         l90003046             create
//  
//------------------------------------------------------------------------------------
//                           Description 
//------------------------------------------------------------------------------------
//   main function:
//   1.0  : realize the internal Registers and Control Logic of  CPLD
//   2.0  : .......................
//   3.0  : .......................
//************************************************************************************
module su51e8gf( 
                rst_n,                     //Global Reset
                clk,                       //Core Clock
                
                cplda_lbus_a,              //Local Bus Address
                cplda_lbus_d,              //Local Bus Data
                cplda_lbus_cs_n,           //Local Bus CS
                cplda_lbus_wr_n,           //Local Bus Write
                cplda_lbus_rd_n,           //Local Bus Read
                cplda_lbus_rdy_n,          //Local Bus Ready
                cplda_lbus_int_n,          //Local Bus Interruption
                
                lm80,                      //LM80 Interruption
                adt75,                     //ADT75 Interruption
                lm80_reset_n,              //LM80 Reset

                led_test0,                 //Led Testing
                led_test1,
                led_test2,
                led_test3,

                sfp_only_pin,              //SFP ABS
                sfp_los_pin,               //SFP LOS
                txdis,                     //SFP TX Disable
                
                scl0,                      //SFP SCL
                scl1,
                scl2,
                scl3,
                scl4,
                scl5,
                scl6,
                scl7,
                sda,                       //SFP SDA

                led0,                      //SFP LEDs
                led1,
                led2,
                led3,
                led4,
                led5,
                led6,
                led7,
                
                jtag_con,                  //JTAG Connector Loading Selection
                jtag_sys,                  //JTAG Online Loading Selection
                tck,                       //Emulated TCK
                tdi,                       //Emulated TDI
                tms,                       //Emulated TMS
                tdo,                       //Emulated TDO

                board_online_status        //Board Online Status Detect
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
                
input	          lm80;
input	          adt75;
output	        lm80_reset_n;

output	        led_test0;
output          led_test1;
output          led_test2;
output          led_test3;

input           board_online_status;

input	[7:0]     sfp_only_pin;          //sfp ABS pin
input	[7:0]     sfp_los_pin;           //sfp LOS pin
output	[7:0]   txdis;                 //sfp txdis pin

output          led0;
output          led1;
output          led2;
output          led3;
output          led4;
output          led5;
output          led6;
output          led7;
                
output          scl0;
output          scl1;
output          scl2;
output          scl3;
output          scl4;
output          scl5;
output          scl6;
output          scl7;
inout           sda;

output          jtag_con;
output          jtag_sys;
output          tck;
output          tdi;
output          tms;
input           tdo;


reg [7:0]       cplda_reg_rdata ;
reg [7:0]       cplda_reg_wdata;
reg [7:0]       cplda_reg_wdata_dly;                      
                 
                
reg	[7:0]       cpld_test;             //cpld test register, read and write
reg	[3:0]       int_source;            //int source register, read only, [7:0] reserved reserved reserved LOS ABS LM75 LM80
reg	[3:0]       int_mask;              //int mask register, read and write
reg	[7:0]       debugging_led;         //debugging led control register, read and write
reg	[7:0]       test_mode;             //test mode selection register, read and write
reg             cpld_tck;              //cpld tck register, write only
reg             cpld_tdi;              //cpld tdi register, write only
reg             cpld_tdo;              //cpld tdo register, read only
reg             cpld_tms;              //cpld tms register, write only
reg [7:0]       txdis;                 //sfp tx disable register, read and write
reg [7:0]       led_link;              //link led register, read and write
reg [7:0]       led_act;               //act led register, read and write
reg             jtag_sel;              //JTAG loading mode selection register, read and write
reg [7:0]       iic_sel;               //SFP IIC selection register, write only
                
reg [6:0]       dev_id;                //IIC Device ID
reg [7:0]       add;                   //IIC Device Internal Address
reg [1:0]       command;               //IIC Command
reg [7:0]       data_out;              //IIC Data to Slave
reg             software_wp;           //IIC Module Write Protection
                 
reg [7:0]       sfp_only_reg;          //sfp online status register
reg [7:0]       sfp_only_pad;          //sfp online status filter temp
reg [7:0]       sfp_only_reg_pad;
reg [7:0]       sfp_inout_int;         //sfp inout neg pulse
reg [7:0]       sfp_los_reg;           //sfp los status register
reg [7:0]       sfp_los_pad;           //sfp los status filter temp
reg [7:0]       sfp_los_reg_pad; 
reg [7:0]       fiber_inout_int;       //link updown neg pulse
reg             sfp0_inout_n;
reg             sfp1_inout_n;
reg             sfp2_inout_n;
reg             sfp3_inout_n;
reg             sfp4_inout_n;
reg             sfp5_inout_n;
reg             sfp6_inout_n;
reg             sfp7_inout_n;
reg             sfp0_inout_pad1;
reg             sfp0_inout_pad2;
reg             sfp1_inout_pad1;
reg             sfp1_inout_pad2;
reg             sfp2_inout_pad1;
reg             sfp2_inout_pad2;
reg             sfp3_inout_pad1;
reg             sfp3_inout_pad2;
reg             sfp4_inout_pad1;
reg             sfp4_inout_pad2;
reg             sfp5_inout_pad1;
reg             sfp5_inout_pad2;
reg             sfp6_inout_pad1;
reg             sfp6_inout_pad2;
reg             sfp7_inout_pad1;
reg             sfp7_inout_pad2;
reg             sfp0_updown_n;
reg             sfp1_updown_n;
reg             sfp2_updown_n;
reg             sfp3_updown_n;
reg             sfp4_updown_n;
reg             sfp5_updown_n;
reg             sfp6_updown_n;
reg             sfp7_updown_n;
reg             sfp0_updown_pad1;
reg             sfp0_updown_pad2;
reg             sfp1_updown_pad1;
reg             sfp1_updown_pad2;
reg             sfp2_updown_pad1;
reg             sfp2_updown_pad2;
reg             sfp3_updown_pad1;
reg             sfp3_updown_pad2;
reg             sfp4_updown_pad1;
reg             sfp4_updown_pad2;
reg             sfp5_updown_pad1;
reg             sfp5_updown_pad2;
reg             sfp6_updown_pad1;
reg             sfp6_updown_pad2;
reg             sfp7_updown_pad1;
reg             sfp7_updown_pad2;
reg [7:0]       abs_int_n_reg;
reg [7:0]       los_int_n_reg;
reg             sfp_abs_n;
reg             sfp_los_n;
reg             sfp_abs_rc;
reg             sfp_los_rc;
                
wire            led_counter;

reg             int_spca_reg_rc0;

reg             cplda_lbus_int_n;  
reg             lm80_int_n;
reg             adt75_os_n;

reg             led_test1;
reg             led_test2;
reg             led_test3;

wire            lbus_reg_rd_n;
wire            lbus_reg_we_n;
wire            cplda_lbus_rdy_n;
                
wire            rst_n;
wire            lm80_reset_n;
                
wire            jtag_con;
wire            jtag_sys;
                
wire            fail;
wire            busy;
wire            [7:0]	data_in;
wire            scl;
wire            sda;

parameter       LOGIC_VERSION                 = 8'h01;   //Logic Version Number
parameter       LOGIC_DATA_WIDTH              = 8'h00;   //Data Width
parameter       LOGIC_COMPILING_MONTH         = 8'ha8;   //Compiling Year and Month
parameter       LOGIC_COMPILING_DATE          = 8'h19;   //Compiling Date
parameter       PCB_BOARD_VERSION             = 8'h01;   //Pcb Version Number
parameter       BOARD_MAN_VERSION             = 8'h01;   //Board Version Number
parameter       BOARD_CONFIG                  = 8'h00;   //Board Configration

/*---------------register addresses ---------------------------------*/
parameter       ADDR_CPLD_TEST                = 10'b0000000000;      //0x00
parameter       ADDR_DATA_WIDTH               = 10'b0000000001;      //0x01
parameter       ADDR_LOGIC_VERSION            = 10'b0000000010;      //0x02
parameter       ADDR_LOGIC_COMPILING_MONTH    = 10'b0000000011;      //0x03
parameter       ADDR_LOGIC_COMPILING_DATE     = 10'b0000000100;      //0x04
parameter       ADDR_PCB_BOARD_VERSION        = 10'b0000000101;      //0x05
parameter       ADDR_BOARD_MAN_VERSION        = 10'b0000000110;      //0x06
parameter       ADDR_BOARD_CONFIG             = 10'b0000000111;      //0x07
parameter       ADDR_BOARD_ONLINE_STATUS      = 10'b0000001010;      //0x0A
parameter       ADDR_TEST_MODE                = 10'b0000001101;      //0x0D
parameter       ADDR_INT_SOURCE               = 10'b0000100111;      //0x27
parameter       ADDR_INT_MASK                 = 10'b0000101000;      //0x28
parameter       ADDR_DEBUGGING_LED            = 10'b0000101111;      //0x2F
parameter       ADDR_CPLD_TDO                 = 10'b0000111000;      //0x38
parameter       ADDR_CPLD_TDI                 = 10'b0000111001;      //0x39
parameter       ADDR_CPLD_TMS                 = 10'b0000111011;      //0x3B
parameter       ADDR_CPLD_TCK                 = 10'b0000111100;      //0x3C
parameter       ADDR_TXDIS                    = 10'b0001000000;      //0x40
parameter       ADDR_LED_LINK                 = 10'b0001000001;      //0x41
parameter       ADDR_LED_ACT                  = 10'b0001000010;      //0x42
parameter       ADDR_JTAG_SEL                 = 10'b0001000011;      //0x43
parameter       ADDR_IIC_SEL                  = 10'b0001000100;      //0x44
parameter       ADDR_IIC_DEV                  = 10'b0001000101;      //0x45
parameter       ADDR_IIC_ADDR                 = 10'b0001000110;      //0x46
parameter       ADDR_IIC_COMMAND              = 10'b0001000111;      //0x47
parameter       ADDR_IIC_DATA_IN              = 10'b0001001000;      //0x48
parameter       ADDR_IIC_DATA_OUT             = 10'b0001001001;      //0x49
parameter       ADDR_IIC_WP                   = 10'b0001001010;      //0x4A
parameter       ADDR_IIC_FAIL                 = 10'b0001001011;      //0x4B
parameter       ADDR_IIC_BUSY                 = 10'b0001001100;      //0x4C
parameter       ADDR_SFP_ONLINE_STATUS        = 10'b0001010000;      //0x50
parameter       ADDR_SFP_LOS_STATUS           = 10'b0001010001;      //0x51
parameter       ADDR_SFP_ONLINE_INT           = 10'b0001010010;      //0x52
parameter       ADDR_SFP_LOS_INT              = 10'b0001010011;      //0x53

assign  lbus_reg_rd_n = cplda_lbus_cs_n || cplda_lbus_rd_n;
assign  lbus_reg_we_n = cplda_lbus_cs_n || cplda_lbus_wr_n;
assign	cplda_lbus_rdy_n = (lbus_reg_rd_n && lbus_reg_we_n)?1'bz:0;
assign	lm80_reset_n = rst_n;
assign	led_test0 = led_counter;
assign	jtag_con = jtag_sel;
assign	jtag_sys = ~jtag_con;
assign	tck = cpld_tck;
assign	tdi = cpld_tdi;
assign	tms = cpld_tms;
assign	scl0 = (iic_sel == 8'h00)?scl:1'bz;
assign	scl1 = (iic_sel == 8'h01)?scl:1'bz;
assign	scl2 = (iic_sel == 8'h02)?scl:1'bz;
assign	scl3 = (iic_sel == 8'h03)?scl:1'bz;
assign	scl4 = (iic_sel == 8'h04)?scl:1'bz;
assign	scl5 = (iic_sel == 8'h05)?scl:1'bz;
assign	scl6 = (iic_sel == 8'h06)?scl:1'bz;
assign	scl7 = (iic_sel == 8'h07)?scl:1'bz;

/*********************************************************************
------------------------------Local bus Read   ----------------------
*********************************************************************/ 

assign  cplda_lbus_d = (lbus_reg_rd_n)?8'hzz:cplda_reg_rdata;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        begin
            cplda_reg_rdata <= 8'h00;
        end
    else if(!lbus_reg_rd_n)
        begin
            case(cplda_lbus_a[9:0])
                 ADDR_CPLD_TEST:
                      cplda_reg_rdata <= cpld_test;
                 ADDR_DATA_WIDTH:
                      cplda_reg_rdata <= LOGIC_DATA_WIDTH;
                 ADDR_LOGIC_VERSION:
                      cplda_reg_rdata <= LOGIC_VERSION;
                 ADDR_LOGIC_COMPILING_MONTH:
                      cplda_reg_rdata <= LOGIC_COMPILING_MONTH;
                 ADDR_LOGIC_COMPILING_DATE:
                      cplda_reg_rdata <= LOGIC_COMPILING_DATE;
                 ADDR_PCB_BOARD_VERSION:
                      cplda_reg_rdata <= PCB_BOARD_VERSION;
                 ADDR_BOARD_MAN_VERSION:
                      cplda_reg_rdata <= BOARD_MAN_VERSION;
                 ADDR_BOARD_CONFIG:
                      cplda_reg_rdata <= BOARD_CONFIG;
                 ADDR_BOARD_ONLINE_STATUS:
                      cplda_reg_rdata <= {7'b000000,board_online_status};
                 ADDR_TEST_MODE:
                      cplda_reg_rdata <= test_mode;
                 ADDR_INT_SOURCE:
                      cplda_reg_rdata <= {4'b1111,int_source};
                 ADDR_INT_MASK:
                      cplda_reg_rdata <= {4'b1111,int_mask};
                 ADDR_DEBUGGING_LED:
                      cplda_reg_rdata <= debugging_led;
                 ADDR_CPLD_TDO:
                      cplda_reg_rdata <= cpld_tdo;
                 ADDR_TXDIS:
                      cplda_reg_rdata <= txdis;
                 ADDR_LED_LINK:
                      cplda_reg_rdata <= led_link;
                 ADDR_LED_ACT:
                      cplda_reg_rdata <= led_act;
                 ADDR_JTAG_SEL:
                      cplda_reg_rdata <= {7'b0000000,jtag_sel};
                 ADDR_IIC_DATA_IN:                                                                
                      cplda_reg_rdata <= data_in;
                 ADDR_IIC_FAIL:                                                                
                      cplda_reg_rdata <= {7'b0000000,fail};
                 ADDR_IIC_BUSY:                                                                
                      cplda_reg_rdata <= {7'b0000000,busy};
                 ADDR_SFP_ONLINE_STATUS: 
                      cplda_reg_rdata <= sfp_only_reg;
                 ADDR_SFP_LOS_STATUS: 
                      cplda_reg_rdata <= sfp_los_reg;
                 ADDR_SFP_ONLINE_INT: 
                      cplda_reg_rdata <= abs_int_n_reg;
                 ADDR_SFP_LOS_INT: 
                      cplda_reg_rdata <= los_int_n_reg;
                 default:
                      cplda_reg_rdata <= 8'h00;
            endcase
        end
	else
	begin
		;
	end
end
                
/*********************************************************************
------------------------------Local bus Write   ----------------------
*********************************************************************/ 
                
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)  
        begin   
            cplda_reg_wdata_dly <= 8'h00;
        end     
    else        
        begin
            cplda_reg_wdata_dly <= cplda_lbus_d;
        end
end
always @(posedge clk or negedge rst_n)
begin
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
end
        
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        begin
		test_mode <= 8'b00000011;
		cpld_test <= 8'b00000000;
		debugging_led <= 8'b00000001;
		cpld_tck <= 1'b0;
		cpld_tdi <= 1'b1;
		cpld_tms <= 1'b1;
		int_mask <= 4'hf;
		led_link <= 8'hff;
		led_act <= 8'hff;
		txdis <= 8'h00;
		jtag_sel <= 1'b0;
		iic_sel <= 8'h00;
		dev_id <= 7'b0000000;
		add <= 8'h00;
		command <= 2'b00;
		data_out <= 8'h00;
		software_wp <= 1'b0;
        end
    else if(!lbus_reg_we_n)
        begin
            case(cplda_lbus_a[9:0])
                ADDR_CPLD_TEST: 
			cpld_test <= ~cplda_reg_wdata;
                ADDR_TEST_MODE:                                                                
			test_mode <= cplda_reg_wdata;
		            ADDR_INT_MASK:
			int_mask <= cplda_reg_wdata[3:0];
                ADDR_DEBUGGING_LED:                                                                
			debugging_led <= cplda_reg_wdata;
                ADDR_CPLD_TDI:                                                                
			cpld_tdi <= cplda_reg_wdata[0];
                ADDR_CPLD_TMS:                                                                
			cpld_tms <= cplda_reg_wdata[0];
                ADDR_CPLD_TCK:                                                                
			cpld_tck <= cplda_reg_wdata[0];
                ADDR_TXDIS:                                                                
			txdis <= cplda_reg_wdata;
                ADDR_LED_LINK:                                                                
			led_link <= cplda_reg_wdata;
                ADDR_LED_ACT:                                                                
			led_act <= cplda_reg_wdata;
                ADDR_JTAG_SEL:                                                                
			jtag_sel <= cplda_reg_wdata[0];
                ADDR_IIC_SEL:                                                                
			iic_sel <= cplda_reg_wdata;
                ADDR_IIC_DEV:                                                                
			dev_id <= cplda_reg_wdata[6:0];
                ADDR_IIC_ADDR:                                                                
			add <= cplda_reg_wdata;
                ADDR_IIC_COMMAND:                                                                
			command <= cplda_reg_wdata[1:0];
                ADDR_IIC_DATA_OUT:                                                                
			data_out <= cplda_reg_wdata;
                ADDR_IIC_WP:                                                                
			software_wp <= cplda_reg_wdata[0];
                default:
                    begin
                        ;                        
                    end                      
            endcase
        end 
    else
        begin
        ;
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
	        	else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
			else
			    begin
				    ;
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
		else
	        begin
		    ;
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
		else
	        begin
		    ;
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
		else
                begin
		    ;
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
		else
	        begin
		    ;
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
		else
		begin
			;
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
		else
		begin
			;
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

//--------------------int_reg read clear --------------------
always @(posedge clk or negedge rst_n)
    begin
        if (rst_n==1'b0) 
        begin
                int_source  <= 4'hf;
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
                        int_source <= 4'hf;
                        int_spca_reg_rc0<= 1'b0;
                end
                else
                begin 
                        int_source [0]  <= (int_mask [0] == 1'b1)? lm80_int_n:1'b1; 
                        int_source [1]  <= (int_mask [1] == 1'b1)? adt75_os_n:1'b1; 
                        int_source [2]  <= (int_mask [2] == 1'b1)? sfp_abs_n:1'b1; 
                        int_source [3]  <= (int_mask [3] == 1'b1)? sfp_los_n:1'b1;       
                        int_spca_reg_rc0<= int_spca_reg_rc0;  
			cplda_lbus_int_n <= (int_source[0] && int_source[1]) && (int_source[2] && int_source[3]);
                end            
        end
    end                                 

//-----------------------JTAG Mode---------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		cpld_tdo <= 1'b0;
	end
	else
	begin
		cpld_tdo <= tdo;
	end
end
//-----------------------Led test----------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		led_test1 <= 1'b1;
		led_test2 <= 1'b1;
		led_test3 <= 1'b1;
	end
	else if (sfp_abs_n == 1'b0)
	begin
		led_test1 <= led_counter;
	end
	else if (sfp_los_n == 1'b0)
	begin
		led_test2 <= led_counter;
	end
	else
	begin
	led_test3 <= led_test3;
	end
end
leddetect ledout(
	.clk(clk),
	.rst_n(rst_n),
	.link(led_link),
	.act(led_act),
	.blink(led_counter),
	.led0(led0),
	.led1(led1),
	.led2(led2),
	.led3(led3),
	.led4(led4),
	.led5(led5),
	.led6(led6),
	.led7(led7)
);
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
	.sda(sda),
	.scl(scl),
	.software_wp(software_wp)
	);
four_hz_timer ledcounter(
	.clk(clk),
	.rst_n(rst_n),
	.timer(led_counter)
	);
endmodule

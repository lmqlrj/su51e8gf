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
module su51e8gf_top( 
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
                lm80_reset_n,              //LM80 Reset

                led_test0,                 //Led Testing

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
                tdo                       //Emulated TDO

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
output	        lm80_reset_n;

output	        led_test0;

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


wire [7:0] test_mode;
wire [7:0] debugging_led;
wire [6:0] dev_id;
wire [7:0] add;
wire [1:0] command;
wire [15:0] data_out;
wire [7:0] sfp_los_reg;
wire [7:0] sfp_only_reg;                
wire [7:0]       fiber_inout_int;       //link updown int reg
wire [7:0]       sfp_inout_int;         //sfp inout int reg
wire sfp_los_int_bit;
wire sfp_abs_int_bit;

                
wire [2:0]      int_mask;
wire            lm80;
                
wire            jtag_sel;
wire [7:0]      iic_sel;
                
wire            fail;
wire            busy;
wire            [15:0]	data_in;
wire            scl;
wire            sda;
wire two_bytes;
wire software_wp;

wire            clk_100khz;
wire            clk_100hz;
wire            clk_6hz;

wire            reading_abs_int;
wire            reading_los_int;

wire [7:0] led_link;
wire [7:0] led_act;



assign	lm80_reset_n = rst_n;
assign	led_test0 = clk_6hz;
assign	jtag_con = jtag_sel;
assign	jtag_sys = ~jtag_con;
assign	scl0 = (iic_sel == 8'h00)?scl:1'bz;
assign	scl1 = (iic_sel == 8'h01)?scl:1'bz;
assign	scl2 = (iic_sel == 8'h02)?scl:1'bz;
assign	scl3 = (iic_sel == 8'h03)?scl:1'bz;
assign	scl4 = (iic_sel == 8'h04)?scl:1'bz;
assign	scl5 = (iic_sel == 8'h05)?scl:1'bz;
assign	scl6 = (iic_sel == 8'h06)?scl:1'bz;
assign	scl7 = (iic_sel == 8'h07)?scl:1'bz;

                              



lb_reg_ctrl local_bus(
                .rst_n(rst_n),
                .clk(clk),                
                .cplda_lbus_a(cplda_lbus_a),
                .cplda_lbus_d(cplda_lbus_d),
                .cplda_lbus_cs_n(cplda_lbus_cs_n),
                .cplda_lbus_wr_n(cplda_lbus_wr_n),
                .cplda_lbus_rd_n(cplda_lbus_rd_n),
                .cplda_lbus_rdy_n(cplda_lbus_rdy_n),
                .cplda_lbus_int_n(cplda_lbus_int_n),
                .sfp_only_pin(sfp_only_reg),
                .sfp_los_pin(sfp_los_reg),
                .sfp_inout_int(sfp_inout_int),
                .fiber_inout_int(fiber_inout_int),                        
                .tdo(tdo),                
                .data_in(data_in),
                .fail(fail),
                .busy(busy),
                .txdis(txdis),
                .int_mask(int_mask),                
                .lm80(lm80),
                .sfp_los_int_bit(sfp_los_int_bit),
                .sfp_abs_int_bit(sfp_abs_int_bit),                
                .jtag_sel(jtag_sel),                
                .led_link(led_link),
                .led_act(led_act),                
                .test_mode(test_mode),
                .debugging_led(debugging_led),                
                .dev_id(dev_id),
                .add(add),
                .command(command),
                .data_out(data_out),
                .software_wp(software_wp),
                .two_bytes(two_bytes),
                .iic_sel(iic_sel),
                .reading_abs_int(reading_abs_int),
                .reading_los_int(reading_los_int),                
                .cpld_tck(tck),
                .cpld_tdi(tdi),
                .cpld_tms(tms)
                );

sfp_ctrl sfp_management(
                .clk(clk),
                .clk_100hz(clk_100hz),
                .rst_n(rst_n),                
                .sfp_only_pin(sfp_only_pin),
                .sfp_los_pin(sfp_los_pin),
                .int_mask(int_mask[1:0]),
                .sfp_inout_int(sfp_inout_int),
                .fiber_inout_int(fiber_inout_int),                
                .sfp_los_int_bit(sfp_los_int_bit),
                .sfp_abs_int_bit(sfp_abs_int_bit),                
                .sfp_only_reg(sfp_only_reg),
                .sfp_los_reg(sfp_los_reg)
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
	.software_wp(software_wp),
	.two_bytes(two_bytes),
	.clk_100khz(clk_100khz)
	);
	
interrupt abs_interruption(
		.clk(clk),
		.rst(rst_n),
		.status(sfp_only_reg),
		.oping(reading_abs_int),
		.intreg(sfp_inout_int)
	);
	
interrupt los_interruption(
		.clk(clk),
		.rst(rst_n),
		.status(sfp_los_reg),
		.oping(reading_los_int),
		.intreg(fiber_inout_int)
	);
	
	counter clk_gen(
	.clk(clk_100khz),
	.rst(rst_n),
	.clk_6hz(clk_6hz),
	.clk_100hz(clk_100hz)
	);
	
	leddriver led_out0 (
	.blink(clk_6hz),
	.link(led_link[0]),
	.act(led_act[0]),
	.ledout(led0)
);
leddriver led_out1 (
	.blink(clk_6hz),
	.link(led_link[1]),
	.act(led_act[1]),
	.ledout(led1)
);
leddriver led_out2 (
	.blink(clk_6hz),
	.link(led_link[2]),
	.act(led_act[2]),
	.ledout(led2)
);
leddriver led_out3 (
	.blink(clk_6hz),
	.link(led_link[3]),
	.act(led_act[3]),
	.ledout(led3)
);
leddriver led_out4 (
	.blink(clk_6hz),
	.link(led_link[4]),
	.act(led_act[4]),
	.ledout(led4)
);
leddriver led_out5 (
	.blink(clk_6hz),
	.link(led_link[5]),
	.act(led_act[5]),
	.ledout(led5)
);
leddriver led_out6 (
	.blink(clk_6hz),
	.link(led_link[6]),
	.act(led_act[6]),
	.ledout(led6)
);
leddriver led_out7 (
	.blink(clk_6hz),
	.link(led_link[7]),
	.act(led_act[7]),
	.ledout(led7)
);
endmodule

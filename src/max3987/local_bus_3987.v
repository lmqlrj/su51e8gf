module lb_reg_ctrl(
                rst_n,                     //Global Reset
                clk,                       //Core Clock
                
                cplda_lbus_a,              //Local Bus Address
                cplda_lbus_d,              //Local Bus Data
                cplda_lbus_cs_n,           //Local Bus CS
                cplda_lbus_wr_n,           //Local Bus Write
                cplda_lbus_rd_n,           //Local Bus Read
                cplda_lbus_rdy_n,          //Local Bus Ready
                cplda_lbus_int_n,          //Local Bus Interruption);
                
//--------------status ports------------------------------------------

                sfp_only_pin,              //SFP ABS
                sfp_los_pin,               //SFP LOS        
                sfp_inout_int,
                fiber_inout_int,
                        
                tdo,                       //Emulated TDO
                
                data_in,
                fail,
                busy,
                
//--------------control ports-----------------------------------------

                txdis,                     //SFP TX Disable
                int_mask,
                
                lm80,
                sfp_los_int_bit,
                sfp_abs_int_bit,
                
                jtag_sel,
                
                led_link,
                led_act,
                
                test_mode,
                debugging_led,
                
                dev_id,
                add,
                command,
                data_out,
                software_wp,
                byte_count,
                address_dis,
                iic_sel,
                
                reading_abs_int,
                reading_los_int,
                
                cpld_tck,                       //Emulated TCK
                cpld_tdi,                       //Emulated TDI
                cpld_tms                        //Emulated TMS                
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

input   [7:0]     sfp_only_pin;          //sfp ABS pin
input   [7:0]     sfp_los_pin;           //sfp LOS pin
input [7:0] sfp_inout_int;
input [7:0] fiber_inout_int;

input lm80;
input sfp_los_int_bit;
input sfp_abs_int_bit;

input [47:0] data_in;
input fail;
input busy;

input  tdo;
                
output  [7:0]   txdis;                 //sfp txdis pin

output [2:0] int_mask;

output jtag_sel;

output [7:0] led_link;
output [7:0] led_act;

output [7:0] test_mode;
output [7:0] debugging_led;

output [6:0] dev_id;
output [7:0] add;
output [1:0] command;
output [47:0] data_out;
output software_wp;
output [2:0] byte_count;
output address_dis;
output [7:0] iic_sel;

output reading_abs_int;
output reading_los_int;

output  cpld_tck;
output  cpld_tdi;
output  cpld_tms;

reg [7:0]       cplda_reg_rdata ;
reg [7:0]       cplda_reg_wdata;
reg             lbus_reg_we_n_delay1;                      
reg             lbus_reg_we_n_delay2;                      
reg reading_abs_int;
reg reading_los_int;
                 
                
reg     [7:0]       cpld_test;             //cpld test register, R/W internal
//reg   [3:0]       int_source;            //int source register, R internal, [2:0] LOS ABS LM80
reg     [2:0]       int_mask;              //int mask register, R/W control
reg     [7:0]       debugging_led;         //debugging led control register, R/W control
reg     [7:0]       test_mode;             //test mode selection register, R/W control
reg             cpld_tck;              //cpld tck register, W control
reg             cpld_tdi;              //cpld tdi register, W control
reg             cpld_tms;              //cpld tms register, W control
reg [7:0]       txdis;                 //sfp tx disable register, R/W control
reg [7:0]       led_link;              //link led register, R/W control
reg [7:0]       led_act;               //act led register, R/W control
reg             jtag_sel;              //JTAG loading mode selection register, R/W control
reg [7:0]       iic_sel;               //SFP IIC selection register, W control
                
reg [6:0]       dev_id;                //IIC Device ID, W control
reg [7:0]       add;                   //IIC Device Internal Address, W control
reg [1:0]       command;               //IIC Command, W control
reg [47:0]       data_out;              //IIC Data to Slave, W control
reg             software_wp;           //IIC Module Write Protection, W control
                 
reg [2:0]       byte_count;             //IIC two bytes operation flag
reg address_dis;

wire            lbus_reg_rd_n;
wire            lbus_reg_we_n;
wire            cplda_lbus_rdy_n;

wire lm80_int_bit;


parameter       LOGIC_VERSION                 = 8'h06;   //Logic Version Number
parameter       LOGIC_DATA_WIDTH              = 8'h00;   //Data Width
parameter       LOGIC_COMPILING_MONTH         = 8'hb1;   //Compiling Year and Month
parameter       LOGIC_COMPILING_DATE          = 8'h0d;   //Compiling Date
parameter       PCB_BOARD_VERSION             = 8'h01;   //Pcb Version Number
parameter       BOARD_MAN_VERSION             = 8'h01;   //Board Version Number
parameter       BOARD_CONFIG                  = 8'h00;   //Board Configration

/*---------------register addresses ---------------------------------*/
parameter       ADDR_DATA_WIDTH               = 10'b0000000000;      //0x00
parameter       ADDR_CPLD_TEST                = 10'b0000000001;      //0x01
parameter       ADDR_LOGIC_VERSION            = 10'b0000000010;      //0x02
parameter       ADDR_LOGIC_COMPILING_MONTH    = 10'b0000000011;      //0x03
parameter       ADDR_LOGIC_COMPILING_DATE     = 10'b0000000100;      //0x04
parameter       ADDR_PCB_BOARD_VERSION        = 10'b0000000101;      //0x05
parameter       ADDR_BOARD_MAN_VERSION        = 10'b0000000110;      //0x06
parameter       ADDR_BOARD_CONFIG             = 10'b0000000111;      //0x07
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
parameter       ADDR_IIC_BYTE_SEL             = 10'b0001001101;      //0x4D
parameter       ADDR_IIC_DATA_IN1            = 10'b0001001110;      //0x4E
parameter       ADDR_IIC_DATA_OUT1           = 10'b0001001111;      //0x4F
parameter       ADDR_SFP_ONLINE_STATUS        = 10'b0001010000;      //0x50
parameter       ADDR_SFP_LOS_STATUS           = 10'b0001010001;      //0x51
parameter       ADDR_SFP_ONLINE_INT           = 10'b0001010010;      //0x52
parameter       ADDR_SFP_LOS_INT              = 10'b0001010011;      //0x53
parameter       ADDR_IIC_ADDRESS_DISABLE      = 10'b0001010100;      //0x54
parameter       ADDR_IIC_DATA_IN2             = 10'b0001010101;      //0x55
parameter       ADDR_IIC_DATA_IN3             = 10'b0001010110;      //0x56
parameter       ADDR_IIC_DATA_IN4             = 10'b0001010111;      //0x57
parameter       ADDR_IIC_DATA_IN5             = 10'b0001011000;      //0x58
parameter       ADDR_IIC_DATA_OUT2            = 10'b0001011001;      //0x59
parameter       ADDR_IIC_DATA_OUT3            = 10'b0001011010;      //0x5a
parameter       ADDR_IIC_DATA_OUT4            = 10'b0001011011;      //0x5b
parameter       ADDR_IIC_DATA_OUT5            = 10'b0001011100;      //0x5c

assign  lbus_reg_rd_n = cplda_lbus_cs_n || cplda_lbus_rd_n;
assign  lbus_reg_we_n = cplda_lbus_cs_n || cplda_lbus_wr_n;
assign  cplda_lbus_rdy_n = (lbus_reg_rd_n && lbus_reg_we_n)?1'bz:0;
assign  cplda_lbus_int_n = ~((sfp_abs_int_bit|sfp_los_int_bit)|lm80_int_bit);
//assign  reading_abs_int = ((cplda_lbus_a==ADDR_SFP_ONLINE_INT)&&(lbus_reg_rd_n == 1'b0))?1'b1:1'b0;
//assign  reading_los_int = ((cplda_lbus_a==ADDR_SFP_LOS_INT)&&(lbus_reg_rd_n == 1'b0))?1'b1:1'b0;
assign  lm80_int_bit = ~(int_mask[2]|lm80);

/*********************************************************************
------------------------------Local bus Read   ----------------------
*********************************************************************/ 

assign  cplda_lbus_d = (lbus_reg_rd_n)?8'hzz:cplda_reg_rdata;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        begin
            cplda_reg_rdata <= 8'h00;
            reading_abs_int <= 1'b0;
            reading_los_int <= 1'b0;
        end
    else if(~lbus_reg_rd_n)
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
                 ADDR_TEST_MODE:
                      cplda_reg_rdata <= test_mode;
                 ADDR_INT_SOURCE:
                      cplda_reg_rdata <= {5'b00000,lm80_int_bit,sfp_los_int_bit,sfp_abs_int_bit};
                 ADDR_INT_MASK:
                      cplda_reg_rdata <= {5'b00000,int_mask};
                 ADDR_DEBUGGING_LED:
                      cplda_reg_rdata <= debugging_led;
                 ADDR_CPLD_TDO:
                      cplda_reg_rdata <= {7'b0000000,tdo};
                 ADDR_TXDIS:
                      cplda_reg_rdata <= txdis;
                 ADDR_LED_LINK:
                      cplda_reg_rdata <= led_link;
                 ADDR_LED_ACT:
                      cplda_reg_rdata <= led_act;
                 ADDR_JTAG_SEL:
                      cplda_reg_rdata <= {7'b0000000,jtag_sel};
                 ADDR_IIC_DATA_IN:                                                                
                      cplda_reg_rdata <= data_in[7:0];
                 ADDR_IIC_DATA_IN1:
                      cplda_reg_rdata <= data_in[15:8];
              ADDR_IIC_DATA_IN2:
                      cplda_reg_rdata <= data_in[23:16];
              ADDR_IIC_DATA_IN3:
                      cplda_reg_rdata <= data_in[31:24];
              ADDR_IIC_DATA_IN4:
                      cplda_reg_rdata <= data_in[39:32];
              ADDR_IIC_DATA_IN5:
                      cplda_reg_rdata <= data_in[47:40];
                 ADDR_IIC_FAIL:                                                                
                      cplda_reg_rdata <= {7'b0000000,fail};
                 ADDR_IIC_BUSY:                                                                
                      cplda_reg_rdata <= {7'b0000000,busy};
                 ADDR_SFP_ONLINE_STATUS: 
                      cplda_reg_rdata <= sfp_only_pin;
                 ADDR_SFP_LOS_STATUS: 
                      cplda_reg_rdata <= sfp_los_pin;
                 ADDR_SFP_ONLINE_INT: 
                 begin
                      cplda_reg_rdata <= ~sfp_inout_int;
                      reading_abs_int <= 1'b1;
                 end
                 ADDR_SFP_LOS_INT: 
                 begin
                      cplda_reg_rdata <= ~fiber_inout_int;
                      reading_los_int <= 1'b1;
                 end
                 default:
                 begin
                      cplda_reg_rdata <= 8'h00;
                      reading_abs_int <= 1'b0;
                      reading_los_int <= 1'b0;
                 end
            endcase
        end
        else
        begin
                reading_abs_int <= 1'b0;
                reading_los_int <= 1'b0;
        end
end
                
/*********************************************************************
------------------------------Local bus Write   ----------------------
*********************************************************************/ 
                
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)  
        begin   
            cplda_reg_wdata <= 8'h00;
        end     
    else        
        begin
            cplda_reg_wdata <= cplda_lbus_d;
        end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        begin
            lbus_reg_we_n_delay1     <= 1'b1;
            lbus_reg_we_n_delay2     <= 1'b1;
        end
    else
        begin
            lbus_reg_we_n_delay1     <= lbus_reg_we_n;
            lbus_reg_we_n_delay2     <= lbus_reg_we_n_delay1;
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
                int_mask <= 3'b000;
                led_link <= 8'hff;
                led_act <= 8'hff;
                txdis <= 8'hff;
                jtag_sel <= 1'b0;
                iic_sel <= 8'h00;
                dev_id <= 7'b0000000;
                add <= 8'h00;
                command <= 2'b00;
                data_out <= 48'h000000000000;
                software_wp <= 1'b0;
                byte_count <= 3'b000;
                address_dis <= 1'b0;
        end
    else if((lbus_reg_we_n_delay1==1'b1)&&(lbus_reg_we_n_delay2==1'b0))
        begin
            case(cplda_lbus_a[9:0])
                ADDR_CPLD_TEST: 
                        cpld_test <= ~cplda_reg_wdata;
                ADDR_TEST_MODE:                                                                
                        test_mode <= cplda_reg_wdata;
                ADDR_INT_MASK:
                        int_mask <= cplda_reg_wdata[2:0];
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
                        data_out[7:0] <= cplda_reg_wdata;
                                  ADDR_IIC_DATA_OUT1:
                        data_out[15:8] <= cplda_reg_wdata;
                ADDR_IIC_DATA_OUT2:
                        data_out[23:16] <= cplda_reg_wdata;
                ADDR_IIC_DATA_OUT3:
                        data_out[31:24] <= cplda_reg_wdata;
                ADDR_IIC_DATA_OUT4:
                        data_out[39:32] <= cplda_reg_wdata;
                ADDR_IIC_DATA_OUT5:
                        data_out[47:40] <= cplda_reg_wdata;
                ADDR_IIC_WP:                                                                
                        software_wp <= cplda_reg_wdata[0];
                ADDR_IIC_BYTE_SEL:
                        byte_count <= cplda_reg_wdata[2:0];
                ADDR_IIC_ADDRESS_DISABLE:
                        address_dis <= cplda_reg_wdata[0];
                default:
                        ;                        
            endcase
        end 
    else
       ;
end                                      
endmodule

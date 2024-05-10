/* GUILLEM PRENAFETA (UB 2023-2024)

IMPLEMENTATION OF MICRO-RISCV-CPU

CPU core and MDU obtanied from::
RISCV CPU ==> SERIAL RISCV
MDU https://github.com/zeeshanrafique23/mdu
*/

`default_nettype none

module TOP
    #(//Paranetres memoria
        parameter data_depth = 64, //for Data memory
        parameter ins_depth = 512)  //for Instruction memory
        //parameter memfile = "machine.hex")

    (
        input wire i_clk,
        input wire globalRSTN,

        input wire PROG,

        inout wire [7:0] GPIO_out,

        input wire i_CSn,
        input wire i_MOSI,
        input wire i_SCLK,
        output wire o_MISO

		  //output ibus_cyc
    );


//------------ MODULE DIRECTIONS ------------------------------//
    parameter ins_ADDR     = 4'h0;
    parameter data_ADDR    = 4'h1;
    parameter SPI_ADDR     = 4'h2;
    parameter gpio_ADDR    = 4'h3;
    parameter int_ADDR     = 4'h4;

//------------ INSTRUCTION MEM --------------------------------//
   wire [31:0]  ibus_adr;
   wire [31:0]  ibus_dat;
   wire         ibus_we;
   wire         ibus_cyc;
   wire [31:0]  ibus_rdt;
   wire         ibus_ack;

//------------ DATA MEM ---------------------------------------//
   wire [31:0]  dbus_adr;
   wire [31:0]  dbus_dat;
   wire [3:0]   dbus_sel;
   wire         dbus_we;
   wire         dbus_cyc;
   wire [31:0]  dbus_rdt;
   wire         dbus_ack;

   wire [3:0] mem_MOD = dbus_adr[32-1:28];


//------------ DMEM BUS ---------------------------------------//

wire [31:0]    dbusMEM_rdt;
wire           dbusMEM_ack;

//------------ SPI BUS ----------------------------------------//

wire [15:0]    dbusSPI_rdt;
wire           dbusSPI_ack;
wire           SPI_irq;

//------------ GPIO BUS ---------------------------------------//

wire [7:0]     dbusGPIO_rdt;
wire           dbusGPIO_ack;
wire           GPIO_irq;

//------------ INT BUS ----------------------------------------//

wire [8-1:0]   dbusINT_rdt;
wire           dbusINT_ack;
wire           irq;

//------------ BOOT BUS ---------------------------------------//

wire           bootRST;
wire [32-1:0]  bootIMEMadr;
wire           bootIMEMcyc;
wire           bootSPIaddr;
wire           bootSPIcyc;
wire           bootSPIwe;
wire [8-1:0]   bootSPIWd;
wire           bootEN;

// DATA BUS

assign dbus_rdt = (mem_MOD==data_ADDR) ? dbusMEM_rdt : (mem_MOD==SPI_ADDR) ? {16'd0, dbusSPI_rdt} : (mem_MOD==gpio_ADDR) ? {24'd0, dbusGPIO_rdt} : (mem_MOD==int_ADDR) ? {24'd0, dbusINT_rdt} : 32'd0;
assign dbus_ack = (mem_MOD==data_ADDR) ? dbusMEM_ack : (mem_MOD==SPI_ADDR) ? dbusSPI_ack : (mem_MOD==gpio_ADDR) ? dbusGPIO_ack : (mem_MOD==int_ADDR) ? dbusINT_ack : 32'd0;

//------------ MDU BUS ---------------------------------------//

wire [32-1:0] mdu_rs1;
wire [32-1:0] mdu_rs2;
wire [2:0]    mdu_op;
wire          mdu_valid;
wire          mdu_ready;
wire [32-1:0] mdu_rd;

//------------ RESET -----------------------------------------//

wire rst;
reg [1:0] rstREG;
   assign rst=(~globalRSTN)|(bootRST); //li sumem el rst que genera el boot module
   assign bootEN = (~rstREG[1]) & (rstREG[0]); //abans teniem 0 i ara un 1

   /* To first program the PROG::
      MAKING a full reset, rstn==0, put PROG to 1, and then rst > 1, you're in programming mode
      Normal use, always PROG to gnd and then make rstn 1>0>1
   */
   
   always@(posedge i_clk) begin
      if(PROG) begin
         rstREG[0]<=globalRSTN;
      end else begin
         rstREG[0]<=1'b1; //sempre abans hem de tenir un 0 per tant anula
      end
      rstREG[1]<=rstREG[0];
   end

//------------ BOOT MODULE ----------------------------------//

      BOOT boot(

         .clk           (i_clk),
         .rst           (~globalRSTN),
         .bootEN        (bootEN),
         .bootRST       (bootRST),     //justament genera uns rst per l'altre logica que es desactivara quan hagi acabat

         .i_IMEM_ack    (ibus_ack),
         .o_IMEM_cyc    (bootIMEMcyc),
         .o_IMEM_we     (ibus_we),
         .i_IMEM_dat    (ibus_rdt),
         .RxWord        (ibus_dat),
         .o_IMEM_adr    (bootIMEMadr),

         .i_wb_ack      (dbusSPI_ack),
         .i_data2R      (dbusSPI_rdt[8-1:0]),
         .o_wb_cyc      (bootSPIcyc),
         .o_wb_we       (bootSPIwe),
         .o_data2W      (bootSPIWd),
         .addr          (bootSPIaddr),
         .int           (SPI_irq)


         //ouput for the programer


         //program of IMEM

         );

/////////------ CPU ------////////////////////////////////////////
/////////////////////////////////////////////////////////////////

   serv_rf_top
   #(.RESET_PC (32'd0),
    .MDU (1))
   CPU(
    .clk            (i_clk),
    .i_rst          (rst),
    .i_timer_irq     (irq),

    .o_ibus_adr     (ibus_adr),
    .o_ibus_cyc     (ibus_cyc),
    .i_ibus_rdt     (ibus_rdt),
    .i_ibus_ack     (ibus_ack),

    .o_dbus_adr     (dbus_adr),
    .o_dbus_dat     (dbus_dat),
    .o_dbus_sel     (dbus_sel),
    .o_dbus_we      (dbus_we),
    .o_dbus_cyc     (dbus_cyc),
    .i_dbus_rdt     (dbus_rdt),
    .i_dbus_ack     (dbus_ack),

    //extension & MDU
    .o_ext_rs1      (mdu_rs1),
    .o_ext_rs2      (mdu_rs2),
    .o_ext_funct3   (mdu_op),
    .i_ext_rd       (mdu_rd),
    .i_ext_ready    (mdu_ready),
    .o_mdu_valid    (mdu_valid)
    );

/////////------ MDU MODULE ------/////////////////////////////////
/////////////////////////////////////////////////////////////////

   MDU
   modul_MDU(
    .i_clk          (i_clk),
    .i_rst          (rst),
    .i_mdu_rs1      (mdu_rs1),
    .i_mdu_rs2      (mdu_rs2),
    .i_mdu_op       (mdu_op),
    .i_mdu_valid    (mdu_valid),
    .o_mdu_ready    (mdu_ready),
    .o_mdu_rd       (mdu_rd)
    );

/////////------ INSTRUCTION MEM ------////////////////////////////
/////////////////////////////////////////////////////////////////

wire [32-1:0] IMEM_adr = (bootRST) ? bootIMEMadr : ibus_adr; //pel modul boot
wire IMEM_cyc = bootRST ? bootIMEMcyc : ibus_cyc;

   IMEM
   #(.depth (ins_depth)
    )
   IMEM(
    .i_clk          (i_clk),

    .i_wb_adr     (IMEM_adr),
    .i_wb_dat     (ibus_dat),
    .i_wb_we      (ibus_we),
    .i_wb_cyc     (IMEM_cyc),
    .o_wb_rdt     (ibus_rdt),
    .o_wb_ack     (ibus_ack)


    );

/////////------ DATA MEM ------///////////////////////////////////
/////////////////////////////////////////////////////////////////

   DMEM
   #(.depth (data_depth)
    )
   DMEM(
    .i_clk          (i_clk),

    .i_wb_adr     (dbus_adr),
    .i_wb_dat     (dbus_dat),
    .i_wb_sel     (dbus_sel),
    .i_wb_we      (dbus_we&&(mem_MOD==data_ADDR)),
    .i_wb_cyc     (dbus_cyc&&(mem_MOD==data_ADDR)),
    .o_wb_rdt     (dbusMEM_rdt),
    .o_wb_ack     (dbusMEM_ack)
    );

/////////------ MODUL SPI ------//////////////////////////////////
/////////////////////////////////////////////////////////////////

   wire SPI_cyc;
   assign SPI_cyc = bootRST ? (bootSPIcyc) : (dbus_cyc&&(mem_MOD==SPI_ADDR));
   wire SPI_we;
   assign SPI_we = bootRST ? (bootSPIwe) : (dbus_we&&(mem_MOD==SPI_ADDR));
   wire [16-1:0] SPI_d2W;
   assign SPI_d2W = bootRST ? ({8'd0, bootSPIWd}) : (dbus_dat[16-1:0]);
   wire SPI_addr;
   assign SPI_addr = bootRST ? (1'b0) : (dbus_adr[2]);

   SPI_MODULE spi(
    .rstn           (globalRSTN), //unic modul que no esta en rst quan es fa la PROG
    .clk            (i_clk),

    .i_dbus_adr  (SPI_addr),
    .i_dbus_cyc  (SPI_cyc),
    .i_dbus_we    (SPI_we),
    .i_dbus_dat   (SPI_d2W),
    .o_dbus_rdt   (dbusSPI_rdt),
    .o_dbus_ack   (dbusSPI_ack),

    .intSPI       (SPI_irq),

    .i_SCLK       (i_SCLK),
    .o_MISO       (o_MISO),
    .i_MOSI       (i_MOSI),
    .i_CSn        (i_CSn)
    );

/////////------ MODUL GPIOs ------////////////////////////////////
/////////////////////////////////////////////////////////////////

   GPIO_MOD GPIOs(
    .rstn                (~rst),
    .clk                (i_clk),

    .GPIO_out     (GPIO_out),

    .addr     (dbus_adr[3:2]), //el 0 i 1 no
    .i_wb_dat     (dbus_dat[7:0]),
    //.i_wb_sel     (dbus_sel),
    .i_wb_we      (dbus_we&&(mem_MOD==gpio_ADDR)),
    .i_wb_cyc     (dbus_cyc&&(mem_MOD==gpio_ADDR)),
    .o_wb_rdt     (dbusGPIO_rdt),
    .o_wb_ack     (dbusGPIO_ack),
    .int          (GPIO_irq)
    );

/////////------ INTERRUPTS ------/////////////////////////////////
/////////////////////////////////////////////////////////////////

wire timer_int;
assign timer_int = 1'b0;

 interrupt int_module(

    .rstn         (~rst),
    .clk          (i_clk),

    //interrupt inputs (Privileged (1))
    .int1         (SPI_irq),
    .int2         (GPIO_irq),
    .int3         (timer_int),
    .int4         (1'b0),
    .int5         (1'b0),
    .int6         (1'b0),
    .int7         (1'b0),
    .int8         (1'b0),

    .int          (irq),
    .ins_ack      (ibus_ack), //per saber quan processador es llança a la rutina (per baixar flag irq) (irq ha de durar 1 cicle d'instruccio)

   
    .addr         (dbus_adr[2]),
    .i_wb_cyc     (dbus_cyc&&(mem_MOD==int_ADDR)),
    .o_wb_rdt     (dbusINT_rdt),
    .o_wb_ack     (dbusINT_ack),
    .i_wb_data    (dbus_dat[8-1:0]),
    .i_wb_we      (dbus_we&&(mem_MOD==int_ADDR))      

    );



endmodule

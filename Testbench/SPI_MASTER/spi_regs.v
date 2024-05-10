/********1*********2*********3*********4*********5*********6*********7*********8
* File : spi_regs.v
*_______________________________________________________________________________
*
* Revision history
*
* Name          Date        Observations
* ------------------------------------------------------------------------------
* -            01/02/2022   First version.
* ------------------------------------------------------------------------------
*_______________________________________________________________________________
* Description
* Configuration and Status Registers for SPI Bus.
*
* ============================================================================== 
*  SPI_CTRL:   Serial Peripheral Interface Control Register           
*              (Write/Read) Default: 0x00
* ------------------------------------------------------------------------------
*    bit[7]  : BUSY ? SPI Bus Busy Flag (Read only)
*                 1 = Transmission not complete.
*                 0 = Transmission completed.
*    bit[5:1]: Reserved bits.
*    bit[0]  : ENABLE ? Serial Peripheral Master Enable
*                0 = SPI master off
*                1 = SPI master on
* 
* ============================================================================== 
*  SPI_BUFFER: Serial Peripheral Interface Transmited/Received Data Register 
*              (Write/Read) Default: 0x00
*
* ============================================================================== 
*  SPI_CONFIG: Serial Preipheral Interface SCK Configuration Register
*              (Write/Read) Default: 0x00
* ------------------------------------------------------------------------------
*    bit[7:0]: Reserved bits.
*    bit[5]  : CPOL ? Clock Polarity
*                0 = the base value of the clock is zero
*                1 = the base value of the clock is one
*    bit[4]  : CPHA ? Clock Phase
*                At CPOL=0 the base value of the clock is zero:
*                  - For CPHA=0: data are captured on the clock's rising 
*                    edge (low2high transition) and data are propagated on a 
*                    falling edge.
*                  - For CPHA=1: data are captured on the clock's falling edge
*                    and data are propagated on a rising edge.
*                At CPOL=1 the base value of the clock is one (inversion of CPOL=0)
*                  - For CPHA=0: data are captured on clock's falling edge and 
*                    data are propagated on a rising edge.
*                  - For CPHA=1: data are captured on clock's rising edge and 
*                    data are propagated on a falling edge.
*    bit[3:0]: CPre ? Prescaled Value used to determine the bus baud rate. The
*              SCK clock obtained is given by: SCK = Clk/[2*(CPre+1)] where Clk is 
*              the system clock.
*
* ==============================================================================
*  SPI_SSELEC: Serial Peripheral Interface Slave Selector Register       
*              (Write/Read) Default: 0xFF
* ------------------------------------------------------------------------------
*    Each bit is used to select one slave.  
*_______________________________________________________________________________ 
*
* (c) Copyright Universitat de Barcelona, 2022
*
*********1*********2*********3*********4*********5*********6*********7*********/
`include "spi_defines.vh"

module spi_regs #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 2
)(
  input  Clk,                      // system clock
  input  Rst_n,                    // system reset asynch, active low
  input  [ADDR_WIDTH-1:0] Addr,    // registers addres
  input  Wr,                       // registers write enable
  input  [DATA_WIDTH-1:0] DataWr,  // registers data input
  output reg [DATA_WIDTH-1:0] DataRd,  // registers data output

  output CPol,                     // Used to select the SCK polarization
  output CPha,                     // Used to select the SCK phase
  output [4-1:0] CPre,             // SCK clock prescale, number of clk ticks to defin one SCK semi period
  output reg StartTx,              // Initiates the transmission.
  input  EndTx,                    // Indicates the end of transission
  output [DATA_WIDTH-1:0] TxData,
  input  [DATA_WIDTH-1:0] RxData,
  output [DATA_WIDTH-1:0] SlaveSelectors
);

  // spi registers
  reg [8-1:0] ctrl;       // SPI_CTRL register with busy flag and enable bits
  reg [DATA_WIDTH-1:0] buffer;     // SPI_BUFFER register
  reg [8-1:0] sckConfig;  // SPI SCK Configuration registers CPOL CPHA CPRE
  reg [8-1:0] sselect;    // SPI Slave Selector register

  // other registers
  reg busy;          // flag to indicate there is a transmission in course
  wire enable;       // used to mask de start signal enabling or disabling the spi master

  // output assignaments
  assign enable = ctrl[0];

  assign CPol = sckConfig[5];
  assign CPha = sckConfig[4];
  assign CPre = sckConfig[3:0];

  assign SlaveSelectors = sselect;

  assign TxData = buffer;

  // write synch
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      ctrl <= 8'h00;
    else if(Wr==1'b1 && Addr==`SPI_CTRL)
      ctrl <= DataWr[7:0];
    else
      ctrl <= ctrl;

  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      sckConfig <= 8'h00;
    else if(Wr==1'b1 && Addr==`SPI_CONFIG)
      sckConfig <= DataWr[7:0];
    else
      sckConfig <= sckConfig;

  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      sselect <= 8'hFF;
    else if(Wr==1'b1 && Addr==`SPI_SSELEC)
      sselect <= DataWr[7:0];
    else if(EndTx)
      sselect <=8'hFF;
    else
      sselect <= sselect;

  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      buffer <= {DATA_WIDTH{1'b0}};
    else if(EndTx)
      buffer <= RxData;
    else if(Wr==1'b1 && Addr==`SPI_BUFFER)
      buffer <= DataWr;
    else
      buffer <= buffer;

  // logic to generate Start and loadTx signals
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      StartTx <= 1'b0;
    else if(Wr==1'b1 && Addr==`SPI_BUFFER)
      StartTx <= enable;
    else
      StartTx <= 1'b0;

  // logic to generate the busy flag
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      busy <= 1'b0;
    else if(StartTx)
      busy <= 1'b1;
    else if(EndTx)
      busy <= 1'b0;
    else
      busy <= busy;

  // asynch read
  always @(*)
    case(Addr)
      `SPI_CTRL   : DataRd = {{DATA_WIDTH-8{1'b0}}, busy, ctrl[8-2:0]};
      `SPI_BUFFER : DataRd = buffer;
      `SPI_CONFIG : DataRd = {{DATA_WIDTH-8{1'b0}},sckConfig};
      `SPI_SSELEC : DataRd = {{DATA_WIDTH-8{1'b0}},sselect};
      default : DataRd = {DATA_WIDTH{1'b0}};
    endcase

endmodule


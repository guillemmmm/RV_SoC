/********1*********2*********3*********4*********5*********6*********7*********8
* File : spi_top.v
*_______________________________________________________________________________
*
* Revision history
*
* Name          Date        Observations
* ------------------------------------------------------------------------------
* -            01/02/2022   First version.
* ------------------------------------------------------------------------------
*_______________________________________________________________________________
*
* Description
* Top Module of the SPI Master
*_______________________________________________________________________________

* (c) Copyright Universitat de Barcelona, 2022
*
*********1*********2*********3*********4*********5*********6*********7*********/

module spi_top (
  input  Clk,             // system cloc
  input  Rst_n,           // system reset asynch, active low
  input  [2-1:0] Addr,    // registers addres
  input  Wr,              // registers write enable
  input  [8-1:0] DataWr,  // registers data input
  output [8-1:0] DataRd,  // registers data output
  output Sck,
  output Mosi,
  input  Miso,
  output Ss0,
  output Ss1,
  output Ss2,
  output Ss3,
  output Ss4,
  output Ss5,
  output Ss6,
  output Ss7
);

  localparam DATA_WIDTH = 8;
  localparam CPRE_WIDTH = 4;

  wire cPol, cPha;
  wire [CPRE_WIDTH-1:0] cPre;
  wire startTx, endTx, loadTx;
  wire [DATA_WIDTH-1:0] txData, rxData;
  wire pulseEn, pulse;
  wire shiftTx, shiftRx;

  spi_regs #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(2)) i_REGS(
    .Clk                (Clk),
    .Rst_n              (Rst_n),
    .Addr               (Addr),
    .Wr                 (Wr),
    .DataWr             (DataWr),
    .DataRd             (DataRd),
    .CPol               (cPol),
    .CPha               (cPha),
    .CPre               (cPre),
    .StartTx            (startTx),
    .EndTx              (endTx),
    .TxData             (txData),
    .RxData             (rxData),
    .SlaveSelectors     ({Ss7,Ss6,Ss5,Ss4,Ss3,Ss2,Ss1,Ss0})
  );

  pulse_generator #(.SIZE(CPRE_WIDTH)) i_PULSE(
    .Clk                (Clk),
    .Rst_n              (Rst_n & pulseEn),
    .Ticks              (cPre),
    .Pulse              (pulse)
  );

  shiftreg #(.SIZE(DATA_WIDTH)) i_TXREG(
    .Clk                (Clk),
    .Rst_n              (Rst_n),
    .En                 (shiftTx),
    .Load               (loadTx),
    .SerIn              (1'b0),
    .DataIn             (txData),
    .SerOut             (Mosi),
    .DataOut            ()
  );

  shiftreg #(.SIZE(DATA_WIDTH)) i_RXREG(
    .Clk                (Clk),
    .Rst_n              (Rst_n),
    .En                 (shiftRx),
    .Load               (1'b0),
    .SerIn              (Miso),
    .DataIn             ({DATA_WIDTH{1'b0}}),
    .SerOut             (),
    .DataOut            (rxData)
  );

  spi_cu i_CU(
    .Clk                (Clk),
    .Rst_n              (Rst_n),
    .StartTx            (startTx),
    .Pulse              (pulse),
    .CPol               (cPol),
    .CPha               (cPha),
    .PulseEn            (pulseEn),
    .LoadTx             (loadTx),
    .ShiftTx            (shiftTx),
    .ShiftRx            (shiftRx),
    .EndTx              (endTx),
    .Sck                (Sck)
  );

endmodule

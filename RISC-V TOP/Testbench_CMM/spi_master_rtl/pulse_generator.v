/********1*********2*********3*********4*********5*********6*********7*********8
* File : pulse_generator.v
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
* Cyclic pulse generator. 
* It generates a pulse lasting one clock cycle every N clock cycle.
*
* For Ticks = 2:
*                      _________________________________________
*    Rs_n    _________/                                         \__________
*              _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   
*    Clk     _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_|
*            ______________ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ _______
*    counter ___________0__X_1_X_2_X_0_X_1_X_2_X_0_X_1_X_2_X_0_X_1_X__0____     
*                               ___         ___         ___
*    Pulse   __________________/   \_______/   \_______/   \_______________
* 
*_______________________________________________________________________________

* (c) Copyright Universitat de Barcelona, 2022
*
*********1*********2*********3*********4*********5*********6*********7*********/
module pulse_generator #(parameter SIZE = 8)(
  input Clk,
  input Rst_n,
  input [SIZE-1:0] Ticks,
  output reg Pulse
);

  reg [SIZE-1:0] counter;

  // counts the ticks
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      counter <= {SIZE{1'b0}};
    else
      counter <= (counter < Ticks) ? counter + 1'b1 : {SIZE{1'b0}};

  // generats the pulse
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n)
      Pulse <= 1'b0;
    else
      Pulse <= (counter == Ticks-1'b1) ? 1'b1: ~|Ticks;

endmodule

// module pulse_generator #(parameter SIZE = 8)(
//   input Clk,
//   input Rst_n,
//   input [SIZE-1:0] Ticks,
//   output reg Pulse
// );
//
//   reg [SIZE:0] counter;
//
//   // counts the ticks
//   always @(posedge Clk or negedge Rst_n)
//     if(!Rst_n)
//       counter <= Ticks-1'b1;
//     else
//       counter <= counter[SIZE] ? Ticks-1'b1 : counter-1'b1;
//
//   // generats the pulse
//   always @(posedge Clk or negedge Rst_n)
//     if(!Rst_n)
//       Pulse <= 1'b0;
//     else
//       Pulse <= ~|counter | ~|Ticks;
//
// endmodule

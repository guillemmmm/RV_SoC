/********1*********2*********3*********4*********5*********6*********7*********8
* File : spi_cu.v
*_______________________________________________________________________________
*
* Revision history
*
* Name          Date        Observations
* ------------------------------------------------------------------------------
* -            01/02/2022   First version.
* -            01/02/2022   Alignment of SCK and MOSI for CPHA during LoadTx.
*                           + end state added.
* ------------------------------------------------------------------------------
*_______________________________________________________________________________
*
* Description
* SPI master control unit. It is incharge to generate SCK and control the timing
* of the SPI transmission.
* 
*_______________________________________________________________________________

* (c) Copyright Universitat de Barcelona, 2022
*
*********1*********2*********3*********4*********5*********6*********7*********/
module spi_cu (
  input Clk,
  input Rst_n,
  input StartTx,
  input Pulse,
  input CPol,
  input CPha,
  output reg PulseEn,
  output reg LoadTx,
  output reg ShiftTx,
  output reg ShiftRx,
  output reg EndTx,
  output reg Sck
);

  localparam IDLE    = 6'd0,    // define states of the FSM
             RX_BIT31 = 6'd1,
             TX_BIT30 = 6'd2,
             RX_BIT30 = 6'd3,
             TX_BIT29 = 6'd4,
             RX_BIT29 = 6'd5,
             TX_BIT28 = 6'd6,
             RX_BIT28 = 6'd7,
             TX_BIT27 = 6'd8,
             RX_BIT27 = 6'd9,
             TX_BIT26 = 6'd10,
             RX_BIT26 = 6'd11,
             TX_BIT25 = 6'd12,
             RX_BIT25 = 6'd13,
             TX_BIT24 = 6'd14,
             RX_BIT24 = 6'd15,
             TX_BIT23 = 6'd16,
             RX_BIT23 = 6'd17,
             TX_BIT22 = 6'd18,
             RX_BIT22 = 6'd19,
             TX_BIT21 = 6'd20,
             RX_BIT21 = 6'd21,
             TX_BIT20 = 6'd22,
             RX_BIT20 = 6'd23,
             TX_BIT19 = 6'd24,
             RX_BIT19 = 6'd25,
             TX_BIT18 = 6'd26,
             RX_BIT18 = 6'd27,
             TX_BIT17 = 6'd28,
             RX_BIT17 = 6'd29,
             TX_BIT16 = 6'd30,
             RX_BIT16 = 6'd31,
             TX_BIT15 = 6'd32,
             RX_BIT15 = 6'd33,
             TX_BIT14 = 6'd34,
             RX_BIT14 = 6'd35,
             TX_BIT13 = 6'd36,
             RX_BIT13 = 6'd37,
             TX_BIT12 = 6'd38,
             RX_BIT12 = 6'd39,
             TX_BIT11 = 6'd40,
             RX_BIT11 = 6'd41,
             TX_BIT10 = 6'd42,
             RX_BIT10 = 6'd43,
             TX_BIT9 = 6'd44,
             RX_BIT9 = 6'd45,
             TX_BIT8 = 6'd46,
             RX_BIT8 = 6'd47,
             TX_BIT7 = 6'd48,
             RX_BIT7 = 6'd49,
             TX_BIT6 = 6'd50,
             RX_BIT6 = 6'd51,
             TX_BIT5 = 6'd52,
             RX_BIT5 = 6'd53,
             TX_BIT4 = 6'd54,
             RX_BIT4 = 6'd55,
             TX_BIT3 = 6'd56,
             RX_BIT3 = 6'd57,
             TX_BIT2 = 6'd58,
             RX_BIT2 = 6'd59,
             TX_BIT1 = 6'd60,
             RX_BIT1 = 6'd61,
             TX_BIT0 = 6'd62,
             RX_BIT0 = 6'd63,
             END     = 7'd64;

  reg [7-1:0] state, next; // FSM current state and next state var

  reg spiSck;    

  // state register
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n) state <= IDLE;
    else       state <= next;

  // combinational logic to calculate next state
  always @(state or StartTx or Pulse)
    case(state)
      IDLE    : if(StartTx) next = RX_BIT31;
                else        next = IDLE;
      RX_BIT31 : if(Pulse)   next = TX_BIT30;
                else        next = RX_BIT31;
      TX_BIT30 : if(Pulse)   next = RX_BIT30;
                else        next = TX_BIT30;
      RX_BIT30 : if(Pulse)   next = TX_BIT29;
                else        next = RX_BIT30;
      TX_BIT29 : if(Pulse)   next = RX_BIT29;
                else        next = TX_BIT29;
      RX_BIT29 : if(Pulse)   next = TX_BIT28;
                else        next = RX_BIT29;
      TX_BIT28 : if(Pulse)   next = RX_BIT28;
                else        next = TX_BIT28;
      RX_BIT28 : if(Pulse)   next = TX_BIT27;
                else        next = RX_BIT28;
      TX_BIT27 : if(Pulse)   next = RX_BIT27;
                else        next = TX_BIT27;
      RX_BIT27 : if(Pulse)   next = TX_BIT26;
                else        next = RX_BIT27;
      TX_BIT26 : if(Pulse)   next = RX_BIT26;
                else        next = TX_BIT26;
      RX_BIT26 : if(Pulse)   next = TX_BIT25;
                else        next = RX_BIT26;
      TX_BIT25 : if(Pulse)   next = RX_BIT25;
                else        next = TX_BIT25;
      RX_BIT25 : if(Pulse)   next = TX_BIT24;
                else        next = RX_BIT25;                
      TX_BIT24 : if(Pulse)   next = RX_BIT24;
                else        next = TX_BIT24;
      RX_BIT24 : if(Pulse)   next = TX_BIT23;
                else        next = RX_BIT24;
      TX_BIT23 : if(Pulse)   next = RX_BIT23;
                else        next = TX_BIT23;
      RX_BIT23 : if(Pulse)   next = TX_BIT22;
                else        next = RX_BIT23;
      TX_BIT22 : if(Pulse)   next = RX_BIT22;
                else        next = TX_BIT22;
      RX_BIT22 : if(Pulse)   next = TX_BIT21;
                else        next = RX_BIT22;
      TX_BIT21 : if(Pulse)   next = RX_BIT21;
                else        next = TX_BIT21;
      RX_BIT21 : if(Pulse)   next = TX_BIT20;
                else        next = RX_BIT21;                
      TX_BIT20 : if(Pulse)   next = RX_BIT20;
                else        next = TX_BIT20;
      RX_BIT20 : if(Pulse)   next = TX_BIT19;
                else        next = RX_BIT20;
      TX_BIT19 : if(Pulse)   next = RX_BIT19;
                else        next = TX_BIT19;
      RX_BIT19 : if(Pulse)   next = TX_BIT18;
                else        next = RX_BIT19;
      TX_BIT18 : if(Pulse)   next = RX_BIT18;
                else        next = TX_BIT18;
      RX_BIT18 : if(Pulse)   next = TX_BIT17;
                else        next = RX_BIT18;
      TX_BIT17 : if(Pulse)   next = RX_BIT17;
                else        next = TX_BIT17;
      RX_BIT17 : if(Pulse)   next = TX_BIT16;
                else        next = RX_BIT17;
      TX_BIT16 : if(Pulse)   next = RX_BIT16;
                else        next = TX_BIT16;
      RX_BIT16 : if(Pulse)   next = TX_BIT15;
                else        next = RX_BIT16;
      TX_BIT15 : if(Pulse)   next = RX_BIT15;
                else        next = TX_BIT15;
      RX_BIT15 : if(Pulse)   next = TX_BIT14;
                else        next = RX_BIT15;                
      TX_BIT14 : if(Pulse)   next = RX_BIT14;
                else        next = TX_BIT14;
      RX_BIT14 : if(Pulse)   next = TX_BIT13;
                else        next = RX_BIT14; 
      TX_BIT13 : if(Pulse)   next = RX_BIT13;
                else        next = TX_BIT13;
      RX_BIT13 : if(Pulse)   next = TX_BIT12;
                else        next = RX_BIT13; 
      TX_BIT12 : if(Pulse)   next = RX_BIT12;
                else        next = TX_BIT12;
      RX_BIT12 : if(Pulse)   next = TX_BIT11;
                else        next = RX_BIT12;
      TX_BIT11 : if(Pulse)   next = RX_BIT11;
                else        next = TX_BIT11;
      RX_BIT11 : if(Pulse)   next = TX_BIT10;
                else        next = RX_BIT11;
      TX_BIT10 : if(Pulse)   next = RX_BIT10;
                else        next = TX_BIT10;
      RX_BIT10 : if(Pulse)   next = TX_BIT9;
                else        next = RX_BIT10;                
      TX_BIT9 : if(Pulse)   next = RX_BIT9;
                else        next = TX_BIT9;
      RX_BIT9 : if(Pulse)   next = TX_BIT8;
                else        next = RX_BIT9;
      TX_BIT8 : if(Pulse)   next = RX_BIT8;
                else        next = TX_BIT8;
      RX_BIT8 : if(Pulse)   next = TX_BIT7;
                else        next = RX_BIT8;                  
      TX_BIT7 : if(Pulse)   next = RX_BIT7;
                else        next = TX_BIT7;
      RX_BIT7 : if(Pulse)   next = TX_BIT6;
                else        next = RX_BIT7;    
      TX_BIT6 : if(Pulse)   next = RX_BIT6;
                else        next = TX_BIT6;
      RX_BIT6 : if(Pulse)   next = TX_BIT5;
                else        next = RX_BIT6; 
      TX_BIT5 : if(Pulse)   next = RX_BIT5;
                else        next = TX_BIT5;
      RX_BIT5 : if(Pulse)   next = TX_BIT4;
                else        next = RX_BIT5;
      TX_BIT4 : if(Pulse)   next = RX_BIT4;
                else        next = TX_BIT4;
      RX_BIT4 : if(Pulse)   next = TX_BIT3;
                else        next = RX_BIT4;
      TX_BIT3 : if(Pulse)   next = RX_BIT3;
                else        next = TX_BIT3;
      RX_BIT3 : if(Pulse)   next = TX_BIT2;
                else        next = RX_BIT3;
      TX_BIT2 : if(Pulse)   next = RX_BIT2;
                else        next = TX_BIT2;
      RX_BIT2 : if(Pulse)   next = TX_BIT1;
                else        next = RX_BIT2;
      TX_BIT1 : if(Pulse)   next = RX_BIT1;
                else        next = TX_BIT1;
      RX_BIT1 : if(Pulse)   next = TX_BIT0;
                else        next = RX_BIT1;
      TX_BIT0 : if(Pulse)   next = RX_BIT0;
                else        next = TX_BIT0;
      RX_BIT0 : if(Pulse)   next = END;
                else        next = RX_BIT0;
      END     : if(Pulse)   next = IDLE;
                else        next = END;
      default : next = IDLE;
    endcase

  // sequetinal logic of the FSM to generate the registerd outputs
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n) begin
      PulseEn <= 1'b0;
      LoadTx  <= 1'b0;
      ShiftTx <= 1'b0;
      ShiftRx <= 1'b0;
      EndTx   <= 1'b0;
      spiSck  <= 1'b0;
      Sck     <= 1'b0;
    end else begin
      PulseEn <= 1'b1;
      LoadTx  <= 1'b0;
      ShiftTx <= 1'b0;
      ShiftRx <= 1'b0;
      EndTx   <= 1'b0;
      spiSck  <= Pulse ? ~spiSck : spiSck;
      Sck     <= spiSck; // to align SCK and MOSI 
      case(state)
        IDLE : begin
          PulseEn <= StartTx ? 1'b1 : 1'b0; 
          Sck     <= CPol;    // to avoid Change SCK while CS low.
          LoadTx  <= StartTx; // transmission of bit 7
          spiSck  <= StartTx ? (CPha ? !CPol : CPol) : CPol;
        end
        RX_BIT31, RX_BIT30, RX_BIT29, RX_BIT28, RX_BIT27, RX_BIT26, RX_BIT25, RX_BIT24,RX_BIT23, RX_BIT22, RX_BIT21, RX_BIT20, RX_BIT19, RX_BIT18, RX_BIT17, RX_BIT16,RX_BIT15, RX_BIT14, RX_BIT13, RX_BIT12, RX_BIT11, RX_BIT10, RX_BIT9, RX_BIT8,RX_BIT7, RX_BIT6, RX_BIT5, RX_BIT4, RX_BIT3, RX_BIT2, RX_BIT1, RX_BIT0 : begin
          ShiftRx <= Pulse;
        end
        TX_BIT30,TX_BIT29, TX_BIT28,TX_BIT27, TX_BIT26, TX_BIT25, TX_BIT24, TX_BIT23, TX_BIT22, TX_BIT21,TX_BIT20, TX_BIT19, TX_BIT18, TX_BIT17, TX_BIT16, TX_BIT15, TX_BIT14,TX_BIT13, TX_BIT12, TX_BIT11, TX_BIT10, TX_BIT9, TX_BIT8, TX_BIT7,TX_BIT6, TX_BIT5, TX_BIT4, TX_BIT3, TX_BIT2, TX_BIT1, TX_BIT0: begin
          ShiftTx <= Pulse;
        end
        END : begin
          EndTx   <= Pulse ? 1'b1 : 1'b0;
          spiSck  <= Pulse ? CPol : spiSck; // generates transition when CPHA = 0    
        end
        default : begin
          PulseEn <= 1'b0;
          spiSck  <= 1'b0;
        end
      endcase
    end

// -----------------------------------------------------------------------------


endmodule

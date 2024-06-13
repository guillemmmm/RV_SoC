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

  localparam IDLE    = 5'd0,    // define states of the FSM
             RX_BIT7 = 5'd1,
             TX_BIT6 = 5'd2,
             RX_BIT6 = 5'd3,
             TX_BIT5 = 5'd4,
             RX_BIT5 = 5'd5,
             TX_BIT4 = 5'd6,
             RX_BIT4 = 5'd7,
             TX_BIT3 = 5'd8,
             RX_BIT3 = 5'd9,
             TX_BIT2 = 5'd10,
             RX_BIT2 = 5'd11,
             TX_BIT1 = 5'd12,
             RX_BIT1 = 5'd13,
             TX_BIT0 = 5'd14,
             RX_BIT0 = 5'd15,
             END     = 5'd16;

  reg [5-1:0] state, next; // FSM current state and next state var

  reg spiSck;    

  // state register
  always @(posedge Clk or negedge Rst_n)
    if(!Rst_n) state <= IDLE;
    else       state <= next;

  // combinational logic to calculate next state
  always @(state or StartTx or Pulse)
    case(state)
      IDLE    : if(StartTx) next = RX_BIT7;
                else        next = IDLE;
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
        RX_BIT7, RX_BIT6, RX_BIT5, RX_BIT4, RX_BIT3, RX_BIT2, RX_BIT1, RX_BIT0 : begin
          ShiftRx <= Pulse;
        end
        TX_BIT6, TX_BIT5, TX_BIT4, TX_BIT3, TX_BIT2, TX_BIT1, TX_BIT0: begin
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
// synopsys translate_off
reg [8*10-1:0] stateName; // shows the state name during simulation.
always @(state)
  case (state)
    IDLE : stateName = "IDLE      ";
    TX_BIT0 : stateName = "TX_BIT0  ";
    TX_BIT1 : stateName = "TX_BIT1  ";
    TX_BIT2 : stateName = "TX_BIT2  ";
    TX_BIT3 : stateName = "TX_BIT3  ";
    TX_BIT4 : stateName = "TX_BIT4  ";
    TX_BIT5 : stateName = "TX_BIT5  ";
    TX_BIT6 : stateName = "TX_BIT6  ";
    RX_BIT0 : stateName = "RX_BIT0  ";
    RX_BIT1 : stateName = "RX_BIT1  ";
    RX_BIT2 : stateName = "RX_BIT2  ";
    RX_BIT3 : stateName = "RX_BIT3  ";
    RX_BIT4 : stateName = "RX_BIT4  ";
    RX_BIT5 : stateName = "RX_BIT5  ";
    RX_BIT6 : stateName = "RX_BIT6  ";
    RX_BIT7 : stateName = "RX_BIT7  ";
    END     : stateName = "END      ";
    default : stateName = "XXXXXXX";
  endcase // case (state)

reg [8*10-1:0] nextName; // shows the state name during simulation.
always @(next)
  case (next)
    IDLE : nextName = "IDLE      ";
    TX_BIT0 : nextName = "TX_BIT0  ";
    TX_BIT1 : nextName = "TX_BIT1  ";
    TX_BIT2 : nextName = "TX_BIT2  ";
    TX_BIT3 : nextName = "TX_BIT3  ";
    TX_BIT4 : nextName = "TX_BIT4  ";
    TX_BIT5 : nextName = "TX_BIT5  ";
    TX_BIT6 : nextName = "TX_BIT6  ";
    RX_BIT0 : nextName = "RX_BIT0  ";
    RX_BIT1 : nextName = "RX_BIT1  ";
    RX_BIT2 : nextName = "RX_BIT2  ";
    RX_BIT3 : nextName = "RX_BIT3  ";
    RX_BIT4 : nextName = "RX_BIT4  ";
    RX_BIT5 : nextName = "RX_BIT5  ";
    RX_BIT6 : nextName = "RX_BIT6  ";
    RX_BIT7 : nextName = "RX_BIT7  ";
    END     : nextName = "END      ";
    default : nextName = "XXXXXXX";
  endcase // case (next)
// synopsys translate_on

endmodule

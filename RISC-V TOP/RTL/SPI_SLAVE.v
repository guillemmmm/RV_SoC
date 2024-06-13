
// MODUL SPI SLAVE PARAMETRITZABLE TANT DE MIDA COM DE MODE DE FUNCIONAMENT
// fet per GUILLEM PRENAFETA GUILERA (UB 2024)
/*
*
*      
*   
*/  

// SPI SLAVE (8 bits)
// SPI mode of CPol,CPha = 0,1

// Ultra low size SPI slave 3 + 3 (8b) == 6 registers

//primer fem una lectura i la guardem en un registre

module SPI_SLAVE
        (

        input wire rst, //rstn with shift RX
        input wire clk,

        //TX_FIFO
        output wire o_rd_TX,
        input wire [8-1:0] i_dataTX,

        //RX_FIFO
        output reg o_wr_RX,
        output reg [8-1:0] o_dataRX,

        //input CPol, CPha
        input wire [1:0] CPolCPha,

    
        //SPI interface (2ext)
        input wire i_SCLK,
        output wire o_MISO,
        input wire i_MOSI,
        input wire i_CSn //per nivell baix (CS a 0 esta activat)
        );

        //6 register

        reg [1:0] CSn;
        reg [1:0] SCK;

        reg [3-1:0] RXC;
        reg [3-1:0] TXC;

        always@(posedge clk) CSn <= {CSn[0], i_CSn};    
        always@(posedge clk) SCK <= {SCK[0], i_SCLK};

        wire SCKpos = SCK[0] && ~SCK[1];
        wire SCKneg = SCK[1] && ~SCK[0];

        wire cross = CPolCPha[1]^CPolCPha[0];

        wire shift  = (cross) ? SCKpos : SCKneg; //zero and 1 with transition of SCK
        wire shiftCS = shift | (CSn[1] & ~CSn[0])&(~CPolCPha[0]);   //neg CSn quan CPHa == 0
        wire sample = (cross) ? SCKneg : SCKpos;

/*
        //data shift
        always@(posedge clk) begin
          if(~|RXC)                   dataTX <= i_dataTX; //si encara no hem rebut res carreguem
          else if(shift)              dataTX <= dataTX << 1;
          else                        dataTX <=dataTX;
        end
*/

        //data shift
        always@(posedge clk) begin
          if(CSn[0])        TXC <= 3'b111;
          else if(shiftCS)  TXC <= RXC;
          else              TXC <= TXC;
        end
        /*
        always@(posedge clk) begin
          if(CSn[0])        o_MISO <= 1'bZ;
          else if(shiftCS)  o_MISO <= i_dataTX[RXC];
          else              o_MISO <= o_MISO;
        end
        */
        assign o_MISO = CSn[0] ? 1'bZ : i_dataTX[TXC];

        //data sample
        always@(posedge clk) begin
          if(sample)       o_dataRX <= {o_dataRX[6:0], i_MOSI};
          else             o_dataRX <= o_dataRX;
        end

        always@(posedge clk) begin //anem restant
          if(CSn[0]) begin
            RXC <= 3'b111;
            o_wr_RX <= 1'b0;
          end else if(sample) begin
            RXC <= RXC - 1'b1;
            if(~|RXC) begin //quan arribem a 0 hem rebut N-1 dades
              //hem rebut 8 bits
              o_wr_RX <= 1'b1;
            end else begin
              o_wr_RX <= 1'b0;
            end
          end else begin
            RXC <= RXC;
            o_wr_RX <= 1'b0;
          end
        end

        assign o_rd_TX = o_wr_RX;


endmodule





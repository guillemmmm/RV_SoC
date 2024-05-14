
// MODUL SPI SLAVE PARAMETRITZABLE TANT DE MIDA COM DE MODE DE FUNCIONAMENT
// fet per GUILLEM PRENAFETA GUILERA (UB 2024)
//

//Aquest slave rep primer el MSB
//I envia primer el MSB (protocol)

//Es pot configurar SW en el diferents modes (CPOL,CPHA)
//Es pot configurar de diferents tamanys 8,16,32 b
//S'ha d'activar per tal de rebre interrupcions

//LEN si son 8 bits LEN==7 si son 16 bits LEN==15 (4bits)

module SPI_SLAVE
        (

        input wire rstn, //rstn with shift RX
        input wire clk,

        //TX_FIFO
        output wire o_rd_TX,
        input wire [16-1:0] i_dataTX,

        //RX_FIFO
        output wire o_wr_RX,
        output reg [16-1:0] o_dataRX,

        //UC
        input wire [1:0] CPolPha,
        input wire [4-1:0] LEN,

        //SPI interface (2ext)
        input wire i_SCLK,
        output wire o_MISO,
        input wire i_MOSI,
        input wire i_CSn //per nivell baix (CS a 0 esta activat)
        );


        reg [5-1:0] rdcounter, txcounter;

        reg [1:0] rdcounterZero; //1 clk de retras

        //wire rdcounterZeroW = i_CSn ? 1'b0 : ~(|rdcounter);
        //wire rdcounterLENW = i_CSn ? 1'b0 : (rdcounter==LEN);

    
        wire sclk_sample, sclk_CSN_shift;

    assign sclk_sample = (CPolPha[1]^CPolPha[0]) ? ~i_SCLK : i_SCLK; //(posedge)
    //assign sclk_shift = ~sclk_sample;
    //assign sclk_CSN_shift = CPolPha[0] ? (1'b0) : (i_CSn);


    //lectura
    always@(posedge sclk_sample) begin
      o_dataRX<={o_dataRX[14:0], i_MOSI};
    end


    //escriptura
    always@(negedge sclk_sample or negedge rstn) begin
		if(~rstn) txcounter<=LEN;
      else txcounter<=LEN-rdcounter;
    end

    //rdcounter
    always@(posedge sclk_sample or negedge rstn) begin
      if(~rstn) begin //si abans era 1 CS
        rdcounter<=5'd0; //es legal?
      end else if(~i_CSn) begin
        if(rdcounter==(LEN)) begin
          rdcounter<=5'd0; //com si fos 0
        end else begin
          rdcounter<=rdcounter+1'b1;
        end
      end else begin
          rdcounter<=5'd0;
      end
    end

    assign o_wr_RX = i_CSn ? (1'b0) : (~rdcounterZero[1]&rdcounterZero[0]);
    assign o_rd_TX = o_wr_RX; 

    always@(posedge clk) rdcounterZero<={rdcounterZero[0], ~(|rdcounter)};

    assign o_MISO = i_CSn ? 1'bZ : i_dataTX[txcounter];


endmodule





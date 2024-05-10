
// MODUL SPI SLAVE PARAMETRITZABLE TANT DE MIDA COM DE MODE DE FUNCIONAMENT
// fet per GUILLEM PRENAFETA GUILERA (UB 2024)
//

//Aquest slave rep primer el MSB
//I envia primer el MSB (protocol)

//Es pot configurar SW en el diferents modes (CPOL,CPHA)
//Es pot configurar de diferents tamanys 8,16,32 b
//S'ha d'activar per tal de rebre interrupcions

//adreces SPI 
`define SPI_buf 3'd0;
`define SPI_status 3'd4; //status 16 bit

// [15:0] STATUS:
/*
 *
 *      [15]   TxFIFO empty Int (R/W)    (0)
 *      [14]   Rx FIFO FULL Int (R/W)    (0)
 *      [13]   RX int enable    (R/W)    (0)
 *      [12]   XXX
 *      [11:8] Bit Size         (R/W)  (8 bit->7 LEN 4'b0111)
 *      [7:6]  CPol, CPha       (R/W)  (2'b00)
 *      [5]    Shift FIFO's     (W)    (auto set to 1) 
 *      [4]    RX FIFO full     (R)
 *      [3]    RX FIFO empyt    (R)
 *      [2]    TX FIFO full     (R)
 *      [1]    TX FIFO empyt    (R)
 *      [0]    SPI busy (CS)    (R)
 */


module SPI_MODULE
        (

        input wire rstn,
        input wire clk,

        //CPU
        input wire          i_dbus_adr,
        input wire          i_dbus_cyc,
        input wire          i_dbus_we,
        input wire [16-1:0] i_dbus_dat,
        output wire [15:0]  o_dbus_rdt,
        output reg         o_dbus_ack,

        output wire intSPI,

        //SPI interface
        input wire i_SCLK,
        output wire o_MISO,
        input wire i_MOSI,
        input wire i_CSn //per nivell baix (CS a 0 esta activat)
        );

        
        reg [11-1:0] spi_cntl;

        wire RXfull, RXempty, TXfull, TXempty;
        //wire SPIbusy = !i_CSn;
        wire wTXfifo, wRXfifo;
        wire rTXfifo, rRXfifo;
        wire [16-1:0] wdataRXfifo, rdataTXfifo, rdataRXfifo;

        assign wTXfifo = (i_dbus_adr&i_dbus_we) ? 1'b0 : i_dbus_we&o_dbus_ack; //quan adreca es 0 i volem escriure
        
        assign rRXfifo = (i_dbus_adr) ? 1'b0 : i_dbus_cyc & o_dbus_ack; //volem que nomes duri 1 pols de rellotge
        //mantenim la dada a la sortida 1 clk mes abans de fer un flush a la FIFO
        //assign rRXfifo = (|i_dbus_adr) ? 1'b0 : i_dbus_cyc & o_dbus_ack;


        always @(posedge clk or negedge rstn) begin
            if (!rstn) o_dbus_ack<=1'b0;
            else o_dbus_ack <= i_dbus_cyc & !o_dbus_ack;
        end

        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                // reset
                spi_cntl<= 11'h138; //11'h38 de 8 bit SPI + 11'h100 de int de RX per bootloader
            end
            else if(i_dbus_we) begin
                if(i_dbus_adr) begin
                    if(i_dbus_cyc) spi_cntl<=i_dbus_dat[15:5]; //si adrea diferent de 0
                end
            end else begin
                spi_cntl<={spi_cntl[11-1:1], 1'b1};
            end
        end

        assign o_dbus_rdt = (i_dbus_adr) ? {spi_cntl, RXfull, RXempty, TXfull, TXempty, !i_CSn} : rdataRXfifo; 

        reg posA, posB;
        //ara farem interrupicio (que sera detector de posedge del registres full i empty o directament final paraula spi)
        assign intSPI = ( ( (~posA)&TXempty )&spi_cntl[10] ) | ( ( (~posB)&RXfull )&spi_cntl[9] ) | ( wRXfifo&spi_cntl[8] );

        always@(posedge clk) begin
            posA<=TXempty;
            posB<=RXfull;
        end


        SPI_SLAVE
        slave(
            .clk        (clk),
            .rstn       (rstn & (spi_cntl[0])), //when we shift we rst the spi module

            .i_SCLK     (i_SCLK),
            .i_CSn      (i_CSn),
            .i_MOSI     (i_MOSI),
            .o_MISO     (o_MISO),

            .CPolPha    (spi_cntl[2:1]),
            .LEN        (spi_cntl[6:3]),

            .o_rd_TX    (rTXfifo),
            .i_dataTX   (rdataTXfifo),

            .o_wr_RX    (wRXfifo),
            .o_dataRX   (wdataRXfifo)

         //   .int        () //la int es directament o_wr_RX
            );

        SPIfifo
        TXFIFO(
            .clk        (clk),
            .rstn       (rstn),

            .wen        (wTXfifo),
            .ren        (rTXfifo),
            .wdata      (i_dbus_dat),
            .rdata      (rdataTXfifo),
            .full       (TXfull),
            .empty      (TXempty),

            .shiftFIFO  (spi_cntl[0])
            );

        SPIfifo
        RXFIFO(
            .clk        (clk),
            .rstn       (rstn),

            .wen        (wRXfifo),
            .ren        (rRXfifo),
            .wdata      (wdataRXfifo),
            .rdata      (rdataRXfifo),
            .full       (RXfull),
            .empty      (RXempty),

            .shiftFIFO  (spi_cntl[0])
            );

endmodule





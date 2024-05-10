`default_nettype none
`include "spi_defines.vh"

`timescale 1ns/1ps
module TOP_tb;

    parameter memfile = "machine.hex";

    integer i;

    reg wb_clk = 1'b0;
    reg wb_rst = 1'b0;

    wire CS,MOSI,MISO,SCLK;
    reg [1:0] master_Addr;
    reg master_wr;
    reg [31:0] master_data2W;
    wire [31:0] master_data2Rd;

    reg [7:0] spi_conf;
    reg [7:0] spi_SS;

    reg [31:0] data;

   


    always  #31 wb_clk <= !wb_clk; //clock 16.1 MHz 62 pulses of 1ns T=62ns
    initial begin //reset general
      #62 wb_rst <= 1'b1;
      #124 wb_rst <=1'b0;
    end

    initial begin
      #200; //esperem a que es facin els resets
      Set_Master_SPI;
      #20000;
      sendData(32'h00000003);
      waitEnd;

      for (i=0;i<(36*13);i=i+1) begin //hem d'esperar minim 13 cicles instruccions del risc
        waitClk;
      end

      waitClk;
      sendData(32'h00000000);
      waitEnd;
      readSpi(`SPI_BUFFER,data);
      $display("La dada es: %h",data);
      $display(data);

    end

  


    initial begin
      #100000;
      $stop;
    end


    TOP
      #(.memfile  (memfile)
        )
    dut
      (
      .i_clk        (wb_clk),
      .rst        (wb_rst),

      .i_CS         (~CS), //es negat
      .i_MOSI       (MOSI),
      .SCLK         (SCLK),
      .o_MISO       (MISO)
      );

    spi_top
    spi_master
      (
        .Clk      (wb_clk),
        .Rst_n    (~wb_rst),
        .Addr     (master_Addr),
        .Wr       (master_wr),
        .DataWr   (master_data2W),
        .DataRd   (master_data2Rd),
        .Sck      (SCLK),
        .Mosi     (MOSI),
        .Miso     (MISO),
        .Ss0      (CS)
      );

      task sendData;
        input [32-1:0] dada;
        begin
          spi_SS = 8'hFE; //baixem CS
          writeSpi(`SPI_SSELEC,{24'h0,spi_SS}); //li definim el selector CS
          waitClk;
          writeSpi(`SPI_BUFFER,dada);
          waitClk;
          //spi_SS = 8'h00; //pujem CS
          //writeSpi(`SPI_SSELEC,{24'h0,spi_SS}); //li definim el selector CS
        end
      endtask

      task writeSpi;
        input [2-1:0] adress;
        input [32-1:0] dada;
        begin
          master_data2W=dada;
          master_Addr=adress;
          master_wr=1'b1;
          waitClk;
          master_wr=1'b0;
        end
      // Task automatically generates a write to a register.
      // Inputs data to write and reg address.
      endtask

      task readSpi;
        input [2-1:0] adress;
        output [32-1:0] data_out;
        begin
          master_Addr=adress;
          #5; //simulem el retard de la lectura
          data_out=master_data2Rd;
        end
        // Task automatically generates a write to a register.
        // Input reg address. Output read data.
      endtask

      task waitEnd;
        begin
          master_Addr=`SPI_CTRL;
          waitClk; //nos asseguramos que se propaga bien la direccion
          fork //farem servir un forkjoin
            begin : wait_time
              
              for(i=0;i<50000;i=i+1) begin
                waitClk; 
              end
              //posem 30 ja que f_trans=fclk necessitem minim 16 clocks
              $display("Error de timeout esperant a que el busy es posi a 0 a %t",$time);
              disable busy_wait;
            end
            begin : busy_wait
              wait(master_data2Rd[7]==1'b0);
              #5
              disable wait_time;
            end
          join
        end
    endtask

      task Set_Master_SPI;
        begin
          spi_conf = {2'b00,1'b0,1'b0,4'd2}; //Ho configurem com CPOL,CPha=0 i Cpre=2
          writeSpi(`SPI_CONFIG,{24'h0,spi_conf}); //li definim el divisor del SCK
          waitClk;
          waitClk;
          writeSpi(`SPI_CTRL,8'h01); //posem el bit de control a 1 per activar les transmissions
          waitClk;
        end
      endtask


      task waitClk;
        begin
          @(posedge wb_clk);
          #2;

        end
      endtask




endmodule

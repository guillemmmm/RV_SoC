/********1*********2*********3*********4*********5*********6*********7*********8
* File : tb_spi_regs.v
*_______________________________________________________________________________
*
* Revision history
*
* Name          Date        Observations
* ------------------------------------------------------------------------------
* -            06/05/2024   Version.
* ------------------------------------------------------------------------------
*_______________________________________________________________________________
*
* Description
* Testbench to verify the SPI slave from RISC-V architecture
*_______________________________________________________________________________

* (c) Copyright Universitat de Barcelona, 2024. Guillem Prenafeta
*
*********1*********2*********3*********4*********5*********6*********7*********/

`timescale 1 ns / 1 ps

`define DELAY 2 //typical delays ticks (ns)

`include "spi_defines.vh"

module tb_spi_slave();

//hardware registers/wires--------------//
  reg clk;
  reg rstn;

  //CPU regs
  reg wb_dbus_cyc;
  reg wb_dbus_we;
  wire wb_dbus_ack;
  reg [16-1:0] wb_dbus_WData;
  wire [16-1:0] wb_dbus_RData;
  reg [3-1:0] wb_dbus_addr;
  wire SPIint;

  wire MISO;
  wire MOSI;
  wire SCLK;
  wire CSn;

  //to SPI master
  reg SPImaster_wr;
  reg [2-1:0] SPImaster_addr;
  reg [8-1:0] SPImaster_WData;
  wire [8-1:0] SPImaster_RData;

  reg [3:0] freq_div;
  reg [1:0] j;


//testbench signals---------------//
integer i,k;
reg [8-1:0] dataTESTvec [7:0];
reg [16-1:0] data16b;
reg [8-1:0]  data8b;
integer error;

SPI_MODULE 
  DUT(
    .clk        (clk),
    .rstn       (rstn),

    .i_dbus_adr  (wb_dbus_addr),
    .i_dbus_cyc  (wb_dbus_cyc),
    .i_dbus_we    (wb_dbus_we),
    .i_dbus_dat   (wb_dbus_WData),
    .o_dbus_rdt   (wb_dbus_RData),
    .o_dbus_ack   (wb_dbus_ack),

    .intSPI       (SPIint),

    .i_SCLK       (SCLK),
    .o_MISO       (MISO),
    .i_MOSI       (MOSI),
    .i_CSn        (CSn)
    );


spi_top //spi which we know that works
  MASTER_SPI(
        .Clk      (clk),
        .Rst_n    (rstn),
        .Addr     (SPImaster_addr),
        .Wr       (SPImaster_wr),
        .DataWr   (SPImaster_WData),
        .DataRd   (SPImaster_RData),
        .Sck      (SCLK),
        .Mosi     (MOSI),
        .Miso     (MISO),
        .Ss0      (CSn)
    );


initial clk=1'b0;
always #10 clk=~clk; // 50 MHz clock

initial begin //program structure
  $timeformat(-9, 2, " ns", 10); // format for the time print
  //definition of control variables
    rstn=1'b1;

    wb_dbus_cyc=1'b0;
      wb_dbus_we=1'b0;
    wb_dbus_WData=16'd0;
    wb_dbus_cyc=1'b0;
    wb_dbus_addr=16'd0;

    SPImaster_wr=1'b0;
    SPImaster_addr=2'd0;
    SPImaster_WData=8'd0;

    CSnH;

  #100; //delay inicial

  GeneralRstn; //PoRST

  //master SPI initialization
  
  writeSpiMaster(`SPI_CTRL,8'h01);
  writeSpiMaster(`SPI_CONFIG,{2'b00,4'd9}); //divisor de 10

  writeSpiSlave(4'd4, {1'b0, 1'b1, 1'b0, 5'd8, 2'd0, 6'd0});

  $display("[Info- %t] Starting test of communication modes", $time);


  for (k=0;k<4;k=k+1) begin
    j=k;
    $display("[Info- %t] Test CPol, CPha=%b", $time, j);
    writeSpiMaster(`SPI_CONFIG,{2'd0,j,4'd9}); //divisor de 10
    readSpiSlave(4'd4, data16b);
    data16b=(data16b & 16'hFF3F) | (j*64); //movem 8 posicions que es multiplicar per 64
    writeSpiSlave(4'd4, data16b);

    CSnL;

    fork //separem programa per master i slave

    begin: masterT

    for(i=0;i<8;i=i+1) begin
      dataTESTvec[i]=8'hAB;
      sendData(dataTESTvec[i]);
      waitEnd; //nomes es pot enviar de un en un
      //aqui podem mirar si salta la interrupcio d'una paraula rebuda
    end

    waitCycles(200);
    $display("Error de timeout esperant interrupcio a %t",$time);
    disable intWait;
    end

    begin: intWait

    waitClk;

    waitInterrupt;
    readSpiSlave(3'd4, data16b);
    waitClk;

    disable masterT;

    end  

    join

    CSnH;

    //ara llegim RX FIFO
    for(i=0;i<8;i=i+1) begin
      readSpiSlave(4'd0, data8b);
      waitClk; //nomes es pot enviar de un en un
      if(data8b==dataTESTvec[i]) begin
        $display("[Info- %t] Correct reception", $time);
      end else $display("[Info- %t] Error of reception", $time);
    end

  end



  $display("[Info- %t] Starting test of maximal freq div", $time);

  freq_div = 4'd10;

  while(freq_div>0) begin
    freq_div = freq_div -1;
    for (k=0;k<4;k=k+1) begin
      error=0;
      j=k;
      $display("[Info- %t] Test CPol, CPha=%b and freq_div = %d", $time, j, freq_div);
      writeSpiMaster(`SPI_CONFIG,{2'd0,j,freq_div}); //divisor de 10
      readSpiSlave(4'd4, data16b);
      data16b=(data16b & 16'hFF3F) | (j*64); //movem 8 posicions que es multiplicar per 64
      writeSpiSlave(4'd4, data16b);

      CSnL;

      fork //separem programa per master i slave

      begin: masterT1

      for(i=0;i<8;i=i+1) begin
        //dataTESTvec[i]=8'hAB;
        dataTESTvec[i]=10*i+1;
        sendData(dataTESTvec[i]);
        waitEnd; //nomes es pot enviar de un en un
        //aqui podem mirar si salta la interrupcio d'una paraula rebuda
      end

      waitCycles(200);
      $display("Error de timeout esperant interrupcio a %t",$time);
      disable intWait1;
      end

      begin: intWait1

      waitClk;

      waitInterrupt;
      readSpiSlave(3'd4, data16b);
      waitClk;

      disable masterT1;

      end  

      join

      CSnH;

      //ara llegim RX FIFO
      for(i=0;i<8;i=i+1) begin
        readSpiSlave(4'd0, data8b);
        //$display("[Info- %t]  %d, %d", $time, data8b, dataTESTvec[i]);
        waitClk; //nomes es pot enviar de un en un
        if(data8b==dataTESTvec[i]) begin
          //$display("[Info- %t] Correct reception", $time);
        end else error=error+1;//$display("[Info- %t] Error of reception", $time);
      end

      if(error>0) begin
        $display("[Info- %t] %d ERRORS", $time, error);
      end else begin
        $display("[Info- %t] Correct reception", $time);
      end

    end
  end


  $stop;


  
end


//---------------TASKS-----------------------------------------//


//CPU TASKS-----------------------------------------

task writeSpiSlave;
    input [3-1:0] adress;
    input [16-1:0] dada;

    begin
      wb_dbus_WData=dada;
      wb_dbus_addr=adress;
      waitClk;
      wb_dbus_we=1'b1;
      #`DELAY;
      wb_dbus_cyc=1'b1;
      wait(wb_dbus_ack==1'b1);
      waitClk;
      wb_dbus_cyc=1'b0;
      #`DELAY;
      wb_dbus_we=1'b0;

    end
endtask

task readSpiSlave;
    input [3-1:0] adress;
    output [16-1:0] dada;

    begin
      wb_dbus_addr=adress;
      waitClk;
      wb_dbus_we=1'b0;
      #`DELAY;
      wb_dbus_cyc=1'b1;
      wait(wb_dbus_ack==1'b1);
      @(posedge clk) dada<=wb_dbus_RData;
      //dada=wb_dbus_RData;
      wb_dbus_cyc=1'b0;
      #`DELAY;
      wb_dbus_we=1'b0;
      //dada=wb_dbus_RData;

    end
endtask

task waitInterrupt;
  begin
    wait(SPIint==1'b1);
    waitClk;
    waitClk;
  end
endtask


//SPI MASTER TASKS----------------------------------

task sendData;
        input [8-1:0] dada;
        begin
          writeSpiMaster(`SPI_BUFFER,dada);
          waitClk;
          //spi_SS = 8'h00; //pujem CS,, es puja sol
          //writeSpiMaster(`SPI_SSELEC,{24'h0,spi_SS}); //li definim el selector CS
        end
endtask

task CSnH;
  begin
    data8b = 8'hFF; //baixem CS
    writeSpiMaster(`SPI_SSELEC,{24'h0,data8b}); //li definim el selector CS
    waitClk;
  end
endtask

task CSnL;
  begin
    data8b = 8'hFE; //baixem CS
    writeSpiMaster(`SPI_SSELEC,{24'h0,data8b}); //li definim el selector CS
    waitClk;
  end
endtask

task writeSpiMaster;
    input [2-1:0] adress;
    input [8-1:0] dada;
    begin
    SPImaster_WData=dada;
    SPImaster_addr=adress;
    SPImaster_wr=1'b1;
    waitClk;
    SPImaster_wr=1'b0;
    end
    // Task automatically generates a write to a register.
    // Inputs data to write and reg address.
  endtask

  task readSpiMaster;
    input [2-1:0] adress;
    output [8-1:0] data_out;
    begin
      SPImaster_addr=adress;
      #5; //simulem el retard de la lectura
      data_out=SPImaster_RData;
    end
    // Task automatically generates a write to a register.
    // Input reg address. Output read data.
  endtask

task waitEnd; //tasca per esperar final transmissio SPI
    begin
      SPImaster_addr=`SPI_CTRL;
      waitClk; //nos asseguramos que se propaga bien la direccion
      fork //farem servir un forkjoin
        begin : wait_time
        waitCycles(5000); //posem 30 ja que f_trans=fclk necessitem minim 16 clocks
        $display("Error de timeout esperant a que el busy es posi a 0 a %t",$time);
        disable busy_wait;
        end
        begin : busy_wait
        wait(SPImaster_RData[7]==1'b0);
        #5
        disable wait_time;
        end
      join
    end
  endtask


//BASIC TASKS---------------------------------------

// generation of reset pulse
    task GeneralRstn;
      begin
        $display("[Info- %t] Reset", $time);
        rstn = 1'b0;
        waitCycles(3);
        rstn = 1'b1;
      end
    endtask

// wait for N clock cycles
    task waitCycles;
      input [32-1:0] Ncycles;
      begin
        repeat(Ncycles) begin
          waitClk;
        end
      end

    endtask

// wait the next posedge clock
    task waitClk;
      begin
        @(posedge clk);
          #`DELAY;
      end //begin
    endtask

endmodule
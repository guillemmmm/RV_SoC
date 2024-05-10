//TESTBENCH SOC TOP GUILLEM PRENAFETA

`default_nettype none
`include "spi_defines.vh"

`timescale 1ns/1ps
`define DELAY 2 //typical delays ticks (ns)


module TOP_tb;

  parameter memfile = "machine.hex"; //codi d'on cargarem el programa en hex

//hardware registers/wires--------------//
  reg clk;
  reg rstn;

  //CPU regs
  reg PROGN;
  wire [8-1:0] reg_GPIOs;

  wire MISO;
  wire MOSI;
  wire SCLK;
  wire CSn;

  //to SPI master
  reg SPImaster_wr;
  reg [2-1:0] SPImaster_addr;
  reg [8-1:0] SPImaster_WData;
  wire [8-1:0] SPImaster_RData;


//testbench signals---------------//
  integer i, ig, ix, ij;

  reg [8-1:0] dada8b;
  reg [8-1:0] dada8bit4[4-1:0];
  reg [32-1:0] dada32b, dada32bRX;


parameter depth = 512;
reg [31:0]        mem [0:depth-1];


    TOP
    dut
      (
      .i_clk        (clk),
      .globalRSTN   (rstn),
      .PROG         (~PROGN),

      .i_CSn         (CSn), //es negat
      .i_MOSI       (MOSI),
      .i_SCLK         (SCLK),
      .o_MISO       (MISO),
      .GPIO_out     (reg_GPIOs)
      );

    spi_top
    spi_master
      (
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

    
  //GENEREM EL CLK
    initial clk=1'b0;
    always  #10 clk <= ~clk; //clock de 50MHz


    initial begin //reset general

      $timeformat(-9, 2, " ns", 10); // format for the time print
      //definition of control variables
      rstn=1'b1;

      SPImaster_wr=1'b0;
      SPImaster_addr=2'd0;
      SPImaster_WData=8'd0;

      CSnH;
      
      $display("[Info- %t] Reset", $time);
      GeneralRstnPROG; //fem un rst per programar

      $display("[Info- %t] Començem a programar", $time);
      programMEM; //programem la memoria
      $display("[Info- %t] Final programacio", $time);

      //ARA LLEGIM LA MEMORIA PER VEURE QUE ES CORRECTE::
      $display("[Info- %t] Pasem a lectura ", $time);
      GeneralRstnPROG; //fem un rst per programar
      
      readIMEM;

      $display("[Info- %t] Final lectura ", $time);
      /////////////////////////
      //Ara ja podem començar a treballar amb el RISCV

      $display("[Info- %t] General RST ", $time);
      GeneralRstn;
      Set_Master_SPI;

      /////////////////////////
      delayus(1000); //1ms d'inicialitzacio

      //enviem per spi
      CSnL; //BAIXEM cs
      dada8b=8'd2; //enviem nomes 1Byte //on volem escriure IMEM
      sendData(dada8b);
      waitEnd;
      readSpiMaster(`SPI_BUFFER,dada8b);
      waitClk;
      $display("La dada es: %h",dada8b); //rebem la dada inicial ens dona igual
      CSnH;

      delayus(50);

      //tonrem a enviar i mirem que hem rebut
      CSnL; //BAIXEM cs
      dada8b=8'd2; //enviem nomes 1Byte //on volem escriure IMEM
      sendData(dada8b);
      waitEnd;
      readSpiMaster(`SPI_BUFFER,dada8b);
      waitClk;
      $display("La dada es: %h",dada8b); //rebem la dada inicial ens dona igual
      CSnH;

      delayus(100);

      $stop;
      
  
    end


    initial begin //timeout
      #8000000;
      $stop;
    end

  
//SPI MASTER CONTROLLER TASKS----------------------------------

  task programMEM;
    begin

      //com hem fet rst, tornem a configurar SPI master (coses del modul)
      Set_Master_SPI; //el configurem a 8b CPOL, CPha 00
      #1000;

      CSnL; //BAIXEM cs

      dada8b=8'd2; //enviem nomes 1Byte //on volem escriure IMEM
      sendData(dada8b);
      waitEnd;
      readSpiMaster(`SPI_BUFFER,dada8b);
      waitClk;
      $display("La dada es: %h",dada8b); //rebem la dada inicial ens dona igual

      $readmemh(memfile, mem); //llegim dades

      ig=0;
    
      begin: carrega //enviem tots els bytes
        forever
        begin
          dada32b=mem[ig];
          if(dada32b===32'hXXXXXXXX) begin
            disable carrega;
          end else begin
            sendInstructionSPI(dada32b,dada32bRX); //anem enviant les dades
            //$display("Dada rebuda %h, Dada escrita %h, it: %d",dada32bRX,dada32b,ig);
            ig=ig+1;
          end
        end

      end 

      waitClk;
      sendInstructionSPI(32'hFFFFFFFF,dada32b); //enviem dada final (no hi ha cap RV-32IM que sigui tot FF)
      $display("La dada es: %h",dada32b);
      #50;
      $display("S'han carregat %d dades",ig);
      $display("End of BOOT");
      #100;

      CSnH; //tornem a pujar CSn
    end
  endtask

  task readIMEM;
    begin
      Set_Master_SPI; //el configurem a 8b
      #1000;

      CSnL; //iniciem com

      waitClk;
      dada8b=8'd1; //enviem nomes 1Byte i volem llegir
      sendData(dada8b);
      waitEnd;
      readSpiMaster(`SPI_BUFFER,dada8b);
      waitClk;
      $display("La dada es: %h",dada8b); //rebem la dada inicial ens dona igual

      #1;
      dada32b<=32'h0; //direccio 0
      waitClk;
      $display("%h",dada32b);
      sendInstructionSPI(dada32b,dada32bRX);


      for (ix=0;ix<ig;ix=ix+1) begin
        dada32b<=dada32b+32'd4;
        waitClk;
        //$display("%h",lectura);
        sendInstructionSPI(dada32b,dada32bRX);
        #5;
        //$display("%h, %h, %d",dada32bRX,mem[ix],ix);
        if(dada32bRX==mem[ix]) begin
          #1;
        end else begin
          $display("Error de IMEM");
          if(ix>10) begin
            $stop;
          end
        end
      end

      CSnH;

    end
  endtask


  task sendInstructionSPI; //LSB first and MSBit first
        input [32-1:0] dada;
        output [32-1:0] dada32b;
        begin
          dada8bit4[3]=dada[31:24];
          dada8bit4[2]=dada[23:16];
          dada8bit4[1]=dada[15:8];
          dada8bit4[0]=dada[7:0];
          //reg [7:0] dada2[3:0];
          //integer ij;
          for(ij=0;ij<4;ij=ij+1) begin
            waitClk;
            //$display("%h",dada3[ij]);
            sendData(dada8bit4[ij]);
            waitEnd;
            readSpiMaster(`SPI_BUFFER,dada8bit4[ij]);
            //$display("%h",dada2[ij]);
          end
          dada32b={dada8bit4[3],dada8bit4[2],dada8bit4[1],dada8bit4[0]};
        end
  endtask


//SPI MASTER TASKS---------------------------------------------

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
      dada8b = 8'hFF; //baixem CS
      writeSpiMaster(`SPI_SSELEC,{24'h0,dada8b}); //li definim el selector CS
      waitClk;
    end
  endtask

  task CSnL;
    begin
      dada8b = 8'hFE; //baixem CS
      writeSpiMaster(`SPI_SSELEC,{24'h0,dada8b}); //li definim el selector CS
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

  task Set_Master_SPI;
    begin
      dada8b = {2'b00,1'b0,1'b0,4'd4}; //Ho configurem com CPOL,CPha=0 i Cpre=2
      writeSpiMaster(`SPI_CONFIG,dada8b); //li definim el divisor del SCK
      waitClk;
      waitClk;
      writeSpiMaster(`SPI_CTRL,8'h01); //posem el bit de control a 1 per activar les transmissions
      waitClk;
    end
  endtask

//BASIC TASKS--------------------------------------------------

// generation of reset pulse
    task GeneralRstn;
      begin
        $display("[Info- %t] Reset", $time);
        rstn = 1'b0;
        waitCycles(3);
        rstn = 1'b1;
      end
    endtask

// generation of reset pulse in prog mode
    task GeneralRstnPROG;
      begin
        $display("[Info- %t] Reset PROGN", $time);
        rstn = 1'b0;
        #`DELAY;
        PROGN = 1'b0;
        waitCycles(3);
        rstn = 1'b1;
        #`DELAY;
        PROGN = 1'b1;
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

// tasca per esperar un cicle d'instruccio
    task waitInsCycle;
      input integer num;
      begin
        for (i=0;i<(36*num);i=i+1) begin //hem d'esperar minim 13 cicles instruccions del risc
          waitClk;
        end
      end
    endtask

    task delayms;
      input integer delayus;
      begin
        //sabent rellotge de 50MHz 1 us son 50 clk
        waitCycles(50);
      end
    endtask


endmodule

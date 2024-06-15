#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "driverlib/interrupt.h"
#include "inc/hw_memmap.h"
#include "driverlib/uart.h"
#include "driverlib/adc.h"
#include "driverlib/timer.h"
#include "inc/hw_ints.h"


//#include "definicions.h"
#include "initHW.h"
//#include "fHW.h"
//#include "fSW.h"
#include "flash.h"

#define IMEM_len 512

/*
 * Program to control RISC-V via SPI (and possibility to program it)
 *
 * We use::
 *
 *  SSI2:
 *      SCK: PB4
 *      CS: PA3
 *      MOSI: PB7
 *      MISO: PB6
 *
 *  RST: PC5
 *  PROG: PC6
 *
 *  GPIO 0 (output):PC4
 *  GPIO 1 (input): PC3
 *  GPIO 2 (input): PC2
 *
 */

uint8_t SPI_tx[8];
uint8_t SPI_rx[8];
uint32_t data[512]; //512 paraules

bool SPI_program(bool prog); //if prog true then we program

void main(void)
{

    init_clock(); //clock de 16MHz

    init_timers();

    init_SPI();

    Flash_Enable(); //activem flash

    IntMasterEnable(); //habilitem interrupcions

    //Flash_Enable(); //habilitem flash

    //ara començarem a llegir a la flash el codi a enviar i el posem a la RAM
    //Flash_Read(listGlobal,1428);

    //ara ja tenim les dades i començarem a enviar per SPI el programa

    //fem un rst de 200us sense PROGn
    PROGn_hi;
    RSTn_lo;
    delay100us(2);
    RSTn_hi;
    RSTn_lo;
    delay100us(2);
    RSTn_hi;
    RSTn_lo;
    delay100us(2);
    RSTn_hi;

    //aqui ja tenim el micro funcionant
    delay100us(10); //1ms

    //ara li enviem instruccio per SPI i mirem el que rebem
    SPI_send(8, SPI_tx, SPI_rx);

    SPI_program(true);

    PROGn_hi;
    RSTn_lo;
    delay100us(2);
    RSTn_hi; //ja esta programada



    while(1){
    }

}

bool SPI_program(bool prog){

    //primer llegim la flash i ho posem a la SRAM
    uint32_t count;

    if(prog){
        //ara volem escriure
        RSTn_lo; //fent un rst
        PROGn_lo;
        delay100us(2);
        RSTn_hi; //deixem de fer el rst
        delay100us(1);
        PROGn_hi;

        //ara enviem per SPI instruccio que volem escriure
        SPI_tx[0]=0x02; //imem write
        SPI_send(1, SPI_tx, SPI_rx);

        Flash_Read(data, IMEM_len); //llegim la flash
        count=0;
        while(1){ //ara comencem a enviar les paraules 1 a una enviant primer el LSByte
            //enviem $ Bytes
            SPI_send(4, (uint8_t*)&data[count], SPI_rx);
            count++;
            if(data[count]==0xFFFFFFFF) break;
        }
    } else{
        count=512;
    }

    //ara ens posem a llegir per veure si funciona correctament
    RSTn_lo; //fent un rst
    PROGn_lo;
    delay100us(2);
    RSTn_hi; //deixem de fer el rst
    delay100us(1);
    PROGn_hi;

    SPI_tx[0]=0x01; //imem read
    SPI_send(1, SPI_tx, SPI_rx);

    delay100us(1);

    uint32_t var, varRX;

    var=0;
    SPI_send(4, (uint8_t*)&var, SPI_rx);

    uint16_t ig;
    while(ig<count){
        ig++;
        var+=0x04;
        SPI_send(4, (uint8_t*)&var, (uint8_t*)&varRX);
        if(varRX!=data[ig]){
            __nop();
        }

    }


    return false;
}

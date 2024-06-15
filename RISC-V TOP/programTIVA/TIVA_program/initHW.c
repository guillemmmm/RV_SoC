/*
 * initHW.c
 *
 *  Created on: 1 nov. 2023
 *      Author: guill
 */
#include "initHW.h"

#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"


#include "driverlib/sysctl.h" //libreria del sistema
#include "driverlib/gpio.h"
#include "driverlib/pwm.h"
#include "driverlib/pin_map.h"
#include "driverlib/timer.h"
#include "driverlib/interrupt.h"
#include "driverlib/adc.h"
#include "inc/hw_ints.h"
#include "driverlib/uart.h"
#include "inc/hw_types.h"
#include "inc/hw_gpio.h"
#include "inc/hw_memmap.h"
#include "driverlib/ssi.h"
#include "inc/hw_ssi.h"
//#include "nRF24L01lib.h"

//#define RSTn_hi      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_5, GPIO_PIN_5);
//#define RSTn_lo      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_5, 0);
//#define PROGn_hi     GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_6, GPIO_PIN_6);
//#define PROGn_lo     GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_6, 0);
//#define OUT_hi      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_4, GPIO_PIN_4);
//#define OUT_lo      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_4, 0);
//#define CSn_hi      GPIOPinWrite(GPIO_PORTA_BASE, GPIO_PIN_3, GPIO_PIN_3);
//#define CSn_lo      GPIOPinWrite(GPIO_PORTA_BASE, GPIO_PIN_3, 0);


void init_clock()
{
    SysCtlClockSet(
    SYSCTL_SYSDIV_1 | SYSCTL_USE_OSC | SYSCTL_OSC_MAIN | SYSCTL_XTAL_16MHZ);
    //SysCtlPWMClockSet(SYSCTL_PWMDIV_16); //com volem freq de fins a 160kHz cap a baix, dividim 16MHz/16=1MHz
} //end init_clock

void init_timers(){
    //----
    //Timer for nRF24lib (period 100us)
    SysCtlPeripheralEnable(SYSCTL_PERIPH_TIMER1);
    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_TIMER1))
    {
        __nop();
    }
    TimerClockSourceSet(TIMER1_BASE, TIMER_CLOCK_PIOSC); //16MHz on 100us==16000000*100*10**-6
    TimerConfigure(TIMER1_BASE, TIMER_CFG_SPLIT_PAIR | TIMER_CFG_A_PERIODIC);
    TimerLoadSet(TIMER1_BASE, TIMER_A, 1600);
    IntRegister(INT_TIMER1A, ISRtimerDelay); //enlacem rutina interrrupcio
    TimerIntEnable(TIMER1_BASE, TIMER_TIMA_TIMEOUT);


}

void init_SPI(void){
#if defined(init_PORT_B) //si no esta definit
#else
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOB); //port del SPI PB7 MOSI  PB4 SCLK i MISO PB6
#define init_PORT_B
#endif

    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_GPIOB))
    {
        __nop();
    }

#if defined(init_PORT_C) //si no esta definit
#else
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOC); //PC6 CE del nRF24 i PC5 nRF24 int
#define init_PORT_C
#endif

    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_GPIOC))
    {
        __nop();
    }

#if defined(init_PORT_A) //si no esta definit
#else
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA); //PA4 SPI LCD CS i PA3 nRF SPI CS
#define init_PORT_A
#endif

    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_GPIOA))
    {
        __nop();
    }
#if defined(init_PORT_E) //si no esta definit
#else
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOE); //PA4 SPI LCD CS i PA3 nRF SPI CS
#define init_PORT_E
#endif

    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_GPIOE))
    {
        __nop();
    }
    SysCtlPeripheralEnable(SYSCTL_PERIPH_SSI2); //posar SPI q es fa servir
    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_SSI2))
    {
        __nop();
    }

    GPIOPinTypeGPIOOutput(GPIO_PORTA_BASE, GPIO_PIN_3); //PA3 SPI_CS
    GPIOPinTypeGPIOOutput(GPIO_PORTC_BASE, GPIO_PIN_6);  //PC6 PROG i PC5 RST
    GPIOPinTypeGPIOOutput(GPIO_PORTC_BASE, GPIO_PIN_5);
    GPIOPinTypeGPIOOutput(GPIO_PORTC_BASE, GPIO_PIN_4); //gpio

    GPIOPinTypeGPIOInput(GPIO_PORTC_BASE, GPIO_PIN_3); //gpio input
    GPIOPinTypeGPIOInput(GPIO_PORTC_BASE, GPIO_PIN_2);


//    GPIOIntRegister(GPIO_PORTC_BASE, nRF24ISR);
//    GPIOIntRegister(GPIO_PORTE_BASE, nRF24ISR);
//
//    GPIOIntTypeSet(GPIO_PORTC_BASE, GPIO_PIN_5, GPIO_FALLING_EDGE); //SWitch de baixada
//    GPIOIntTypeSet(GPIO_PORTE_BASE, GPIO_PIN_2, GPIO_FALLING_EDGE); //SWitch de baixada
//    GPIOIntEnable(GPIO_PORTC_BASE, GPIO_PIN_5); //habilitem ints de nRF24
//    GPIOIntEnable(GPIO_PORTE_BASE, GPIO_PIN_2); //habilitem ints de nRF24
//    IntEnable(INT_GPIOC);
//    IntEnable(INT_GPIOE);




    GPIOPinConfigure(GPIO_PB4_SSI2CLK); //posar els pins q es fan servir
    //    GPIOPinConfigure(GPIO_PA3_SSI0FSS);
    GPIOPinConfigure(GPIO_PB6_SSI2RX);
    GPIOPinConfigure(GPIO_PB7_SSI2TX);

    GPIOPinTypeSSI(GPIO_PORTB_BASE, GPIO_PIN_4 | GPIO_PIN_6 | GPIO_PIN_7); //posar pins SPI

    SSIConfigSetExpClk(SSI2_BASE, SysCtlClockGet(), SSI_FRF_MOTO_MODE_0, //cpol 0 cpha 0
                       SSI_MODE_MASTER, 1000000, 8);  //mode esclau DATA WIDTH 8 a 1MHz

    RSTn_hi; //posem rst a 1
    PROGn_hi; //prog a 1
    OUT_lo; //sortida out a 0
    CSn_hi; //cs de spi a 1

    SSIEnable(SSI2_BASE); //enable SPI module

}


uint32_t TCount;
void delay100us(uint32_t ticks)
{
    TCount=0;
    TimerLoadSet(TIMER1_BASE, TIMER_A, 1600); //100us
    IntEnable(INT_TIMER1A);
    TimerEnable(TIMER1_BASE, TIMER_A);
    while (TCount < ticks)
    {
    }
    TimerDisable(TIMER1_BASE, TIMER_A);
    IntDisable(INT_TIMER1A);
}

void ISRtimerDelay(void)
{
    TimerIntClear(TIMER1_BASE, TIMER_TIMA_TIMEOUT); //netejem flag
    TCount++;
}

void SPI_send(uint8_t count, uint8_t * dataout, uint8_t * datain){
    CSn_lo;
    uint8_t i,k,j;
    j=0;
    while(1){
        i=0;
        while(SSIDataPutNonBlocking(SSI2_BASE, *(dataout+i+j))) //omplim la TXFIFO
        {
            i++;
            if(i>=count){
                break;
            }
        }
        //s'ha omplert TX FIFO
        //esperem a que es buidi
        while((HWREG(SSI2_BASE + SSI_O_SR) & SSI_SR_BSY)); //esperem a que es buidi Tx
        uint32_t *RxPointer;
        for (k=0;k<i;k++){
            RxPointer=&(*(datain+k+j));
            SSIDataGetNonBlocking(SSI2_BASE, RxPointer);
            //*(datain+k+j)=dades[i];
        }
        if((j+i)>=count){ //paraules enviades
            break;
        }
        j=j+i; //si reiniciem bucle hem enviat 8 paraules
    }
    CSn_hi;
}

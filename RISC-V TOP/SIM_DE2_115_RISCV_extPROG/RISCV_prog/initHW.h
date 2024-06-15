/*
 * initHW.h
 *
 *  Created on: 1 nov. 2023
 *      Author: guill
 */

#ifndef INITHW_H_
#define INITHW_H_

#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

#include "driverlib/gpio.h"

#define RSTn_hi      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_5, GPIO_PIN_5);
#define RSTn_lo      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_5, 0);
#define PROGn_hi     GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_6, GPIO_PIN_6);
#define PROGn_lo     GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_6, 0);
#define OUT_hi      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_4, GPIO_PIN_4);
#define OUT_lo      GPIOPinWrite(GPIO_PORTC_BASE, GPIO_PIN_4, 0);
#define CSn_hi      GPIOPinWrite(GPIO_PORTA_BASE, GPIO_PIN_3, GPIO_PIN_3);
#define CSn_lo      GPIOPinWrite(GPIO_PORTA_BASE, GPIO_PIN_3, 0);


void init_clock(void);

void init_timers(void);

void init_SPI(void);

void SPI_send(uint8_t count, uint8_t * dataout, uint8_t * datain);

void delay100us(uint32_t ticks);

void ISRtimerDelay(void);



#endif /* INITHW_H_ */

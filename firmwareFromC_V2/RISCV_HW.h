// Guillem Prenafeta RISCV regs

#ifndef RVHW
#define RVHW

#include <stdbool.h>
#include <stdint.h>

#define SetUPIntRegister intRegister(NVIC())


//low level functions for riscv 

void _nop(void); //no operation

void interrupt_enable(void); //habilitem interrupcions generals
void interruptPortEnable(bool estat); //habilitar interrupcions

void intRegister(void (*func)(void)); //rutina interrupcio
void NVIC(void); //interrupt function that finds the int source

void INTENABLE(uint8_t source);
void INTDISABLE(uint8_t source);














#endif
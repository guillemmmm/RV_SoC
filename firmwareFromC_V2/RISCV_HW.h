// Guillem Prenafeta RISCV regs

#ifndef RVHW
#define RVHW

#include <stdbool.h>
#include <stdint.h>


//low level functions for riscv 

void _nop(void); //no operation

void interrupt_enable(void); //habilitem interrupcions generals
void interruptPortEnable(bool estat);

void intRegister(void (*func)(void)); //rutina interrupcio













#endif
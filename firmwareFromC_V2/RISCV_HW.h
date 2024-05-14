// Guillem Prenafeta RISCV regs

#ifndef RVHW
#define RVHW

#include <stdbool.h>
#include <stdint.h>
#include "RISCV_regs.h"

#define SetUPIntRegister intRegister(NVIC)


//low level functions for riscv 

void _nop(void); //no operation

void interrupt_enable(void); //habilitem interrupcions generals(inici prog)
void interruptPortEnable(bool estat); //habilitar interrupcions (per activar/desactivar global interrupts)

void intRegister(void (*func)(void)); //rutina interrupcio que enllaca NVIC
void NVIC(void); //interrupt function that finds the int source

void INTENABLE(uint8_t source); //per activar i desactivar les interrupcions de cada modul 0xFF (es tots els moduls)
void INTDISABLE(uint8_t source);

//----- GPIO functions------------//
void GPIO_Input(uint8_t GPIOpin);
void GPIO_Output(uint8_t GPIOpin);
void GPIO_write(uint8_t GPIOpin, uint8_t GPIO_state);
uint8_t GPIO_read(void);
void GPIO_IntEnable(uint8_t GPIOpin);

#endif
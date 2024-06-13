// Guillem Prenafeta RISCV regs

#ifndef RVHW
#define RVHW

#include <stdbool.h>
#include <stdint.h>
#include "RISCV_regs.h"

#define SetUPIntRegister intRegister(irq_entry)

#define _nop	__asm__ volatile("nop")
#define  nop	__asm__ volatile("nop")


//low level functions for riscv 

void enable_mie(void); //habilitem interrupcions generals(inici prog)
void enable_timer_interrupts(bool estat); //habilitar interrupcions (per activar/desactivar global interrupts) timer

void intRegister(void (*func)(void)); //rutina interrupcio que enllaca NVIC

void INTENABLE(uint8_t source); //per activar i desactivar les interrupcions de cada modul 0xFF (es tots els moduls)
void INTDISABLE(uint8_t source);

//----- GPIO functions------------//
void GPIO_Input(uint8_t GPIOpin);
void GPIO_Output(uint8_t GPIOpin);
void GPIO_write(uint8_t GPIOpin, uint8_t GPIO_state);
uint8_t GPIO_read(void);
void GPIO_IntEnable(uint8_t GPIOpin);

void irq_entry(void) __attribute__ ((interrupt ("machine")));

//--- SSI functions--------------//
bool SSI_PutData(uint8_t data); //returns false if TxFIFO full
bool SSI_ReadData(uint8_t* data); //returns false if RxFIFO empty

/* //Volem ahorrar tamany de IMEM
bool isTXFfull(void);
bool isTXFempty(void);
bool isRXFfull(void);
bool isRXFempty(void);
*/


#endif
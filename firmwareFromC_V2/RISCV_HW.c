

#include <stdint.h>
#include <stdbool.h>

#include "RISCV_HW.h"

#define hardwareMEMread 			(volatile uint32_t*)0x10000004 //variable que fem servir a la funcio int register

extern void SSI_isr(void);
extern void GPIO_isr(void);
extern void Timer_isr(void);


void _nop(void){
	__asm__ volatile(//
		"addi x0, zero, 0"
		
		);
}

void volatile interrupt_enable(void){
	__asm__ volatile("li t1, 0x00000008");
	__asm__ volatile(".word 0x00031073");
}

//0 desactivar 1 activar (per les interrupcions del nostre sistema)
void interruptPortEnable(bool estat){
	if(estat){
		__asm__ volatile("li t1, 0x00000080");
	}else{
		__asm__ volatile("li t1, 0x00000000");
	}
	__asm__ volatile(".word 0x00431073");
}

void intRegister(void (*func)(void)){	

	uintptr_t funcAddress = (uintptr_t)func;
	*(hardwareMEMread)=(uint32_t)funcAddress;
	__asm__ volatile("li a0, 0x10000004");
	__asm__ volatile("lw t1, 0(a0)");
	__asm__ volatile(".word 0x00531073"); //llegeix t1 i ho fica com a vector d'interrupcions
}

void NVIC(void){
	uint8_t IntVec;
	// (es desactiven interrupcions automaticament)

	IntVec = *(INTM);
	*(INTM) = 0; //NETEJEM FLAG INTERRUPCIONS

	
	if(IntVec&int_SSI){ //timer interrupt
		SSI_isr();
	}
	if(IntVec&int_GPIO){
		GPIO_isr();
	}
	if(IntVec&int_Timer){
		Timer_isr();
	}

	//reactivem nterrupcions (funcio interrupt port enable)
	__asm__ volatile("li t1, 0x00000008");
	__asm__ volatile(".word 0x00031073");
}

void INTENABLE(uint32_t source){
	*(INTM+1)=*(INTM+1) | source;
}
void INTDISABLE(uint32_t source){
	*(INTM+1)=*(INTM+1) & (~source);
}



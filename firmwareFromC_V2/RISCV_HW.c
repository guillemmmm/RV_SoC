

#include <stdint.h>
#include <stdbool.h>

#include "RISCV_HW.h"

#define hardwareMEMread 			(volatile uint32_t*)0x10000004 //variable que fem servir a la funcio int register


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
	__asm__ volatile("li a0, 0x10000000");
	__asm__ volatile("lw t1, 0(a0)");
	__asm__ volatile(".word 0x00531073"); //llegeix t1 i ho fica com a vector d'interrupcions
}



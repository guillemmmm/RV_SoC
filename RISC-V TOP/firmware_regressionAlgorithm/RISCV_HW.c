

//#include <stdint.h>
//#include <stdbool.h>

#include "RISCV_HW.h"

//#define hardwareMEMread 			(volatile uint32_t*)0x10000004 //variable que fem servir a la funcio int register (ultima pos de memoria util)

extern void SSI_isr(void);
extern void GPIO_isr(void);
extern void Timer_isr(void);
extern void INT3isr(void);

void volatile enable_mie(void){
	__asm__ volatile("li t1, 0x00000008"); //S'ha de ficar 0x08 al registre MIE
	__asm__ volatile(".word 0x00031073"); //escribim csrw registre t1 mie
	//__asm__ volatile("csrw mstatus, t1"); //es necessiten extensions
}

//0 desactivar 1 activar (per les interrupcions del nostre sistema)
void enable_timer_interrupts(bool estat){
	if(estat){
		__asm__ volatile("li t1, 0x00000080");
	}else{
		__asm__ volatile("li t1, 0x00000000");
	}
	__asm__ volatile(".word 0x00431073"); //escribim csre registre t1 el mtie
}

void intRegister(void (*func)(void)){	

	/*

	uintptr_t funcAddress = (uintptr_t)func;
	*(hardwareMEMread)=(uint32_t)funcAddress;
	__asm__ volatile("li a0, 0x10000004");
	__asm__ volatile("lw t1, 0(a0)");
	__asm__ volatile(".word 0x00531073"); //llegeix t1 i ho fica com a vector d'interrupcions

	*/

	uint32_t value = (uint32_t)((uintptr_t)func);

	__asm__ volatile ("mv t1, %0" 
                      : // output: none // 
                      : "r" (value) // input : from register //
                      : "t1");

	__asm__ volatile(".word 0x00531073"); //llegeix t1 i ho fica com a vector d'interrupcions


}

void INTENABLE(uint8_t source){
	*(INTM+IE)=*(INTM+IE) | source;
}
void INTDISABLE(uint8_t source){
	*(INTM+IE)=*(INTM+IE) & (~source);
}


//----- GPIO functions------------//
void GPIO_Input(uint8_t GPIOpin){
	*(GPIO+dirGPIO) = (*(GPIO+dirGPIO))&(~GPIOpin);
}
void GPIO_Output(uint8_t GPIOpin){
	*(GPIO+dirGPIO) = (*(GPIO+dirGPIO))|(GPIOpin);
}
void GPIO_write(uint8_t GPIOpin, uint8_t GPIO_state){
	*(GPIO+setGPIO) = ((*(GPIO+setGPIO))&(~GPIOpin))|(GPIO_state&GPIOpin);
}
uint8_t GPIO_read(void){
	return (*(GPIO+getGPIO));
}
void GPIO_IntEnable(uint8_t GPIOpin){
	//ha de ser input
	*(GPIO+setGPIO) = ((*(GPIO+setGPIO))&(~GPIOpin))|(GPIOpin);
}

void irq_entry(void)  {
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
	if(IntVec&BIT3){
		INT3isr();
	}

	//reactivem nterrupcions (funcio interrupt port enable)
	//__asm__ volatile("li t1, 0x00000008");
	//__asm__ volatile(".word 0x00031073");

/* (a VEGADES)
	//sha d'augmentar en 2'd4 el MEPC ja que sino tornem a la direccio anterior i volem pc+1
	__asm__ volatile(".word 0x34129373"); //guarda a x6 MEPC i escriu x5 a MEPC //llegim MEPC i fiquem a x6
	__asm__ volatile("addi x6, x6, 4"); //l//sumem x6+4
	__asm__ volatile(".word 0x341312f3"); //guarda a x5 MEPC i escriu x6 a MEPC //fiquem a MEPC x6
	*/

}

/*void csr_write_mtvec(uint32_t value) {
    __asm__ volatile ("csrw    mtvec, %0" 
                      : // output: none // 
                      : "r" (value) // input : from register //
                      : // clobbers: none //);
}*/

bool SSI_PutData(uint8_t data){
	uint16_t reg16 = *(SSI+1);
	if(reg16&BIT2){ //si esta plena
		return false;
	} else{
		*(SSI) = data;
		return false;
	}
}

bool SSI_ReadData(uint8_t* data){
	uint16_t reg16 = *(SSI+1);
	if(reg16&BIT3){ //si esta buida
		return false;
	} else{
		*data = *SSI;
		return false;
	}
}

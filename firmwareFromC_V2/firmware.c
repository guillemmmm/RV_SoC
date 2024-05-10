

#include <stdint.h>
#include <stdbool.h>

#include "RISCV_regs.h"


/*#if !defined(CLK_FREQ)
#error "Set -DCLK_FREQ=<clock frequency>"
#endif*/

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
//extern uint32_t sram;
/*
#define regControl_fotons			(*(volatile uint32_t*)0x10000000)
#define mem_pointer					(volatile uint32_t*)0x10000000
#define INTpointer					(volatile uint32_t*)0x40000000
#define SPIpointer 					(volatile uint32_t*)0x20000000

#define hardwareMEMread 			(volatile uint32_t*)0x10000000
*/

#define BASE_MASK 					0x00FFFFFF
#define EXP_MASK 					0xFF000000
#define EXP_SH   					24


//SPI
#define SPI32b 0
#define SPI16b 1
#define SPI8b 2


// --------------------------------------------------------

//volatile uint32_t* pf;

// --------------------------------------------------------

void configuracioSPI(uint8_t mode, uint8_t registerWidth, bool enable);
void interruptVec(void);
void SPImodule(void);

// --------------------------------------------------------
volatile uint32_t variable=1;

void main(){

	_nop();


	interrupt_enable();
	configuracioSPI(0, SPI32b, true);
	intRegister(interruptVec);
	interruptPortEnable(true);

	while(1){
		_nop();
	}


}

void configuracioSPI(uint8_t mode, uint8_t registerWidth,bool enable){
	uint32_t conf = 0x00000000;

	conf = mode | (registerWidth<<2);

	if (enable){
		conf|=0x10;
	}

	*(SPIpointer+1) = conf;

}

void interruptVec(void){ //llegirem d'on prove l'interrupcio
	uint32_t IntVec;
	// (es desactiven interrupcions)

	IntVec = *(INTpointer);
	*(INTpointer) = 0; //NETEJEM FLAG INTERRUPCIONS

	if((IntVec&0x1)==0x1){ //spi
		SPImodule();
	}

	//reactivem nterrupcions
	__asm__ volatile("li t1, 0x00000008");
	__asm__ volatile(".word 0x00031073");


}

void SPImodule(void){
	uint32_t receivedata;

	__asm__ volatile("li t1, 0xFFFF0000"); //falgs per trobar el programa

	receivedata = *(SPIpointer);

//comunicacio estandard
	if(receivedata==0x00000301){
		*(SPIpointer) = 0x00ACDC00;
	}
	else if(receivedata==0xFFFFFFFF){
		*(SPIpointer) = 0;
		__asm__ volatile("li t5, 0x0000000A"); //flags
	}

	__asm__ volatile("li t1, 0x0000FFFF");

}





//tenemos en memoria 16 datos de 8bits (4 registros de 32b)
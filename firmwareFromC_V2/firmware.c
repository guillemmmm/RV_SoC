

#include <stdint.h>
#include <stdbool.h>

#include "RISCV_regs.h"
#include "RISCV_HW.h"


// --------------------------------------------------------

//volatile uint32_t* pf;

// --------------------------------------------------------

void configuracioSPI(uint8_t mode, uint8_t registerWidth, bool enable);
void interruptVec(void);
void SPImodule(void);

// --------------------------------------------------------

void SSI_isr(void);



void main(){

	_nop(); //no-op


	SetUPIntRegister; //configurem NVIC com a funcio quan s'executa interrupcio
	interrupt_enable();

	interruptPortEnable(true); //habilitem interrupcions (falta activar interrupcions per modul)

	INTENABLE(int_SSI); //habilitem ints spi

	while(1){
		_nop();
	}
}

void SSI_isr(void){
	//llegim SPI
	uint32_t dada = *(SSI);
	//posem dada a la TxFIFO
	*(SSI)=dada;
}


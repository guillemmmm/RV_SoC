

#include <stdint.h>
#include <stdbool.h>

#include "RISCV_regs.h"
#include "RISCV_HW.h"



// ---------- Interruption ISR definitions ----------------- //
void SSI_isr(void);
void GPIO_isr(void);
void Timer_isr(void);
// -------------------------------------------------------- //
void init_GPIOs(void);

void main(){

	_nop(); //no-op


	SetUPIntRegister; //configurem NVIC com a funcio quan s'executa interrupcio
	interrupt_enable();

	interruptPortEnable(true); //habilitem interrupcions (falta activar interrupcions per modul)

	INTENABLE(int_SSI); //habilitem ints spi

	init_GPIOs();

	while(1){
		_nop();
	}
}

void SSI_isr(void){ //a 50MHz tarda uns 20.766 us en respondre (1038 clk a 36 clk/ins son 28 cicles d'instruccio)
	//llegim SPI
	uint32_t dada = *(SSI);
	//posem dada a la TxFIFO
	*(SSI)=dada;
}

void GPIO_isr(void){
	uint8_t interrupt_status=*(GPIO+isGPIO);
	*(GPIO+isGPIO)=0;

	if(interrupt_status&PIN0){
		*(GPIO+setGPIO)=*(GPIO+setGPIO) ^ PIN1; //canviem output pin1
	}
	
}
void Timer_isr(void){}

void init_GPIOs(void){
	//defininim el GPIO PIN0 com input interrupt, i PIN1 com output amb valor inicial de 1

	GPIO_Input(PIN0);
	GPIO_IntEnable(PIN0);
	//habilitem interrupcions modul
	INTENABLE(int_GPIO);

	GPIO_Output(PIN1);
	GPIO_write(PIN1, PIN1); //escribim un 1
}


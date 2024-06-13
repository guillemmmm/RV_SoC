

#include <stdint.h>
#include <stdbool.h>

#include "RISCV_regs.h"
#include "RISCV_HW.h"

#define resTAU 4 //must be less than 8 to avoid overflow
#define logF 4



// ---------- Interruption ISR definitions ----------------- //
void SSI_isr(void); //per programar i parlar amb el chip
void GPIO_isr(void); //farem servir gpio per indicar dades preparades per enviar/rebre
void Timer_isr(void); //el timer no el farem servir
void INT3isr(void);
// -------------------------------------------------------- //
	// USER functions //

void init_GPIOs(void);

void calcTAU(volatile uint32_t* regs, uint8_t nRegs, uint32_t* tauRAW); //tau = tauRAW/2**res * log2(e)

uint32_t log2n(uint32_t x);

// ------ MAIN -------------------------------------------- //

bool data2process;
uint32_t tau;

void main(){

	_nop; //no-op

/*
	//__asm__ volatile(".word 0x34102573"); //llegeix MEPC i ho fica a x5/t0
	//__asm__ volatile("li x5, 4"); //suma t0=t0+4
	__asm__ volatile("li x6, 0"); //llegeix MEPC i ho fica a x5/t0  //fiquem a x6 0
	__asm__ volatile(".word 0x341312f3"); //guarda a x5 MEPC i escriu x6 a MEPC //fiquem x6 a MEPC (0)
	__asm__ volatile(".word 0x34129373"); //guarda a x6 MEPC i escriu x5 a MEPC //llegim MEPC i fiquem a x6
	__asm__ volatile("addi x6, x6, 4"); //llegeix MEPC i ho fica a x5/t0 //sumem x6+4
	__asm__ volatile(".word 0x341312f3"); //guarda a x5 MEPC i escriu x6 a MEPC //fiquem a MEPC x6
	*/


	SetUPIntRegister; //in order to setup de MTVEC

	enable_mie();

	enable_timer_interrupts(true);

	//INTENABLE(int_SSI); //habilitem ints spi

	init_GPIOs();

	INTENABLE(BIT3); //habilitem interrupcions (int4)

	data2process=false;
	GPIO_write(PIN0, PIN0); //activem mesures
	while(1){
		if(data2process){
			data2process=false;

			//calculem la TAU
			calcTAU(HW_C_regs, 64, &tau); //llegim contadors on suposem que hi han 64

			//posem la TAU a la FIFO del SPI
			//buidem TXFIFO SPI per si de cas i omplim amb dades
			*(SSI+SSICONF) |= BIT5; //fem un shift de les FIFOs
			SSI_PutData(0xAB); //indiquem que tenim valor
			uint8_t* ptr8 = (uint8_t*)&tau;
			SSI_PutData(*(ptr8+0));
			SSI_PutData(*(ptr8+1));
			SSI_PutData(*(ptr8+2));
			SSI_PutData(*(ptr8+3));
			//indiquem que tenim calcul fet
			GPIO_write(PIN2, PIN2);
			nop; //temps suficient
			GPIO_write(PIN2, 0); //baixem flag 
		} else{
			nop;
		}
	}
}

void SSI_isr(void){ //a 50MHz tarda uns 20.766 us en respondre (1038 clk a 36 clk/ins son 28 cicles d'instruccio)
	//llegim SPI
	//treiem la dada
	uint16_t dada;
	dada = *(SSI);
	//GPIO_write(PIN2, 0); //baixem flag 
}

void GPIO_isr(void){
}
void Timer_isr(void){
}
void INT3isr(void){
	data2process=true;	
}

void init_GPIOs(void){
	//farem servir GPIO 0 per triggeritzar mesura
	//farem servir GPIO 2 com output per indicar master TAU calculada

	GPIO_Output(PIN0);
	GPIO_write(PIN0, 0); //escribim 0

	GPIO_Output(PIN2);
	GPIO_write(PIN2, 0); //escribim 0
}

void calcTAU(volatile uint32_t* regs, uint8_t nRegs, uint32_t* tauRAW){
	//CMM algorithm when we add all bins
	
	uint32_t var = 0;
	uint32_t var1 = 0;
	uint32_t i;

	for (i=0;i<nRegs;i++){
		var += (i+1)*(*(regs+i));
		var1 += *(regs+i);
	}
	var <<= resTAU; //tau precision
	*tauRAW = var / var1;
}
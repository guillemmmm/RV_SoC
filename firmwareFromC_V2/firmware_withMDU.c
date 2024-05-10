

#include <stdint.h>
#include <stdbool.h>


/*#if !defined(CLK_FREQ)
#error "Set -DCLK_FREQ=<clock frequency>"
#endif*/

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define regControl_fotons			(*(volatile uint32_t*)0x10000000)
#define mem_pointer					(volatile uint32_t*)0x10000000

#define BASE_MASK 					0x00FFFFFF
#define EXP_MASK 					0xFF000000
#define EXP_SH   					24


// --------------------------------------------------------
uint32_t  div(uint32_t a, uint32_t b);
uint32_t log(uint32_t a);
uint32_t tau(uint32_t* punter, uint8_t num_punts);

// --------------------------------------------------------


void main(){

	__asm__ volatile(//
		"addi x0, zero, 0"
		
		);

	uint32_t ar;
	uint32_t i;


	while(1){
		for (i=1;i<256;i++){
			ar=log(i);
			*(&regControl_fotons+i)=ar;
		}
		*(&regControl_fotons+1)=250;
		*(&regControl_fotons+2)=152;
		*(&regControl_fotons+3)=92;
		*(&regControl_fotons+4)=56;
		*(&regControl_fotons+5)=34;
		*(&regControl_fotons+6)=21;
		*(&regControl_fotons+7)=12;
		*(&regControl_fotons+8)=8;

		uint32_t taucalc;
		uint32_t* punter;
		punter=(&regControl_fotons)+1;
		taucalc=tau(punter,8);
		*(&regControl_fotons+16)=0xFFFFFFFF;
		*(&regControl_fotons+17)=taucalc;
		*(&regControl_fotons+18)=0;

		while(1){
			__asm__ volatile(
		"addi x0, zero, 0"
		
		);
		}

	}


}


uint32_t log(uint32_t a){ //a>1 ja que si es 1 log1=0 (no cal fer-lo) (a ha de ser maxim 8b)
	uint32_t logaritme=0;
	uint32_t dividend;

	if(a==1){
		return logaritme;
	}
	else{
		int32_t dif=1;
		uint32_t i=0;
		while(dif>0){ //mirem el limit inferior
			i++;
			dif=a-(1<<i);
		}
		//logartime sera a/(2**(i+1)-2**i)+i-1 (on el quocient pren valors entre 1 i 2) (per tant 2î+1-2î val maxim 128 per tant sabem que l'altre valdra 256 per tant podem pasar d'aquests 8b a 16b (multiplicant per 2**16) per tenir mes prec a la divisio)
		if(dif==0){
			logaritme=(i<<8);
			return logaritme;
		}
		else{
			i--;
			logaritme=a<<8;
			dividend=1<<i;
			logaritme=logaritme/dividend;
			//logaritme=div(logaritme,dividend); //fem la divisio de a*2**8/2**i+1-2**i
			logaritme=logaritme+((i-1)<<8); //tenim el resultat amb 2**8 (2 decimals minim)
			return logaritme;
	}

	}
}

uint32_t tau(uint32_t* punter, uint8_t num_punts){ //recordar que tenim els valors del logaritme amb un factor 2**8=256 per tant, tau amb un factor 256
	uint32_t sumx; //1/2*num_punts-1*(1+num_punts-1)
	uint32_t sumx2;//1/6*num_punts-1*(1+num_punts-1)(1+2num_punts-2)=1/6*(num_punts-1)*(num_punts)*(2numpunts-1)
	uint32_t sumxy=0;
	uint32_t sumy=0;
	uint32_t sum2x=0; //sumx)**2
	uint32_t Nsumx2=0; 
	uint32_t Nsumxy=0; 
	uint32_t sumxsumy=0; 
	uint32_t dada;


	uint32_t i;

	for(i=0;i<num_punts;i++){ //fem el logaritme de la dada
		dada=*(punter+i);
		dada=log(dada);
		sumy+=dada;
		sumxy+=i*dada;

	}

	sumx=num_punts*(num_punts-1);
	sumx=sumx>>1; //dividim entre 2
	sumx2=sumx*(-1+(num_punts<<1));
	sumx2=sumx2/3;//dividim 1/3
	sum2x=sumx*sumx;
	sumxsumy=sumx*sumy;


	Nsumx2=sumx2*num_punts;
	Nsumxy=sumxy*num_punts;

	Nsumx2=(Nsumx2-sum2x)<<16;
	sumxsumy=sumxsumy-Nsumxy;
	//uint32_t tauf=div(Nsumx2,sumxsumy);
	uint32_t tauf=Nsumx2/sumxsumy;
	return tauf; //DEVUELVE TAU_RARA DONDE TAU=TAU_RARA*LOG2(E)*2**-8
}





//tenemos en memoria 16 datos de 8bits (4 registros de 32b)
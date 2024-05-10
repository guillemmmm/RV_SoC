// Guillem Prenafeta RISCV regs

#ifndef RVregs
#define RVregs

#include <stdbool.h>
#include <stdint.h>


//--- MODULES POINTERS-------------------//

#define DMEM			(volatile uint32_t*)0x10000000
#define SSI				(volatile uint32_t*)0x20000000
#define GPIO			(volatile uint32_t*)0x30000000
#define INT 			(volatile uint32_t*)0x40000000


//---- SSI OFFETS ---------//

#define SSIDR 			0
#define SSICONF			1

//---- GPIO OFFSET--------//

#define getGPIO 		0
#define setGPIO 		1
#define dirGPIO 		2
#define isGPIO			3

//---- INT OFFSETS--------//

#define IE 				1
#define IS  			0








// BIT defines

#define BIT0 0x01
#define BIT1 0x02
#define BIT2 0x04
#define BIT3 0x08
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80




#endif
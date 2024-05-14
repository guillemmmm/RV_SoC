// Guillem Prenafeta RISCV regs

#ifndef RVregs
#define RVregs

#include <stdbool.h>
#include <stdint.h>


//--- MODULES POINTERS-------------------//

#define DMEM			(volatile uint32_t*)0x10000000
#define SSI				(volatile uint16_t*)0x20000000
#define GPIO			(volatile uint8_t*)0x30000000
#define INTM			(volatile uint8_t*)0x40000000


//---- SSI OFFETS ---------//

#define SSIDR 			0
#define SSICONF			2

//---- GPIO OFFSET--------//

#define getGPIO 		0
#define setGPIO 		4
#define dirGPIO 		8
#define isGPIO			12

//---- INT OFFSETS--------//

#define IE 				4
#define IS  			0

//----- Interrupt Sources

#define int_SSI        	0x01
#define int_GPIO       	0x02
#define int_Timer      	0x04








// BIT defines

#define BIT0 0x01
#define BIT1 0x02
#define BIT2 0x04
#define BIT3 0x08
#define BIT4 0x10
#define BIT5 0x20
#define BIT6 0x40
#define BIT7 0x80

// GPIO defines

#define PIN0 0x01
#define PIN1 0x02
#define PIN2 0x04
#define PIN3 0x08
#define PIN4 0x10
#define PIN5 0x20
#define PIN6 0x40
#define PIN7 0x80




#endif
/*  GUILLEM PRENAFETA 2024
 * flash.H
 *
 *  CODE SOURCE LIBRARY FROM::: Copyright (c) 2017 Jim Spicer
 *  https://github.com/jspicer-code/Tiva-C-Embedded/blob/master/LICENSE
 */

#ifndef FLASH_H_
#define FLASH_H_

#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

void Flash_Enable(void);

int Flash_Erase(int blockCount);

int Flash_Write(uint32_t* data, uint32_t wordCount);

void Flash_Read(void* data, uint32_t wordCount);

#endif /* FLASH_H_ */



// DATA STRUCTURE //
/*
 *
 *  1ST WORD:: 0xF0F0ABCD  (error word) to know if its well uploaded
 *  2nd: Number of Points [31:24] (MS)  -- Base velocity [23:0]
 *  3rd: Interval velocity[31:16] (MS)  -- Lim velocity[15:0] (LS)
 *  4rd-4rd+N-1 Delay number (CLK)
 *  4rd+N END WORD 0xF0F0DCBA
 *
 */

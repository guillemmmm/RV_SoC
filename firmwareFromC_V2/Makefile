CROSS=riscv32-unknown-elf-
CFLAGS = -march=rv32im -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -mstrict-align -O0  


firmware.elf: sections.lds start.s firmware.c
	${CROSS}gcc -DCLK_FREQ=50000000 ${CFLAGS} -o $@ start.s firmware.c RISCV_HW.c



%.hex: %.elf
	${CROSS}objcopy -O verilog $< $@

%.lst: %.elf
	${CROSS}objdump -d $< >$@



all_noflash: firmware.elf firmware.hex firmware.lst

run_make_word: firmware.hex
	python3 makeWord.py


all: clear all_noflash run_make_word

clear:
	rm -rf *.elf
	rm -rf *.hex
	rm -rf *.lst
	rm -rf *.v
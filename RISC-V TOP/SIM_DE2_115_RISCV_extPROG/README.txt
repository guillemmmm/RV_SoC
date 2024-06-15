En aquesta carpeta està contingut tot el projecte de programació d'un RISCV que es programa externament amb un micro de texas instruments (msp430).

Per fer-ho el poregrama en C es compila en gcc RV32-IM i s'extreu el codi en format HEX.
Un cop tenim les paraules del codi executem un programa en python que ho converteix en Intel HEX (adreça de memòria 0x00020000) per posar-li a la FLASH del micro.

Per ficar el HEX a la FLASH, entrem en el mode debugger i fem LOAD_MEMORY.

En el programa ja ens encarreguem de llegir la FLASH i enviar-la per SPI per programar el RISC-V.

El programa el que fa es gestionar dos tipus d'interrupcions, si hi ha un negedge del boto (PIN 0) canvia l'estat del PIN 1 (output) i cada cop que salta un timer de ~500 ms salta una interrupció commutant el PIN 2. Gestionant tot aixó des de la CPU RiscV de 32 bits.
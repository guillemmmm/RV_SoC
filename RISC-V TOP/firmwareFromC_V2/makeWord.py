#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

import sys


with open('firmware.hex','r') as file:
    entrada_data=file.read()
    numeros=entrada_data.split()
    #print(len(numeros))
    datos_nuevo=''
    k=0
    for i in range(0,int((len(numeros)-1)/4)):
        #print(i)
        cadena=''
        for k in range(0,4):
            #print(numeros[1+(3-k)*(i+1)])
            #print(1+(3-k)+4*(i))
            cadena=cadena+numeros[1+(3-k)+4*(i)]
            
        #print(cadena)
        datos_nuevo=datos_nuevo+(cadena+' ')
        datos_nuevo=datos_nuevo.replace(" ","\n")
    #print(datos_nuevo)
    with open("codi.hex","w") as file_w:
        file_w.write(datos_nuevo)
    with open("machine.hex","w") as file_w:
        file_w.write(datos_nuevo)
    with open("../SYN/codi.hex","w") as file_w:
        file_w.write(datos_nuevo)
    with open("../Testbench/codi.hex","w") as file_w:
        file_w.write(datos_nuevo)

    
    print("Program size %d words which is %d Bytes (%d bits)\n" % ((len(numeros)-1)/4, len(numeros)-1, (len(numeros)-1)*8))




    

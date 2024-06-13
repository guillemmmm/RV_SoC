import sys 
import random as r
import math as m
import matplotlib.pyplot as plt

def gen_list(tau, N, nbins, iprint):
    llista = [0 for i in range(nbins)]
    for _ in range(0,N):
        temps=r.random()
        temps=-tau*m.log(1-temps)
        ti=int(temps)
        if(ti<nbins):
            llista[ti]=llista[ti]+1
    if (iprint==1):
        valores = []
        for indice, frecuencia in enumerate(llista):
            valores.extend([indice] * frecuencia)

        # Crear el histograma
        plt.hist(valores, bins=len(llista), edgecolor='black')#, align='left', range=(0, len(lista)))

        # Añadir título y etiquetas
        plt.title(f'Histograma de tau={tau}')
        plt.xlabel('BIN')
        plt.ylabel('Cuentas')

        # Mostrar el histograma
        plt.show()
    return llista

def wr_list(llista):
    with open('numeros.hex', 'w') as archivo:
        for i in llista:
            archivo.write(f'{i:08X}\n')



if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: python generar_numeros.py <tau> <nbins> <Npunts>")
        sys.exit(1)
    
    tau = float(sys.argv[1])
    nbins = int(sys.argv[2])
    N = int(sys.argv[3])
    llista = gen_list(tau, N, nbins, 0)
    wr_list(llista)
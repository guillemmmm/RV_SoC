import sys
import os
import random as r
import math as m
import matplotlib.pyplot as plt


def hex2float(hex):
    dec=int(hex,16)
    return dec*m.log2(m.e)/16

def plotData(aTXT):

    if not os.path.exists('resultados'):
        os.makedirs('resultados')

    # Inicializar los vectores
    vector1 = []
    vector2 = []
    vector3 = []

    # Leer los datos del archivo
    with open(aTXT, 'r') as archivo:
        for linea in archivo:
            # Suponiendo que los datos están separados por punto y coma y espacio
            datos = linea.strip().split('; ')
            if len(datos) == 3:
                vector1.append(float(datos[0]))
                vector2.append(float(datos[1]))
                vector3.append(float(datos[2]))
    lista_error = []
    lista_x=[]
    lista_tiempo_ms =[]
    for i in range(0, len(vector1)):
        lista_error.append(abs(100*(vector1[i]-vector2[i])/(vector1[i])))
        lista_x.append(100*vector1[i]/65)
        lista_tiempo_ms.append(vector3[i]/1000000)

    # Crear el gráfico para error de tau
    plt.figure()
    plt.plot(lista_x,lista_error)# marker='o', label='Vector 1')
    #plt.title('Gráfico de vectores')
    plt.xlabel('TAU (%t window)')
    plt.ylabel('Error (%)')
    #plt.legend()
    #plt.grid(True)

    # Guardar el gráfico en un archivo PNG dentro del directorio 'resultados'
    plt.savefig(os.path.join('resultados', 'error_tau.png'))
    plt.close()
    
    plt.figure()
    plt.plot(lista_x,lista_tiempo_ms)# marker='o', label='Vector 1')
    #plt.title('Gráfico de vectores')
    plt.xlabel('TAU (%t window)')
    plt.ylabel('Computation time (ms)')
    #plt.legend()
    #plt.grid(True)

    # Guardar el gráfico en un archivo PNG dentro del directorio 'resultados'
    plt.savefig(os.path.join('resultados', 'tiempo_tau.png'))
    plt.close()





if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: python calcSTATUS.py <taudeal(dec)> <tauReb(HEX)> <temps(dec)>")
        sys.exit(1)
    
    tau = int(sys.argv[1])
    tauCALC = hex2float(sys.argv[2])
    N = int(sys.argv[3])
    print(f"La TAU ideal es de {tau} i la TAU calculada es de {tauCALC}")
    print(f"s'ha tardat un temps de {N/1000000}ms i l'error de tau es del {100*abs(tauCALC-tau)/tau} %")

    if(tau==1):
        with open("dadesCalcTAU.txt", 'w') as archivo:
            archivo.write(f"{tau}; {tauCALC}; {N}\n")
    elif(tau<7):#99
        with open("dadesCalcTAU.txt", 'a') as archivo:
            archivo.write(f"{tau}; {tauCALC}; {N}\n")
    else:
        with open("dadesCalcTAU.txt", 'a') as archivo:
            archivo.write(f"{tau}; {tauCALC}; {N}\n")
        plotData('dadesCalcTAU.txt')
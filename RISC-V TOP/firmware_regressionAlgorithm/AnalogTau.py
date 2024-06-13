import csv
import random as r

def escribir_numeros_csv(nombre_archivo, cantidad):
    with open(nombre_archivo, 'w', newline='') as archivo_csv:
        escritor_csv = csv.writer(archivo_csv)

        for _ in range(cantidad):
            numero = r.random()
            escritor_csv.writerow([numero])

    print(f'Se han generado {cantidad} numeros flotantes en el archivo {nombre_archivo}.')

if __name__ == "__main__":
    nombre_archivo = "DADES_AnalogTau.csv"
    cantidad_numeros = 1024  # Puedes ajustar la cantidad de números que quieres generar

    escribir_numeros_csv(nombre_archivo, cantidad_numeros)



    

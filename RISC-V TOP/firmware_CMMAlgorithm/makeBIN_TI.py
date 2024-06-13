def hex_to_binary(hex_str):
    """Convierte una cadena hexadecimal en una cadena binaria."""
    binary_str = bin(int(hex_str, 16))[2:].zfill(32)
    return int(binary_str, 2).to_bytes(4, byteorder='big')

def main(input_file, output_file):
    try:
        with open(input_file, 'r') as infile, open(output_file, 'wb') as outfile:
            for line in infile:
                hex_number = line.strip()
                binary_number = hex_to_binary(hex_number)
                outfile.write((binary_number))
        print("Archivo binario creado con éxito.")
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    input_file = "machine.hex"  # Nombre del archivo .hex de entrada
    output_file = "/mnt/c/Users/guill/OneDrive/Escriptori/codi.bin"  # Nombre del archivo binario de salida
    main(input_file, output_file)
    #print("Bin file generated")




    

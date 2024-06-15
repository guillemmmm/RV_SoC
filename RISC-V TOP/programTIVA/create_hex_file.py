def compute_checksum(data):
    """Compute the checksum for a line of Intel HEX data."""
    checksum = sum(data) & 0xFF
    checksum = ((~checksum + 1) & 0xFF)
    return checksum

def format_hex_line(length, address, record_type, data):
    """Format a single line of Intel HEX format."""
    line = [length, (address >> 8) & 0xFF, address & 0xFF, record_type] + data
    checksum = compute_checksum(line)
    line_str = ":{:02X}{:04X}{:02X}{}".format(length, address, record_type, ''.join("{:02X}".format(byte) for byte in data))
    return line_str + "{:02X}".format(checksum)

def generate_intel_hex(data_words, start_address):
    """Generate Intel HEX lines from data words starting at a given address."""
    hex_lines = []
    current_address = start_address
    extended_address = current_address >> 16

    # Add the extended linear address record
    hex_lines.append(format_hex_line(2, 0, 4, [extended_address >> 8, extended_address & 0xFF]))

    for word in data_words:
        # Convert hex string to bytes
        word_bytes = bytes.fromhex(word)
        word_bytes = word_bytes[::-1]
        hex_lines.append(format_hex_line(4, current_address & 0xFFFF, 0, list(word_bytes)))
        current_address += 4

        # Check if we need a new extended address record
        if (current_address >> 16) != extended_address:
            extended_address = current_address >> 16
            hex_lines.append(format_hex_line(2, 0, 4, [extended_address >> 8, extended_address & 0xFF]))

    # Add the end of file record
    hex_lines.append(":00000001FF")
    return hex_lines

def read_hex_words_from_file(input_file):
    """Read 32-bit hex words from a file."""
    with open(input_file, 'r') as file:
        data_words = [line.strip() for line in file if line.strip()]
    return data_words

def write_intel_hex_to_file(hex_lines, output_file):
    """Write Intel HEX lines to a file."""
    with open(output_file, 'w') as file:
        for line in hex_lines:
            file.write(line + '\n')

def main(input_file, output_file, start_address):
    # Read 32-bit hex words from the input file
    data_words = read_hex_words_from_file(input_file)

    # Generate Intel HEX lines
    hex_lines = generate_intel_hex(data_words, start_address)

    # Write the Intel HEX lines to the output file
    write_intel_hex_to_file(hex_lines, output_file)

# Example usage
input_file = 'codi.hex'      # Input file containing 32-bit words separated by newlines
output_file = '/mnt/c/Users/guill/OneDrive - Universitat de Barcelona/Electronics/LSE1/workspaceLSE/data2load.hex'    # Output Intel HEX file
start_address = 0x00020000    # Starting address

main(input_file, output_file, start_address)
    

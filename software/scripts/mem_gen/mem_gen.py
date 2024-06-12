"""
Author : Abivarman Kandiah

This script print vhdl constant from mem_init.mif files
for bram initialization.

Usage: mem_gen.py mem_init.mif
"""

import sys

if "__main__" == __name__:
    if len(sys.argv) < 2:
        print("No argument given")
        exit(1)
    
    # Create our base output
    out = "constant MEM_INIT : std_logic_vector(16383 downto 0) :=\n"

    # Read all files lines
    lines = ""
    with open(sys.argv[1]) as f:
        lines = f.readlines()
    
    # For each line
    count = 0
    for line in lines:
        data = line[:-1] # Remove \n
        
        if count == 0:
            out += "x\""
        
        out += data
        count += 1

        if count < 6:
            out += "_"
        else:
            out += "\" &\n"
            count = 0

    if out[-1] == '_':
        out = out[:-1] + "\""
    out += ";"

    print(out)
    exit(0)
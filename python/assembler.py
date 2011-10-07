import sys
import struct
from bitstring import BitArray, BitStream, pack
from opcode import makeOpcode

if len(sys.argv) < 3:
    print "Usage:", sys.argv[0], "<input file> <output file>"
    quit()

f = open(sys.argv[1],'r')
outfile = open(sys.argv[2],'w')

line = f.readline()

def interpretArgs(args):
    params = []
    for arg in args[1:]:
        argtype = arg[0].lower()
        argval = arg.strip("ra")
        params.append((argtype, argval))
    return params

while len(line) > 0:
    line = line.strip()
    print line

    args = [a.strip(", ") for a in line.split()]
    params = interpretArgs(args)
    instruction = args[0].upper()
    opcode = makeOpcode(instruction, params)

    if opcode != None:
        print opcode.bin
        outfile.write(opcode.bytes)

    
    
    line = f.readline()
outfile.close()

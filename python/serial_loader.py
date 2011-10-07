from serial import Serial
import sys, struct, argparse
from bitstring import BitArray, BitStream, pack
from opcode import makeOpcode

baudrate = 1200
INSTRUCTION_BUS = 1
DATA_BUS = 0
RW_READ = 1
RW_WRITE = 0


def createHeader(rw, diagmode, fetchreturn, bus):
	header = pack('uint:1, 0b000, uint:2, uint:1, uint:1', rw, diagmode, fetchreturn,bus)
	return header

def interpretArgs(args):
    params = []
    for arg in args[1:]:
        argtype = arg[0].lower()
        argval = arg.strip("ra")
        params.append((argtype, argval))
    return params

parser = argparse.ArgumentParser(description='Serial communication utilities for 353 FPGA project.')
parser.add_argument('-d', dest='device', help='Set serial device', required = True)
parser.add_argument('-f', dest='filename', default=None, help='Load a file into memory')
parser.add_argument('-e', dest='execute', default=None, help='Execute an instruction')
cmdargs = parser.parse_args()


#if len(sys.argv) < 3:
#	print "Usage:", sys.argv[0], "<file> <serial-port>"
#	exit()

#serial = Serial(port=sys.argv[2],baudrate=baudrate,byte=EIGHTBITS)

if cmdargs.filename != None:
	inFile = open(cmdargs.filename, 'r')
	data = inFile.read()

	if len(data) % 2 != 0:
		print "Number of bytes in binary data must be even number, have", len(data)
		exit()

	print "Writing", len(data), "data bytes"

	header = createHeader(RW_WRITE, 0, 0, DATA_BUS)

	address = 0x0
	totalbytes = 0
	intendedbytes = 0


	for byte in data:
		address += 1
		packet = header + pack('uint:16, uint:8', address, ord(byte))
		intendedbytes += len(packet.bytes)
		print packet.bytes
		#serial.write(packet.bytes)

	print "Transmitted", totalbytes, "/", intendedbytes, " bytes (including header and address data)"

if cmdargs.execute != None:
	print "Sending instruction", cmdargs.execute
	args = [a.strip(", ") for a in cmdargs.execute.split()]
	params = interpretArgs(args)
	instruction = args[0].upper()
	opcode = makeOpcode(instruction, params)

	if opcode == None:
		print "Invalid Instruction"
	else:
		print "Resolved to opcode", opcode.bin
		header = createHeader(RW_WRITE, 0, 0, INSTRUCTION_BUS)
		address = 0x0
		packet = header + pack('uint:16, uint:16', address, opcode.uint)
		print packet.bytes
		#serial.write(packet.bytes)
	

print "Serial Loader done"

#print serial

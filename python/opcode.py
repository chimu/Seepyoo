from bitstring import BitArray, BitStream, pack
'''
Makes an opcode from an instruction with params
INCOMPLETE: Missing multiple forms for MV, LD and ST (probalby more as well)

'''
def makeOpcode(instruction, params):

    opcode = None

    if instruction == "LDI":
        x = int(params[0][1])
        imm = int(params[1][1])
        opcode = pack('bin:6,uint:8, uint:2', '0b100001', imm,x)
        
    elif instruction == "LD":
        rx = int(params[0][1])
        ay = int(params[1][1])
        opcode = pack('bin:6, 0b000, uint:2, 0b00, uint:3', '0b000001', ay,rx)
        
    elif instruction == "STI":
        ay = int(params[0][1])
        imm = int(params[1][1])
        opcode = pack('bin:6, uint:8, uint:2', '0b000001', imm, ay)
        
    elif instruction == "ST":
        ay = int(params[0][1])
        rx = int(params[1][1])
        opcode = pack('bin:6, 0b000, uint:2, 0b00, uint:3', '0b000101', ay,rx)
        
    elif instruction == "MV":
        y = int(params[0][1])
        x = int(params[1][1])
        opcode = pack('bin:8,uint:3, 0b00, uint:3', '0b00010000', y,x) 

    elif instruction == "AND":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b000010', ry,rx)
        
    elif instruction == "OR":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b000110', ry,rx)
        
    elif instruction == "NOT":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b001010', ry,rx)
        
    elif instruction == "XOR":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b001110', ry,rx)
        
    elif instruction == "ADD":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b010010', ry,rx)
        
    elif instruction == "ADC":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b010110', ry,rx)

    elif instruction == "SUB":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b011010', ry,rx)
        
    elif instruction == "SBB":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b011110', ry,rx)

    elif instruction == "NEG":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b001000', ry,rx)

    elif instruction == "CMP":
        rx = int(params[0][1])
        ry = int(params[1][1])
        opcode = pack('bin:6, 0b00, uint:3, 0b00, uint:3', '0b001100', ry,rx)

    elif instruction == "BEQ":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b100011', v)

    elif instruction == "BNE":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b100111', v)
        
    elif instruction == "BLT":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b101011', v)
        
    elif instruction == "BGT":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b101111', v)
        
    elif instruction == "BC":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b110011', v)
        
    elif instruction == "BNC":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b110111', v)
        
    elif instruction == "RJMP":
        v = int(params[0][1])
        opcode = pack('bin:6, uint:8, 0b00', '0b111011', v)
        
    elif instruction == "JMP":
        ay = int(params[0][1])
        opcode = pack('bin:6, 0b000, uint:2, 0b00000', '0b011111', ay)
        
    elif instruction == "NOP":
        opcode = BitArray('0x0000')
    else:
        print "LOLWUT"

    return opcode



# Modified Harvard Architecture Microprocessor
The following is a verilog description of a simple microprocessor. The micro uses a Harvard architecture (two seperate memories for program and data memory), a 4-bit data path, and an 8-bit instruction field. 

## Overall Design
This microprocessor is made up of 5 key elements, the program sequencer, program memory, instruction decoder, computational unit, and data memory. The program memory for the microprocessor is 256 words where each word is 8 bits. The data memory is 16 words with each word being 4 bits. The program sequencer is used to control the flow of insturctions, and can accomadate both a jump and a conditional jump. The instruction decoder is fed by the program sequencer with instructions from the program memory to then control signals for the computational unit. The Computational unit, which contains the ALU, processes and carries out the instructions. The processor has 5 instruction types, a load, a move, an ALU opperation, a jump, and a conditional jump. There are a total of 9 ALU instructions, which store meaningful output in a result register.

## Instruction Set Architecture
The 5 instuction types have specific leading codes that make up the beginning portions of their opcodes. The rest of the opcode is made up of bits that define the behaviour, and source/destination registers of the instruction.

### Jump Instruction

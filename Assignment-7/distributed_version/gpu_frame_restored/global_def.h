`define ADDRLEDR 1020 // 10'h3FC
`define ADDRLEDG 1021 // 10'h3FD
`define ADDRHEX  1022 // 10'h3FE

`define BUS_WIDTH 32

`define REG_WIDTH 16
`define VREG_WIDTH 64

`define PC_WIDTH 16 
`define IR_WIDTH 32 
`define OPCODE_WIDTH 8

`define NUM_RF 16 // THE NUMBER OF REGISTERS IN SCALAR REGISTER FILE
`define NUM_VRF 64 // THE NUMBER OF REGISTERS IN VECTOR REGISTER FILE 

`define VREG_ID_WIDTH 6 
`define INST_WIDTH 32
`define DATA_WIDTH 16
`define INST_MEM_SIZE 256 // Change INST_MEM_ADDR_SIZE together 
`define DATA_MEM_SIZE 64  // Change DATA_MEM_ADDR_SIZE together 
`define INST_MEM_ADDR_SIZE 8 
`define DATA_MEM_ADDR_SIZE 6  

`define GSR_WIDTH 8
`define VERTEX_REG_WIDTH 64

`define CC_P 3'b100
`define CC_N 3'b001
`define CC_Z 3'b010 

`define MEMRW_READ_VAL 0


/////////////////////////////////////////
// OPCODE DEFINITIONS GO HERE 
/////////////////////////////////////////
//
`define OP_ADD_D            8'b00000000
`define OP_ADDI_D           8'b00000001
`define OP_ADD_F            8'b00000100
`define OP_ADDI_F           8'b00000101
`define OP_VADD             8'b00000010
`define OP_AND_D            8'b00001000
`define OP_ANDI_D           8'b00001001
`define OP_MOV              8'b00010000
`define OP_MOVI_D           8'b00010001
`define OP_MOVI_F           8'b00010101
`define OP_VMOV             8'b00010010
`define OP_VMOVI            8'b00010111
`define OP_CMP              8'b00011000
`define OP_CMPI             8'b00011001
`define OP_VCOMPMOV         8'b00100010
`define OP_VCOMPMOVI        8'b00100111
`define OP_LDB              8'b00101001
`define OP_LDW              8'b00101010
`define OP_STB              8'b00110001
`define OP_STW              8'b00110010
`define OP_SETVERTEX        8'b01000010
`define OP_SETCOLOR         8'b01001010 
`define OP_ROTATE           8'b01010010 
`define OP_TRANSLATE        8'b01011010
`define OP_SCALE            8'b01100010
`define OP_PUSHMATRIX       8'b10000000
`define OP_POPMATRIX        8'b10001000
`define OP_BEGINPRIMITIVE   8'b10010001
`define OP_ENDPRIMITIVE     8'b10011000
`define OP_LOADIDENTITY     8'b10100000
`define OP_FLUSH            8'b10110000
`define OP_DRAW             8'b10111000
`define OP_BRN              8'b11011100
`define OP_BRZ              8'b11011010
`define OP_BRP              8'b11011001
`define OP_BRNZ             8'b11011110
`define OP_BRNP             8'b11011101
`define OP_BRZP             8'b11011011
`define OP_BRNZP            8'b11011111
`define OP_JMP              8'b11100000
`define OP_RET              8'b11100000
`define OP_JSR              8'b11110000
`define OP_JSRR             8'b11111000
`define OP_HALT             8'b11100000

/////////////////////////////////////////
// GPU-RELATED DEFINITIONS GO HERE 
/////////////////////////////////////////
//
// Horizontal Parameter	(Pixel)
`define	H_SYNC_CYC   96
`define	H_SYNC_BACK  48
`define	H_SYNC_ACT   640
`define	H_SYNC_FRONT 16
`define	H_SYNC_TOTAL 800

// Virtical Parameter (Line)
`define	V_SYNC_CYC   2
`define	V_SYNC_BACK	 32
`define	V_SYNC_ACT   480
`define	V_SYNC_FRONT 11
`define	V_SYNC_TOTAL 525

// Start Offset
`define	X_START	(`H_SYNC_CYC + `H_SYNC_BACK + 4)
`define	Y_START	(`V_SYNC_CYC + `V_SYNC_BACK)

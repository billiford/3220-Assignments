#ifndef __ASSEMBLER_H
#define __ASSEMBLER_H

#include <string>

#define MAX_ARG_NUM 50
#define MAX_LINE_SIZE 1024

#define NUM_SCALAR_REGISTER 16
#define NUM_VECTOR_REGISTER 64

#define NUM_OPS 44

struct OpTableProperties {
  std::string mnemonic;
  int opcode;
};

enum OpCodes {
  OP_ADD_D = 0,
  OP_ADDI_D = 1,
  OP_ADD_F = 4,
  OP_ADDI_F = 5,
  OP_VADD = 2,
  OP_AND_D = 8,
  OP_ANDI_D = 9,
  OP_MOV = 16,
  OP_MOVI_D = 17,
  OP_MOVI_F = 21,
  OP_VMOV = 18,
  OP_VMOVI = 23,
  OP_CMP = 24,
  OP_CMPI = 25,
  OP_VCOMPMOV = 34,
  OP_VCOMPMOVI = 39,
  OP_LDB = 41,
  OP_LDW = 42,
  OP_STB = 49,
  OP_STW = 50,
  OP_SETVERTEX = 66,
  OP_SETCOLOR = 74,
  OP_ROTATE = 82,
  OP_TRANSLATE = 90,
  OP_SCALE = 98,
  OP_PUSHMATRIX = 128,
  OP_POPMATRIX = 136,
  OP_BEGINPRIMITIVE = 145,
  OP_ENDPRIMITIVE = 152,
  OP_LOADIDENTITY = 160,
  OP_FLUSH = 176,
  OP_DRAW = 184,
  OP_BRN = 220,
  OP_BRZ = 218,
  OP_BRP = 217,
  OP_BRNZ = 222,
  OP_BRNP = 221,
  OP_BRZP = 219,
  OP_BRNZP = 223,
  OP_JMP = 224,
  OP_RET = 224,
  OP_JSR = 240,
  OP_JSRR = 248,
  OP_HALT = 192,  
};

#endif // __ASSEMBLER_H

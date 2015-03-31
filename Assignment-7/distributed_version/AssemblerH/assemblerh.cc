#include <iostream>
#include <bitset>
#include <string>
#include <fstream>
#include <sstream>
#include <stdint.h>
#include <cstring>
#include <limits.h>
#include <iomanip>
#include "assembler.h"
using namespace std;

const char *g_scalar_register_names[NUM_SCALAR_REGISTER] = {
  "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"
};

const char *g_vector_register_names[NUM_VECTOR_REGISTER] = {
  "v0",   "v1",   "v2",   "v3",   "v4",   "v5",   "v6",   "v7",   "v8",   "v9",   "v10",  "v11",  "v12",  "v13",  "v14",  "v15",
  "v16",  "v17",  "v18",  "v19",  "v20",  "v21",  "v22",  "v23",  "v24",  "v25",  "v26",  "v27",  "v28",  "v29",  "v30",  "v31",
  "v32",  "v33",  "v34",  "v35",  "v36",  "v37",  "v38",  "v39",  "v40",  "v41",  "v42",  "v43",  "v44",  "v45",  "v46",  "v47",
  "v48",  "v49",  "v50",  "v51",  "v52",  "v53",  "v54",  "v55",  "v56",  "v57",  "v58",  "v59",  "v60",  "v61",  "v62",  "v63"
};

struct OpTableProperties g_op_tables[NUM_OPS] = {
  {"add.d",            OP_ADD_D          }, 
  {"addi.d",           OP_ADDI_D         },
  {"add.f",            OP_ADD_F          },
  {"addi.f",           OP_ADDI_F         },
  {"vadd",             OP_VADD           },
  {"and.d",            OP_AND_D          }, 
  {"andi.d",           OP_ANDI_D         },
  {"mov",              OP_MOV            },
  {"movi.d",           OP_MOVI_D         },
  {"movi.f",           OP_MOVI_F         },
  {"vmov",             OP_VMOV           },
  {"vmovi",            OP_VMOVI          },
  {"cmp",              OP_CMP            },
  {"cmpi",             OP_CMPI           },
  {"vcompmov",         OP_VCOMPMOV       },
  {"vcompmovi",        OP_VCOMPMOVI      },
  {"ldb",              OP_LDB            },
  {"ldw",              OP_LDW            },
  {"stb",              OP_STB            },
  {"stw",              OP_STW            },
  {"setvertex",        OP_SETVERTEX      },
  {"setcolor",         OP_SETCOLOR       },
  {"rotate",           OP_ROTATE         },
  {"translate",        OP_TRANSLATE      },
  {"scale",            OP_SCALE          },
  {"pushmatrix",       OP_PUSHMATRIX     },
  {"popmatrix",        OP_POPMATRIX      },
  {"beginprimitive",   OP_BEGINPRIMITIVE },
  {"endprimitive",     OP_ENDPRIMITIVE   },
  {"loadidentity",     OP_LOADIDENTITY   },
  {"flush",            OP_FLUSH          },
  {"draw",             OP_DRAW           },
  {"brn",              OP_BRN            },
  {"brz",              OP_BRZ            },
  {"brp",              OP_BRP            },
  {"brnz",             OP_BRNZ           },
  {"brnp",             OP_BRNP           },
  {"brzp",             OP_BRZP           },
  {"brnzp",            OP_BRNZP          },
  {"jmp",              OP_JMP            },
  {"ret",              OP_RET            },
  {"jsr",              OP_JSR            },
  {"jsrr",             OP_JSRR           },
  {"halt",             OP_HALT           }, 
};
		  
static int GetOpcode(string str) 
{
	for (int i=0; i < NUM_OPS; i++) 
    if (str.compare(g_op_tables[i].mnemonic) == 0)
      return g_op_tables[i].opcode;
	
  return -1;
}

static int GetScalarRegisterIdx(string str)
{
	for (int i = 0; i < NUM_SCALAR_REGISTER; i++) 
    if (str.compare(g_scalar_register_names[i]) == 0)
      return i;

	return -1;
}

static int GetVectorRegisterIdx(string str) 
{
	for (int i = 0; i < NUM_VECTOR_REGISTER; i++) 
    if (str.compare(g_vector_register_names[i]) == 0)
      return i;

	return -1;
}

#define FLOAT_TO_FIXED187(n) ((int)((n) * (float)(1<<(7)))) & 0xffff
#define FIXED_TO_FLOAT187(n) ((float)(-1*((n>>15)&0x1)*(1<<8)) + (float)((n&(0x7fff)) / (float)(1<<7)))
#define FLOAT_TO_FIXED1114(n) ((int)((n) * (float)(1<<(4)))) & 0xffff
#define FIXED_TO_FLOAT1114(n) ((float)(-1*((n>>15)&0x1)*(1<<11)) + (float)((n&(0x7fff)) / (float)(1<<4)))
static uint16_t EncodeFloatingPointNumberToBinary(float value)
{
  // return (uint16_t)FLOAT_TO_FIXED187(value);
  return (uint16_t)FLOAT_TO_FIXED1114(value);
}

#if 0 
static uint16_t EncodeFloatingPointNumberToBinary(float value)
{
  static const uint16_t base_table[512] = { 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100, 
    0x0200, 0x0400, 0x0800, 0x0C00, 0x1000, 0x1400, 0x1800, 0x1C00, 0x2000, 0x2400, 0x2800, 0x2C00, 0x3000, 0x3400, 0x3800, 0x3C00, 
    0x4000, 0x4400, 0x4800, 0x4C00, 0x5000, 0x5400, 0x5800, 0x5C00, 0x6000, 0x6400, 0x6800, 0x6C00, 0x7000, 0x7400, 0x7800, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 0x7C00, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 
    0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8001, 0x8002, 0x8004, 0x8008, 0x8010, 0x8020, 0x8040, 0x8080, 0x8100, 
    0x8200, 0x8400, 0x8800, 0x8C00, 0x9000, 0x9400, 0x9800, 0x9C00, 0xA000, 0xA400, 0xA800, 0xAC00, 0xB000, 0xB400, 0xB800, 0xBC00, 
    0xC000, 0xC400, 0xC800, 0xCC00, 0xD000, 0xD400, 0xD800, 0xDC00, 0xE000, 0xE400, 0xE800, 0xEC00, 0xF000, 0xF400, 0xF800, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 
    0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00, 0xFC00 };
  static const unsigned char shift_table[512] = { 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 
    13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 13, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 
    13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 13 };

  uint32_t bits;
  memcpy(&bits, &value, sizeof(float));
  uint16_t hbits = base_table[bits>>23] + ((bits&0x7FFFFF)>>shift_table[bits>>23]);

#define FLOAT_ROUND_STYLE ROUND_TO_NEAREST
#if (FLOAT_ROUND_STYLE == ROUND_TO_NEAREST)
    hbits += (((bits&0x7FFFFF)>>(shift_table[bits>>23]-1))|(((bits>>23)&0xFF)==102)) & ((hbits&0x7C00)!=0x7C00);
#elif (FLOAT_ROUND_STYLE == ROUND_TOWARD_ZERO)
    hbits -= ((hbits&0x7FFF)==0x7C00) & ~shift_table[bits>>23];
#elif (FLOAT_ROUND_STYLE == ROUND_TOWARD_INFINITY)
    hbits += ((((bits&0x7FFFFF&((static_cast<uint32>(1)<<(shift_table[bits>>23]))-1))!=0)|(((bits>>23)<=102)&
             ((bits>>23)!=0)))&(hbits<0x7C00)) - ((hbits==0xFC00)&((bits>>23)!=511));
#elif (FLOAT_ROUND_STYLE == ROUND_TOWARD_NEG_INFINITY)
    hbits += ((((bits&0x7FFFFF&((static_cast<uint32>(1)<<(shift_table[bits>>23]))-1))!=0)|(((bits>>23)<=358)&
             ((bits>>23)!=256)))&(hbits<0xFC00)&(hbits>>15)) - ((hbits==0x7C00)&((bits>>23)!=255));
#endif // FLOAT_ROUND_STYLE
  
  return hbits;
}
#endif 


int main(int argc, char** argv) 
{
  if (argc != 3) {
    cerr << "Usage: " << argv[0] << " <input> <output>" << endl; 
    return 1;
  }

  ifstream infile(argv[1]);
  ofstream outfile(argv[2]);

  if (!infile) {
    cerr << "Error: Failed to open input file " << argv[1] << endl;
    return 1;
  }

  if (!outfile) {
    cerr << "ERROR: Failed to open output file " << argv[2] << endl;
    return 1;
  }

  char buffer[MAX_LINE_SIZE] = {0,};
  string tokens[MAX_ARG_NUM];
  while (infile.getline(buffer, sizeof(buffer)))
  {
    // Some text editors tend to insert null, newline or end-of-file character at the end.
    // This should not be parsed otherwise it will emit invalid opcode error message.
    if (buffer[0] == (char)NULL || buffer[0] == EOF || buffer[0] == '\n')
      break;

    istringstream istr(string(buffer), ios_base::out);

    for (int trav = 0; trav < MAX_ARG_NUM; trav++)
      if (!(istr >> tokens[trav]))
        break;

    uint32_t instruction = 0;
    int opcode = GetOpcode(tokens[0]);
    if (opcode == -1) {
      cerr << "Error: invalid opcode " << tokens[0] << endl; 
      infile.close();
      outfile.close();
      return 1;
    }

    instruction = opcode << 24;	

    int integer_value;
    float float_value;

    switch (opcode)
    {
      case OP_ADD_D:
      case OP_ADD_F:
      case OP_AND_D:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<20)&0x00F00000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[2])<<16)&0x000F0000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[3])<< 8)&0x00000F00);
        break;

      case OP_ADDI_D:
      case OP_ANDI_D:
      case OP_LDB:
      case OP_LDW:
      case OP_STB:
      case OP_STW:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<20)&0x00F00000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[2])<<16)&0x000F0000);
        istringstream(tokens[3]) >> integer_value;
        instruction = instruction | (((int16_t)integer_value)&0x0000FFFF);
        break;

      case OP_ADDI_F:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<20)&0x00F00000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[2])<<16)&0x000F0000);
        istringstream(tokens[3]) >> float_value;
        instruction = instruction | (EncodeFloatingPointNumberToBinary(float_value)&0x0000FFFF);
        break;

      case OP_VADD:
        instruction = instruction | ((GetVectorRegisterIdx(tokens[1])<<16)&0x003F0000);
        instruction = instruction | ((GetVectorRegisterIdx(tokens[2])<< 8)&0x00003F00);
        instruction = instruction | ((GetVectorRegisterIdx(tokens[3])    )&0x0000003F);
        break;

      case OP_MOV:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<16)&0x000F0000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[2])<< 8)&0x00000F00);
        break;

      case OP_MOVI_D:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<16)&0x000F0000);
        istringstream(tokens[2]) >> integer_value;
        instruction = instruction | (((int16_t)integer_value)&0x0000FFFF);
        break;

      case OP_MOVI_F:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<16)&0x000F0000);
        istringstream(tokens[2]) >> float_value;
        instruction = instruction | (EncodeFloatingPointNumberToBinary(float_value)&0x0000FFFF);
        break;

      case OP_VMOV:
        instruction = instruction | ((GetVectorRegisterIdx(tokens[1])<<16)&0x003F0000);
        instruction = instruction | ((GetVectorRegisterIdx(tokens[2])<< 8)&0x00003F00);
        break;

      case OP_VMOVI:
        instruction = instruction | ((GetVectorRegisterIdx(tokens[1])<<16)&0x003F0000);
        istringstream(tokens[2]) >> float_value;
        instruction = instruction | (EncodeFloatingPointNumberToBinary(float_value)&0x0000FFFF);
        break;

      case OP_CMP:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<16)&0x000F0000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[2])<< 8)&0x00000F00);
        break;

      case OP_CMPI:
        instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<16)&0x000F0000);
        istringstream(tokens[2]) >> integer_value;
        instruction = instruction | (((int16_t)integer_value)&0x0000FFFF);
        break;

      case OP_VCOMPMOV:
        instruction = instruction | ((GetVectorRegisterIdx(tokens[1])<<16)&0x003F0000);
        istringstream(tokens[2]) >> integer_value;
        instruction = instruction | ((integer_value<<22)&0x00C00000);
        instruction = instruction | ((GetScalarRegisterIdx(tokens[3])<< 8)&0x00000F00);
        break;

      case OP_VCOMPMOVI:
        instruction = instruction | ((GetVectorRegisterIdx(tokens[1])<<16)&0x003F0000);
        istringstream(tokens[2]) >> integer_value;
        instruction = instruction | ((integer_value<<22)&0x00C00000);
        istringstream(tokens[3]) >> float_value;
        instruction = instruction | (EncodeFloatingPointNumberToBinary(float_value)&0x0000FFFF);
        break;

      case OP_PUSHMATRIX:
      case OP_POPMATRIX:
      case OP_ENDPRIMITIVE:
      case OP_LOADIDENTITY:
      case OP_FLUSH:
      case OP_DRAW:
      case OP_HALT: 
        // Do nothing
        break;

      case OP_BEGINPRIMITIVE:
        istringstream(tokens[1]) >> integer_value;
        instruction = instruction | ((integer_value<<16)&0x000F0000);
        break;

      case OP_JSR:
        istringstream(tokens[1]) >> integer_value;
        instruction = instruction | ((integer_value)&0x0000FFFF);
        break;

      case OP_JMP:
      //case OP_RET:
      case OP_JSRR:
        if (tokens[0].compare("ret") == 0)
          instruction = instruction | ((0x07<<16)&0x000F0000);
        else
          instruction = instruction | ((GetScalarRegisterIdx(tokens[1])<<16)&0x000F0000);
        break;

      case OP_SETVERTEX:
      case OP_SETCOLOR:
      case OP_ROTATE:
      case OP_TRANSLATE:
      case OP_SCALE:
        instruction = instruction | ((GetVectorRegisterIdx(tokens[1])<<16)&0x003F0000);
        break;

      case OP_BRN:
      case OP_BRZ:
      case OP_BRP:
      case OP_BRNZ:
      case OP_BRNP:
      case OP_BRZP:
      case OP_BRNZP:
        istringstream(tokens[1]) >> integer_value;
        instruction = instruction | (((int16_t)integer_value)&0x0000FFFF);
        break;

      default:
        break;
    }

   //    bitset<sizeof(uint32_t)*CHAR_BIT> bits(instruction);
   //    outfile << bits;
 outfile << setfill ('0') << setw(8) << hex << instruction << endl; 
  }

  infile.close();
  outfile.close();

  return 0;
}

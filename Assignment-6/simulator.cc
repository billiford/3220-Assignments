#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <bitset>
#include <stdint.h>
#include <string.h> 
#include <cstring> 
#include <limits.h> 
// #include <cstdint> 
#include "simulator.h"


#define FLOAT_TO_FIXED1114(n) ((int)((n) * (float)(1<<(4)))) & 0xffff
#define FIXED_TO_FLOAT1114(n) ((float)(-1*((n>>15)&0x1)*(1<<11)) + (float)((n&(0x7fff)) / (float)(1<<4)))
#define FIXED1114_TO_INT(n) (( (n>>15)&0x1) ?  ((n>>4)|0xf000) : (n>>4)) 
#define DEBUG

using namespace std;

///////////////////////////////////
///  architectural structures /// 
///////////////////////////////////


ScalarRegister g_condition_code_register; // store conditional code 
ScalarRegister g_scalar_registers[NUM_SCALAR_REGISTER];  
VectorRegister g_vector_registers[NUM_VECTOR_REGISTER];

VertexRegister g_gpu_vertex_registers[NUM_VERTEX_REGISTER]; 
ScalarRegister g_gpu_status_register; 
 
unsigned char g_memory[MEMORY_SIZE]; // data memory 

////////////////////////////////////

vector<TraceOp> g_trace_ops;

unsigned int g_instruction_count = 0;
unsigned int g_vertex_id = 0; 
unsigned int g_current_pc = 0; 
unsigned int g_program_halt = 0; 

////////////////////////////////////////////////////////////////////////
// desc: Set g_condition_code_register depending on the values of val1 and val2
// hint: bit0 (N) is set only when val1 < val2
// bit 2: negative 
// bit 1: zero
// bit 0: positive 
////////////////////////////////////////////////////////////////////////
void SetConditionCodeInt(const int16_t val1, const int16_t val2) 
{
  //is the hint above wrong?
  if(val1 == val2) g_condition_code_register.int_value = 2; //010
  else if (val1 > val2) g_condition_code_register.int_value = 1; //001
  else g_condition_code_register.int_value = 4; //100
}


////////////////////////////////////////////////////////////////////////
// Initialize global variables
////////////////////////////////////////////////////////////////////////
void InitializeGlobalVariables() 
{
  g_vertex_id = 0;  // internal setting variables 
  memset(&g_condition_code_register, 0x00, sizeof(ScalarRegister));
  memset(&g_gpu_status_register, 0x00, sizeof(ScalarRegister));
  memset(g_scalar_registers, 0x00, sizeof(ScalarRegister) * NUM_SCALAR_REGISTER);
  memset(g_vector_registers, 0x00, sizeof(VectorRegister) * NUM_VECTOR_REGISTER);
  memset(g_gpu_vertex_registers, 0x00, sizeof(VertexRegister) * NUM_VERTEX_REGISTER);
  memset(g_memory, 0x00, sizeof(unsigned char) * MEMORY_SIZE);
}

////////////////////////////////////////////////////////////////////////
// desc: Convert 16-bit 2's complement signed integer to 32-bit
////////////////////////////////////////////////////////////////////////
int SignExtension(const int16_t value) 
{
  return (value >> 15) == 0 ? value : ((0xFFFF << 16) | value);
}



////////////////////////////////////////////////////////////////////////
// desc: Decode binary-encoded instruction and Parse into TraceOp structure
//       which we will use execute later
// input: 32-bit encoded instruction
// output: TraceOp structure filled with the information provided from the input
////////////////////////////////////////////////////////////////////////
TraceOp DecodeInstruction(const uint32_t instruction) 
{
  TraceOp ret_trace_op;
  memset(&ret_trace_op, 0x00, sizeof(ret_trace_op));

  uint8_t opcode = (instruction & 0xFF000000) >> 24;
  ret_trace_op.opcode = opcode;

  switch (opcode) {
    
   
   
   case OP_ADD_D: 
    {
      int destination_register_idx = (instruction & 0x00F00000) >> 20;
      int source_register_1_idx = (instruction & 0x000F0000) >> 16;
      int source_register_2_idx = (instruction & 0x00000F00) >> 8;
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.scalar_registers[2] = source_register_2_idx;
    }
    break;
    
    /* fill out all the instruction's decode information */ 

    case OP_ADD_F:  
    {
      int destination_register_idx = (instruction & 0x00F00000) >> 20;
      int source_register_1_idx = (instruction & 0x000F0000) >> 16;
      int source_register_2_idx = (instruction & 0x00000F00) >> 8; 
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.scalar_registers[2] = source_register_2_idx;
    }
    break;
    case OP_ADDI_D:
    {
      int destination_register_idx = (instruction & 0x00F00000) >> 20;
      int source_register_1_idx = (instruction & 0x000F0000) >> 16;
      int source_imm = (instruction & 0x0000FFFF); //This should be the last 16 bits to int?
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.int_value = source_imm;   
    }
    break;
    case OP_ADDI_F: 
    {
      int destination_register_idx = (instruction & 0x00F00000) >> 20;
      int source_register_1_idx = (instruction & 0x000F0000) >> 16;
	  int imm = instruction & 0x00008000 ? instruction & 0x0000FFFF - 65536 : instruction & 0x0000FFFF; //SIGNED CHECK
      float source_imm = FIXED_TO_FLOAT1114(imm); //This should be the last 16 bits to float? Not sure if it casts it as is or if we have to use the convert function
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.float_value = source_imm;     
    }    
    break;
    case OP_VADD:
    {
      int destination_register_idx = (instruction & 0x003F0000) >> 16;
      int source_register_1_idx = (instruction & 0x00003F00) >> 8;
      int source_register_2_idx = (instruction & 0x0000003F);
      ret_trace_op.vector_registers[0] = destination_register_idx;
      ret_trace_op.vector_registers[1] = source_register_1_idx;
      ret_trace_op.vector_registers[2] = source_register_2_idx;
    }    
    break;
    case OP_AND_D:
    { //Same as ADD_D
      int destination_register_idx = (instruction & 0x00F00000) >> 20;
      int source_register_1_idx = (instruction & 0x000F0000) >> 16;
      int source_register_2_idx = (instruction & 0x00000F00) >> 8;
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.scalar_registers[2] = source_register_2_idx;      
    }    
    break;
    case OP_ANDI_D:
    { //Same as ADDI_D
      int destination_register_idx = (instruction & 0x00F00000) >> 20;
      int source_register_1_idx = (instruction & 0x000F0000) >> 16;
      int source_imm = (instruction & 0x0000FFFF); //This should be the last 16 bits to int?
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.int_value = source_imm;       
    }
    break;
    case OP_MOV: 
    {
      int destination_register_idx = (instruction & 0x000F0000) >> 16;
      int source_register_1_idx = (instruction & 0x00000F00) >> 8; //Bits 8-11 inclusive
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
    }    
    break;
    case OP_MOVI_D:
    {
      int destination_register_idx = (instruction & 0x000F0000) >> 16;
      int source_imm = (instruction & 0x0000FFFF); //bits 0-15 inclusive
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.int_value = source_imm;    
    }    
    break;
    case OP_MOVI_F: 
    {
      int destination_register_idx = (instruction & 0x000F0000) >> 16;
	  int imm = instruction & 0x00008000 ? instruction & 0x0000FFFF - 65536 : instruction & 0x0000FFFF; //SIGNED CHECK
      float source_imm = FIXED_TO_FLOAT1114(imm); //bits 0-15 inclusive
      ret_trace_op.scalar_registers[0] = destination_register_idx;
      ret_trace_op.float_value = source_imm;       
    }  
    break;  
    case OP_VMOV:  
    {
      int destination_register_idx = (instruction & 0x0003F000) >> 8; //Bits 16-21
      int source_register_1_idx = (instruction & 0x00003F00) >> 8; //Bits 8-13
      ret_trace_op.vector_registers[0] = destination_register_idx;
      ret_trace_op.vector_registers[1] = source_register_1_idx;      
    }  
    break;  
    case OP_VMOVI: 
    {
      int destination_register_idx = (instruction & 0x0003F000) >> 8; //Bits 16-21
      float source_imm = FIXED_TO_FLOAT1114(instruction & 0x0000FFFF); //Bits 0-15
      ret_trace_op.vector_registers[0] = destination_register_idx;
      ret_trace_op.float_value = source_imm;
    }  
    break;  
    case OP_CMP: 
    {
      int source_register_1_idx = (instruction & 0x000F0000) >> 16; //Bits 16-19
      int source_register_2_idx = (instruction & 0x00000F00) >> 8; //Bits 8-11
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.scalar_registers[2] = source_register_2_idx; 
    }    
    break;
    case OP_CMPI:
    {
      int source_register_1_idx = (instruction & 0x000F0000) >> 16; //Bits 16-19
      int source_imm = (instruction & 0x00000FFF); //Bits 8-11
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.int_value = source_imm;
    }    
    break;
    case OP_VCOMPMOV: 
    { // vector reg dest[idx] <- scalar src register
      int destination_register_idx = (instruction & 0x0003F000) >> 12;
      int source_register_1_idx = (instruction & 0x00000F00) >> 8;
      int idx = (instruction & 0x00A00000) >> 20;
      ret_trace_op.vector_registers[0] = destination_register_idx;
      ret_trace_op.scalar_registers[1] = source_register_1_idx;
      ret_trace_op.idx = idx; 
    }    
    break;
    case OP_VCOMPMOVI:  
    {
      int destination_register_idx = (instruction & 0x0003F000) >> 12;
      int source_imm = FIXED_TO_FLOAT1114(instruction & 0x0000FFFF);
      int idx = (instruction & 0x00A00000) >> 20;
      ret_trace_op.vector_registers[0] = destination_register_idx;
      ret_trace_op.float_value = source_imm;
      ret_trace_op.idx = idx;
    }    
    break;
    case OP_LDB: 
    {
      int destination_register_idx = (instruction & 0x00F00000) >> 20; //Bits 20-23
      int base_register = (instruction & 0x000F0000) >> 16; //Bits 16-19
      int offset_imm = (instruction & 0x0000FFFF); //Bits 0-15
      ret_trace_op.scalar_registers[0] = destination_register_idx;     
      ret_trace_op.scalar_registers[1] = base_register;        
      ret_trace_op.int_value = offset_imm;  
    }   
    break; 
    case OP_LDW:
    { //same as LDB
      int destination_register_idx = (instruction & 0x00F00000) >> 20; //Bits 20-23
      int base_register = (instruction & 0x000F0000) >> 16; //Bits 16-19
      int offset_imm = (instruction & 0x0000FFFF); //Bits 0-15
      ret_trace_op.scalar_registers[0] = destination_register_idx;     
      ret_trace_op.scalar_registers[1] = base_register;        
      ret_trace_op.int_value = offset_imm;  
    }  
    break;  
    case OP_STB:  
    { //same as LDB
      int source_register_idx = (instruction & 0x00F00000) >> 20; //Bits 20-23
      int base_register = (instruction & 0x000F0000) >> 16; //Bits 16-19
      int offset_imm = (instruction & 0x0000FFFF); //Bits 0-15
      ret_trace_op.scalar_registers[0] = source_register_idx;     
      ret_trace_op.scalar_registers[1] = base_register;        
      ret_trace_op.int_value = offset_imm;        
    }    
    break;
    case OP_STW: 
    { //same as LDB
      int source_register_idx = (instruction & 0x00F00000) >> 20; //Bits 20-23
      int base_register = (instruction & 0x000F0000) >> 16; //Bits 16-19
      int offset_imm = (instruction & 0x0000FFFF); //Bits 0-15
      ret_trace_op.scalar_registers[0] = source_register_idx;     
      ret_trace_op.scalar_registers[1] = base_register;        
      ret_trace_op.int_value = offset_imm;  
    }   
    break; 
    case OP_SETVERTEX: 
    {
      int destination_register_idx = (instruction & 0x003F0000) >> 20; //Bits 16-21
      ret_trace_op.vector_registers[0] = destination_register_idx;
    }    
    break;
    case OP_SETCOLOR:
    { // same as SETVERTEX
      int destination_register_idx = (instruction & 0x003F0000) >> 20; //Bits 16-21
      ret_trace_op.vector_registers[0] = destination_register_idx;
    }    
    break;
    case OP_ROTATE:  // optional 
    { //same as SETVERTEX
      int destination_register_idx = (instruction & 0x003F0000) >> 20; //Bits 16-21
      ret_trace_op.vector_registers[0] = destination_register_idx;      
    }    
    break;
    case OP_TRANSLATE: 
    { //same as SETVERTEX
      int destination_register_idx = (instruction & 0x003F0000) >> 20; //Bits 16-21
      ret_trace_op.vector_registers[0] = destination_register_idx;
    }    
    break;
    case OP_SCALE:  // optional 
    { //same as SETVERTEX
      int destination_register_idx = (instruction & 0x003F0000) >> 20; //Bits 16-21
      ret_trace_op.vector_registers[0] = destination_register_idx;
    }   
    break; 
    case OP_PUSHMATRIX:       // deprecated 
    {
      
    }    
    break;
    case OP_POPMATRIX:   // deprecated 
    {
      
    }  
    break;  
    case OP_BEGINPRIMITIVE: 
    {
      int destination_register_idx = (instruction & 0x000F0000) >> 20; //Bits 16-19
      ret_trace_op.primitive_type = destination_register_idx;
    }    
    break;
    case OP_ENDPRIMITIVE: //according to update this is deprecated
    {
      //Doesn't take any arguments
    }  
    break;  
    case OP_LOADIDENTITY:  // deprecated 
    {
      
    }    
    break;
    case OP_FLUSH: 
    {
      //Doesn't take any arguments
      //Flushes frame buffer
    }    
    break;
    case OP_DRAW: 
    {
      //Doesn't take any arguments
      //Draws frame buffer to screen
    }    
    break;
    case OP_BRN: 
    { //All branch comparisons take same format
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;
    }   
    break; 
    case OP_BRZ:
    {
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;      
    }    
    break;
    case OP_BRP:
    {
      int pc_offset = (instruction & 0x0000FFFF);
	  if (pc_offset & 0x00008000) pc_offset -= 65536; 
      ret_trace_op.int_value = pc_offset;      
    }    
    break;
    case OP_BRNZ:
    {
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;      
    }    
    break;
    case OP_BRNP:
    {
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;      
    }    
    break;
    case OP_BRZP:
    {
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;      
    }    
    break;
    case OP_BRNZP:
    {
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;      
    }    
    break;
    case OP_JMP:
    {
      int base_register_idx = (instruction & 0x000F0000) >> 20; //Bits 16-19
      ret_trace_op.int_value = base_register_idx;      
    }    
    break;
    case OP_JSR: 
    {
      int pc_offset = (instruction & 0x0000FFFF);
      ret_trace_op.int_value = pc_offset;         
    }    
    break;
    case OP_JSRR: 
    {
      int base_register_idx = (instruction & 0x000F0000) >> 20; //Bits 16-19
      ret_trace_op.int_value = base_register_idx;        
    }    
    break;
    case OP_HALT: 
    {
      // X = R0, Y = R0, Z = R0, imm = R0. If we can't figure out a nop from this, we might as well drop out
      ret_trace_op.int_value = 0;
      ret_trace_op.scalar_registers[0] = 0;
      ret_trace_op.scalar_registers[1] = 0;
      ret_trace_op.scalar_registers[2] = 0;
    }     
      break; 

    default:
    break;
  }

  return ret_trace_op;
}

////////////////////////////////////////////////////////////////////////
// desc: Execute the behavior of the instruction (Simulate)
// input: Instruction to execute 
// output: Non-branch operation ? -1 : OTHER (PC-relative or absolute address)
////////////////////////////////////////////////////////////////////////
int ExecuteInstruction(const TraceOp &trace_op) 
{
  int ret_next_instruction_idx = -1;

  uint8_t opcode = trace_op.opcode;
  switch (opcode) {
    case OP_ADD_D: 
      {
      int source_value_1 = g_scalar_registers[trace_op.scalar_registers[1]].int_value;
      int source_value_2 = g_scalar_registers[trace_op.scalar_registers[2]].int_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        source_value_1 + source_value_2;
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }
    break;


    /* fill out instruction behaviors */ 
    /* It seems to me that float registers should have their contents converted to float upon retreival. 
     * However, it seems like the float immediates that I've already converted above can be accessed via float_value
     * This is because of how this simulator works. g_scalar_registers contains the register contents, indexed by the int register index from
     * trace_op.scalar_registers[index]. The simulator automatically fills the int_value field of the scalar register, so we can't have a float_value field
     * here. So upon retreival of an int value from an fp register on a float operation, we should convert the value using FIXED_TO_FLOAT1114. ????
     * TLDR: g_scalar_register[Register Number] - contents of the scalar registers. ONLY HAS A int_value field
     * trace_op - current operation struct that we fill in with regnos, imm values, idx, etc. */
    case OP_ADD_F:
    {
      float source_value_1 = FIXED_TO_FLOAT1114(g_scalar_registers[trace_op.scalar_registers[1]].int_value);
      float source_value_2 = FIXED_TO_FLOAT1114(g_scalar_registers[trace_op.scalar_registers[2]].int_value);
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        FLOAT_TO_FIXED1114(source_value_1 + source_value_2);
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_ADDI_D:
    {
      int source_value_1 = 
			g_scalar_registers[trace_op.scalar_registers[1]].int_value;
      int source_immediate = trace_op.int_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        source_value_1 + source_immediate;
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_ADDI_F: 
    {
      int source_value_1 = 
			g_scalar_registers[trace_op.scalar_registers[1]].int_value;
      float source_immediate = trace_op.float_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        FLOAT_TO_FIXED1114(source_value_1 + source_immediate); //C++ implicit type conversion. Float + anything = Float
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_VADD:
    {
      for (int i = 0; i < 4; i++) {
		  //need to do something with vector regs
	  }
		  
    }  
    break;
    case OP_AND_D:
    {
      int source_value_1 = g_scalar_registers[trace_op.scalar_registers[1]].int_value;
      int source_value_2 = g_scalar_registers[trace_op.scalar_registers[2]].int_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        source_value_1 & source_value_2;
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_ANDI_D:
    {
      int source_value_1 = g_scalar_registers[trace_op.scalar_registers[1]].int_value;
      int source_immediate = trace_op.int_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        source_value_1 & source_immediate;
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_MOV: 
    { // Just add 0 to the register and put it in destination. Alternatively, we could AND 0xFFFFFFFF
      int source_value_1 = g_scalar_registers[trace_op.scalar_registers[1]].int_value;
      int mov_immediate = 0;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        source_value_1 + mov_immediate;
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_MOVI_D:
    { //iffy
      int mov_immediate = trace_op.int_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = mov_immediate;
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_MOVI_F: 
    {
      float mov_immediate = trace_op.float_value;
      g_scalar_registers[trace_op.scalar_registers[0]].int_value = 
        FLOAT_TO_FIXED1114(mov_immediate);
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[0]].int_value, 0);
    }  
    break;
    case OP_VMOV:  
    {
		//is this correct? not sure what they want us to do from the slides
		VectorRegister dest = g_vector_registers[trace_op.vector_registers[0]];
		VectorRegister src = g_vector_registers[trace_op.vector_registers[1]];
		//dest = src;
    }  
    break;
    case OP_VMOVI: 
    {
		for (int idx = 0; idx < NUM_VECTOR_ELEMENTS; idx++) {
			//more vector stuff
		}
    }  
    break;
    case OP_CMP: 
    {
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[1]].int_value, 
        g_scalar_registers[trace_op.scalar_registers[2]].int_value);
    }  
    break;
    case OP_CMPI:
    {
      SetConditionCodeInt(g_scalar_registers[trace_op.scalar_registers[1]].int_value, 
        trace_op.int_value);
    }  
    break;
    case OP_VCOMPMOV: 
    {

    }  
    break;
    case OP_VCOMPMOVI:
    {

    }  
    break;  
    case OP_LDB: 
    {
		//Set the destinations int_value to be the unsigned char found in memory
		ScalarRegister dest = g_scalar_registers[trace_op.scalar_registers[0]];
		ScalarRegister base = g_scalar_registers[trace_op.scalar_registers[1]];
		int offset = trace_op.int_value;
		unsigned char byte = g_memory[base.int_value + offset];
		dest.int_value = byte;
		//TODO what to compare to set the conditional code?
		//SetConditionCodeInt();
    }  
    break;
    case OP_LDW:
    {
		//Set the destinations int_value to be the unsigned word found in memory
		ScalarRegister dest = g_scalar_registers[trace_op.scalar_registers[0]];
		ScalarRegister base = g_scalar_registers[trace_op.scalar_registers[1]];
		int offset = trace_op.int_value;
		unsigned char byte2 = g_memory[base.int_value + offset + 1];
		unsigned char byte1 = g_memory[base.int_value + offset];
		int word = (byte2 << 8) | byte1;
		dest.int_value = word;
		//TODO what to compare to set the conditional code?
		//SetConditionCodeInt();
    }  
    break;
    case OP_STB: 
    {
		//Store a byte at memory address base + offset
		ScalarRegister src = g_scalar_registers[trace_op.scalar_registers[0]];
		ScalarRegister base = g_scalar_registers[trace_op.scalar_registers[1]];
		int offset = trace_op.int_value;
		g_memory[base.int_value + offset] = src.int_value & 0x00FF;
    }  
    break; 
    case OP_STW: 
    {
		//Store a word at memory address base + offset + 1 : base + offset
		ScalarRegister src = g_scalar_registers[trace_op.scalar_registers[0]];
		ScalarRegister base = g_scalar_registers[trace_op.scalar_registers[1]];
		int offset = trace_op.int_value;
		g_memory[base.int_value + offset] = src.int_value & 0x00FF;
		g_memory[base.int_value + offset + 1] = (src.int_value & 0xFF00) >> 8;
    }  
    break;
    case OP_SETVERTEX:
    {
		//TODO
    }  
    break; 
    case OP_SETCOLOR:
    {
		//TODO
    }  
    break;
    case OP_ROTATE:  // optional
    break;
    case OP_TRANSLATE:
    {
		//TODO
    }  
    break; 
    case OP_SCALE:  // optional 
    break;
    case OP_PUSHMATRIX:       // deprecated 
    break;
    case OP_POPMATRIX:   // deprecated 
    break;
    case OP_BEGINPRIMITIVE: 
    {
		//Delimit the vertices that define a primitive or a group of primitives??
    }  
    break;
    case OP_ENDPRIMITIVE:
    {
		//Delimit the vertices that define a primitive or a group of primitives??
    }  
    break;
    case OP_LOADIDENTITY:  // deprecated 
    break;
    case OP_FLUSH: 
    {

    }  
    break;
    case OP_DRAW:
    {
		//Draw the contents of the frame buffer on a screen (if available).
    }  
    break; 
    case OP_BRN:{
		//I believe the pc is only incremented by 1 each time
		if (g_condition_code_register.int_value == 4) 
			ret_next_instruction_idx = trace_op.int_value;
    }  
    break;

    case OP_BRZ:
    {
		if (g_condition_code_register.int_value == 2)
			ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_BRP:
    {
		if (g_condition_code_register.int_value == 1) 
			ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_BRNZ:
    {
		if (g_condition_code_register.int_value == 2 || g_condition_code_register.int_value == 4)
			ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_BRNP:
    {
		if (g_condition_code_register.int_value == 4 || g_condition_code_register.int_value == 1)
			ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_BRZP:
    {
		if (g_condition_code_register.int_value == 2 || g_condition_code_register.int_value == 1)
			ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_BRNZP:
    {
		ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_JMP:
    {
		//TODO: debugging
		ScalarRegister base = g_scalar_registers[trace_op.scalar_registers[0]];
		ret_next_instruction_idx = base.int_value;
    }  
    break;
    case OP_JSR: 
    {
		g_scalar_registers[7].int_value = g_current_pc;
		ret_next_instruction_idx = trace_op.int_value;
    }  
    break;
    case OP_JSRR: 
    {
		g_scalar_registers[7].int_value = g_current_pc;
		ret_next_instruction_idx = g_scalar_registers[trace_op.scalar_registers[0]].int_value;
    }  
      break; 
      

    case OP_HALT: 
      g_program_halt = 1; 
      break; 

    default:
    break;
    }
	cout << "return: " << ret_next_instruction_idx << endl;
  return ret_next_instruction_idx;
}

////////////////////////////////////////////////////////////////////////
// desc: Dump given trace_op
////////////////////////////////////////////////////////////////////////
void PrintTraceOp(const TraceOp &trace_op) 
{  
  cout << "  opcode: " << SignExtension(trace_op.opcode);
  cout << ", scalar_register[0]: " << (int) trace_op.scalar_registers[0];
  cout << ", scalar_register[1]: " << (int) trace_op.scalar_registers[1];
  cout << ", scalar_register[2]: " << (int) trace_op.scalar_registers[2];
  cout << ", vector_register[0]: " << (int) trace_op.vector_registers[0];
  cout << ", vector_register[1]: " << (int) trace_op.vector_registers[1];
  cout << ", idx: " << (int) trace_op.idx;
  cout << ", primitive_index: " << (int) trace_op.primitive_type;
  cout << ", int_value: " << (int) SignExtension(trace_op.int_value) << endl; 
  //c  cout << ", float_value: " << (float) trace_op.float_value << endl;
}

////////////////////////////////////////////////////////////////////////
// desc: This function is called every trace is executed
//       to provide the contents of all the registers
////////////////////////////////////////////////////////////////////////
void PrintContext(const TraceOp &current_op)
{

  cout << "--------------------------------------------------" << endl;
  cout << "3220X-Instruction Count: " << g_instruction_count
       << " C_PC: " << (g_current_pc *4)
       << " C_PC_IND: " << g_current_pc 
       << ", Curr_Opcode: " << current_op.opcode
       << " NEXT_PC: " << ((g_scalar_registers[PC_IDX].int_value)<<2) 
       << " NEXT_PC_IND: " << (g_scalar_registers[PC_IDX].int_value)
       << ", Next_Opcode: " << g_trace_ops[g_scalar_registers[PC_IDX].int_value].opcode 
       << endl;
  cout <<"3220X-"; 
  for (int srIdx = 0; srIdx < NUM_SCALAR_REGISTER; srIdx++) {
    cout << "R" << srIdx << ":" 
         << ((srIdx < 8 || srIdx == 15) ? SignExtension(g_scalar_registers[srIdx].int_value) : (float) FIXED_TO_FLOAT1114(g_scalar_registers[srIdx].int_value)) 
         << (srIdx == NUM_SCALAR_REGISTER-1 ? "" : ", ");
  }

  cout << " CC :N: " << ((g_condition_code_register.int_value &0x4) >>2) << " Z: " 
       << ((g_condition_code_register.int_value &0x2) >>1) << " P: " << (g_condition_code_register.int_value &0x1) << "  "; 
  cout << " draw: " << (g_gpu_status_register.int_value &0x01) << " fush: " << ((g_gpu_status_register.int_value & 0x2)>>1) ;
  cout << " prim_type: "<< ((g_gpu_status_register.int_value & 0x4) >> 2)  << " "; 
   
  cout << endl;
  
  // for (int vrIdx = 0; vrIdx < NUM_VECTOR_REGISTER; vrIdx++) {
  
  for (int vrIdx = 0; vrIdx < 6; vrIdx++) {
    cout <<"3220X-"; 
    cout << "V" << vrIdx << ":";
    for (int elmtIdx = 0; elmtIdx < NUM_VECTOR_ELEMENTS; elmtIdx++) { 
      cout << "Element[" << elmtIdx << "] = " 
           << (float)FIXED_TO_FLOAT1114(g_vector_registers[vrIdx].element[elmtIdx].int_value) 
           << (elmtIdx == NUM_VECTOR_ELEMENTS-1 ? "" : ",");
    }
    cout << endl;
  }
  cout << endl;
  cout <<"3220X-"; 
  cout <<" vertices P1_X: " << g_gpu_vertex_registers[0].x_value; 
  cout <<" vertices P1_Y: " << g_gpu_vertex_registers[0].y_value; 
  cout <<" r: " << g_gpu_vertex_registers[0].r_value; 
  cout <<" g: " << g_gpu_vertex_registers[0].g_value; 
  cout <<" b: " << g_gpu_vertex_registers[0].b_value; 
  cout <<" P2_X: " << g_gpu_vertex_registers[1].x_value; 
  cout <<" P2_Y: " << g_gpu_vertex_registers[1].y_value; 
  cout <<" r: " << g_gpu_vertex_registers[1].r_value; 
  cout <<" g: " << g_gpu_vertex_registers[1].g_value; 
  cout <<" b: " << g_gpu_vertex_registers[1].b_value; 
  cout <<" P3_X: " << g_gpu_vertex_registers[2].x_value; 
  cout <<" P3_Y: " << g_gpu_vertex_registers[2].y_value; 
  cout <<" r: " << g_gpu_vertex_registers[2].r_value; 
  cout <<" g: " << g_gpu_vertex_registers[2].g_value; 
  cout <<" b: " << g_gpu_vertex_registers[2].b_value << endl; 
  
  cout << "--------------------------------------------------" << endl;
}

int main(int argc, char **argv) 
{
  ///////////////////////////////////////////////////////////////
  // Initialize Global Variables
  ///////////////////////////////////////////////////////////////
  //
  InitializeGlobalVariables();

  ///////////////////////////////////////////////////////////////
  // Load Program
  ///////////////////////////////////////////////////////////////
  //
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " <input>" << endl;
    return 1;
  }

  ifstream infile(argv[1]);
  if (!infile) {
    cerr << "Error: Failed to open input file " << argv[1] << endl;
    return 1;
  }
  vector< bitset<sizeof(uint32_t)*CHAR_BIT> > instructions;
  while (!infile.eof()) {
    bitset<sizeof(uint32_t)*CHAR_BIT> bits;
    infile >> bits;
    if (infile.eof())  break;
    instructions.push_back(bits);
  }
  
  infile.close();

#ifdef DEBUG
  cout << "The contents of the instruction vectors are :" << endl;
  for (vector< bitset<sizeof(uint32_t)*CHAR_BIT> >::iterator ii =
      instructions.begin(); ii != instructions.end(); ii++) {
    cout << "  " << *ii << endl;
  }
#endif // DEBUG

  ///////////////////////////////////////////////////////////////
  // Decode instructions into g_trace_ops
  ///////////////////////////////////////////////////////////////
  //
  for (vector< bitset<sizeof(uint32_t)*CHAR_BIT> >::iterator ii =
      instructions.begin(); ii != instructions.end(); ii++) {
    uint32_t inst = (uint32_t) ((*ii).to_ulong());
    TraceOp trace_op = DecodeInstruction(inst);
    g_trace_ops.push_back(trace_op);
  }

#ifdef DEBUG
  cout << "The contents of the g_trace_ops vectors are :" << endl;
  for (vector<TraceOp>::iterator ii = g_trace_ops.begin();
      ii != g_trace_ops.end(); ii++) {
    PrintTraceOp(*ii);
  }
#endif // DEBUG

  ///////////////////////////////////////////////////////////////
  // Execute 
  ///////////////////////////////////////////////////////////////
  //
  g_scalar_registers[PC_IDX].int_value = 0;
  for (;;) {
    TraceOp current_op = g_trace_ops[g_scalar_registers[PC_IDX].int_value];
    int idx = ExecuteInstruction(current_op);
    g_current_pc = g_scalar_registers[PC_IDX].int_value; // debugging purpose only 
    if (current_op.opcode == OP_JSR || current_op.opcode == OP_JSRR)
      g_scalar_registers[LR_IDX].int_value = (g_scalar_registers[PC_IDX].int_value + 1) << 2 ;


    
    g_scalar_registers[PC_IDX].int_value += 1; 
    if (idx != -1) { // Branch
      if (current_op.opcode == OP_JMP || current_op.opcode == OP_JSRR) // Absolute addressing
        g_scalar_registers[PC_IDX].int_value = idx; 
      else // PC-relative addressing (OP_JSR || OP_BRXXX)
        g_scalar_registers[PC_IDX].int_value += idx; 
    }

#ifdef DEBUG
    g_instruction_count++;
    PrintContext(current_op);
#endif // DEBUG

    if (g_program_halt == 1) 
      break;
  }

  return 0;
}

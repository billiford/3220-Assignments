`include "global_def.h"

module Memory(
  I_CLOCK,
  I_LOCK,
  I_Opcode,
  I_PC,
  I_IR, 	
  I_R15PC,  
  I_DestRegIdx,
  I_DestVRegIdx, 	      
  I_DestValue,
  I_CCValue, 	      
  I_VecSrc1Value, 
  I_VecDestValue, 	 
  I_EX_Valid, 
  I_MARValue,
  I_MDRValue,
  I_RegWEn,
  I_VRegWEn,
  I_CCWEn,   
  I_GPUStallSignal,   
  O_LOCK,
  O_Opcode,
  O_IR, 	
  O_PC, 
  O_R15PC,  
  O_DestRegIdx,
  O_DestVRegIdx, 	  
  O_LEDR,
  O_LEDG,
  O_HEX0,
  O_HEX1,
  O_HEX2,
  O_HEX3,
  O_CCValue, 	      
  O_VecSrc1Value, 
  O_VecDestValue, 
  O_DestValue,
  O_MEM_Valid,
  O_RegWEn,
  O_VRegWEn,
  O_CCWEn   	      
 );

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////
//
// Inputs from the execute stage
input I_CLOCK;
input I_LOCK;
input [`OPCODE_WIDTH-1:0] I_Opcode;
input [`IR_WIDTH-1:0] I_IR;   
input [`PC_WIDTH-1:0] I_PC;
input [`PC_WIDTH-1:0] I_R15PC;
input [3:0] I_DestRegIdx;
input [`VREG_ID_WIDTH-1:0] I_DestVRegIdx;
input [`REG_WIDTH-1:0] I_DestValue;

input [`VREG_WIDTH-1:0] I_VecSrc1Value; 
input [`VREG_WIDTH-1:0] I_VecDestValue;
input I_EX_Valid; 

input [2:0] I_CCValue;
    

input [`REG_WIDTH-1:0] I_MARValue;
input [`REG_WIDTH-1:0] I_MDRValue;


input    I_RegWEn;
input    I_VRegWEn;
input    I_CCWEn;

// GPU pipeline stall signal    
input    I_GPUStallSignal; 

   	       
// Outputs to the writeback stage
output reg O_LOCK;
output reg [`OPCODE_WIDTH-1:0] O_Opcode;
output reg [`IR_WIDTH-1:0] O_IR;  
output reg [`PC_WIDTH-1:0] O_PC; 
output reg [`PC_WIDTH-1:0] O_R15PC; 
output reg [3:0] O_DestRegIdx;
output reg [`VREG_ID_WIDTH-1:0] O_DestVRegIdx;
output reg [`REG_WIDTH-1:0] O_DestValue;

output reg [2:0] O_CCValue;
output reg [`VREG_WIDTH-1:0] O_VecSrc1Value; 
output reg [`VREG_WIDTH-1:0] O_VecDestValue;
output reg O_MEM_Valid; 

output reg   O_RegWEn;
output reg   O_VRegWEn;
output reg   O_CCWEn;


// Outputs for debugging
output [9:0] O_LEDR;
output [7:0] O_LEDG;
output [6:0] O_HEX0, O_HEX1, O_HEX2, O_HEX3;

/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//
reg[`DATA_WIDTH-1:0] DataMem[0:`INST_MEM_SIZE-1];

/////////////////////////////////////////
// INITIAL STATEMENT GOES HERE
/////////////////////////////////////////
//
initial 
begin
  $readmemh("data.hex", DataMem);
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////
//

/////////////////////////////////////////
// ## Note ##
// 1. Do the appropriate memory operations.
/////////////////////////////////////////
always @(negedge I_CLOCK)
begin
  O_LOCK <= I_LOCK;

  if (I_LOCK == 1'b1)
  begin
    /////////////////////////////////////////////
    // TODO: Complete here 
    /////////////////////////////////////////////
  end else // if (I_LOCK == 1'b1)
  begin
     
  end // if (I_LOCK == 1'b1)
end // always @(negedge I_CLOCK)

/////////////////////////////////////////
// ## Note ##
// Simple implementation of Memory-mapped I/O
// - The value stored at dedicated location will be expressed 
//   by the corresponding H/W.
//   - LEDR: Address 1020 (0x3FC)
//   - LEDG: Address 1021 (0x3FD)
//   - HEX : Address 1022 (0x3FE)
/////////////////////////////////////////
// Create and connect HEX register 
reg [15:0] HexOut;

SevenSeg sseg0(.OUT(O_HEX3), .IN(HexOut[15:12]));
SevenSeg sseg1(.OUT(O_HEX2), .IN(HexOut[11:8]));
SevenSeg sseg2(.OUT(O_HEX1), .IN(HexOut[7:4]));
SevenSeg sseg3(.OUT(O_HEX0), .IN(HexOut[3:0]));


// Create and connect LEDR, LEDG registers 
reg [9:0] LedROut;
reg [7:0] LedGOut;


wire [`DATA_MEM_ADDR_SIZE-1:0] mar_line_addr;
reg [`DATA_WIDTH-1:0]      dst_value;
	 
assign mar_line_addr = (I_MARValue >> 1) ; // data is stored with word address
    
 
// access the memory 
// How to access data memory is shown. you have to complete the following always
   
 always @(*) begin
	O_RegWEn = I_RegWEn;
    
      if (I_EX_Valid) begin
	 if (I_Opcode == `OP_LDW) begin
	    dst_value = (DataMem[mar_line_addr]);
	 end
	else 
	  dst_value = I_DestValue;
      end // if (I_EX_Valid)
 end // always @ (*)
   

   
always @(negedge I_CLOCK)
begin
  if (I_LOCK == 1) begin
    HexOut <= 16'hBEEF;
    LedGOut <= 8'b11111111;
    LedROut <= 10'b1111111111;
	O_MEM_Valid <= 1'b0;
	//O_RegWEn <= 1'b0;
	O_VRegWEn <= 1'b0;
	O_CCWEn <= 1'b0; 
	O_PC <= I_PC;
	O_IR <= I_IR;
     
  end else begin // if (I_LOCK == 0) begin

     //O_RegWEn = I_RegWEn;
	 O_PC <= I_PC;
	 O_IR <= I_IR;
     // You need to add more conditions to perform store operations. (Hints: check valid bits) 
     if (I_Opcode == `OP_STW) begin
	// memory mapped IO operations 
	// HexOut <= I_MDRValue;
	
	if ( I_MARValue[9:0] == `ADDRHEX)
	  HexOut <= I_MDRValue;
	else if (I_MARValue[9:0] == `ADDRLEDR)
	  LedROut <= I_MDRValue;
	else if (I_MARValue[9:0] == `ADDRLEDG)
	  LedGOut <= I_MDRValue;
	else
	  
	  // data memory write 
	  DataMem[mar_line_addr] <= I_MDRValue;
     end // if (I_Opcode == `OP_STW)
	

  end // else: !if(I_LOCK == 0)
end
   
   
  
     
     /*
     
    if ((I_FetchStall == 1'b0) && (I_DepStall == 1'b0)) begin
      if (I_Opcode == `OP_STW) begin
	 
        if (I_ALUOut[9:0] == `ADDRHEX)
          HexOut <= I_DestValue;
        else if (I_ALUOut[9:0] == `ADDRLEDR)
          LedROut <= I_DestValue;
        else if (I_ALUOut[9:0] == `ADDRLEDG)
          LedGOut <= I_DestValue;
	 
      end // if (I_Opcode == `OP_STW) begin
    end // if ((I_FetchStall == 1'b0) && (I_DepStall == 1'b0)) begin
   
  end // if (I_LOCK == 0) begin
end // always @(negedge I_CLOCK)
*/

assign O_LEDR = LedROut;
assign O_LEDG = LedGOut;

endmodule // module Memory

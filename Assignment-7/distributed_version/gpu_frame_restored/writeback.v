`include "global_def.h"

module Writeback(
  I_CLOCK,
  I_LOCK,
  I_Opcode,
  I_IR, 	
  I_PC,  
  I_R15PC,
  I_DestRegIdx,
  I_DestVRegIdx, 	
  I_DestValue,  
  I_CCValue, 		 
  I_VecSrc1Value,
  I_VecDestValue,
  I_MEM_Valid,
  I_RegWEn, 
  I_VRegWEn, 
  I_CCWEn,
  I_GPUStallSignal, 
  O_LOCK,
  O_WriteBackRegIdx,
  O_WriteBackVRegIdx,		 
  O_WriteBackData,
  O_PC, 
  O_CCValue, 		 
  O_VecDestValue,
  O_GSRValue, 
  O_GSRValue_Valid,
  O_VertexV1, 
  O_VertexV2, 
  O_VertexV3,
  O_RegWEn, 
  O_VRegWEn, 	 
  O_CCWEn     	       
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////
//
// Inputs from the memory stage
input I_CLOCK;
input I_LOCK;
input [`OPCODE_WIDTH-1:0] I_Opcode;
input [`IR_WIDTH-1:0] I_IR;   
input [`PC_WIDTH-1:0] I_PC;
input [`PC_WIDTH-1:0] I_R15PC;
input [3:0] I_DestRegIdx;
input [`VREG_ID_WIDTH-1:0] I_DestVRegIdx;   
input [`REG_WIDTH-1:0] I_DestValue;
input [2:0] I_CCValue;
    
input [`VREG_WIDTH-1:0] I_VecSrc1Value; 
input [`VREG_WIDTH-1:0] I_VecDestValue;
input I_MEM_Valid; 

input I_RegWEn;
input I_VRegWEn;
input I_CCWEn;

// input from GPU stage 
input I_GPUStallSignal;     

// Outputs to the decode stage
output reg O_LOCK;
output reg [3:0] O_WriteBackRegIdx;
output reg [`VREG_ID_WIDTH-1:0] O_WriteBackVRegIdx;
output reg[`REG_WIDTH-1:0] O_WriteBackData;
output reg [`VREG_WIDTH-1:0] O_VecDestValue;
output reg [2:0] O_CCValue;
output reg  O_RegWEn;
output reg  O_VRegWEn; 	 
output reg  O_CCWEn; 
output reg [`PC_WIDTH-1:0] O_PC;

// Output to the GPU stage 
output reg [`GSR_WIDTH-1:0] O_GSRValue; 
output reg [`VERTEX_REG_WIDTH-1:0] O_VertexV1;
output reg [`VERTEX_REG_WIDTH-1:0] O_VertexV2;
output reg [`VERTEX_REG_WIDTH-1:0] O_VertexV3;
output reg O_GSRValue_Valid; 

   
 reg [1:0] vertex_point_status;

 /////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//

 /////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
// Generate write back data to the decode stage 
 //   Perform Graphic operaionts 
/////////////////////////////////////////
//

   initial
     begin
	vertex_point_status = 0;

     end
   
   
   // Write back stage should perform
   // graphics pipeline operations
   // set vertex, setcolor, rotate, translate, scale, begin primitive, endprimitive, 

   
   reg [29:0] vertex_v1_t;
   reg [29:0] vertex_v2_t;
   reg [29:0] vertex_v3_t;

   
   

   
always @(negedge I_CLOCK)
begin
  O_LOCK <= I_LOCK;
   
  if (I_LOCK == 1'b1) 
    begin
    /////////////////////////////////////////////
    // TODO: Complete here 
    /////////////////////////////////////////////


       
	
    end // if (I_LOCK == 1'b1)
   
  else begin
     vertex_point_status <= 0;
     O_VertexV1 <= 0;
     O_VertexV2 <= 0;
     O_VertexV3 <= 0;
     O_GSRValue <= 0;
     O_GSRValue_Valid <=0; 
     
  end // else: !if(I_LOCK == 1'b1)
   
   
end
   
   


 
    
//   assign o_vertex1[1a

   
endmodule // module Writeback

      
`include "global_def.h"

`timescale 1ns / 1ps

module lg_highlevel(
  // Clock Input	 
  CLOCK_27,     // 27 MHz
  CLOCK_50,     // 50 MHz
  // Push Button
  KEY,          //	Pushbutton[3:0]
  // DPDT Switch
  SW,           // Toggle Switch[9:0]
  // 7-SEG Dispaly
  HEX0,         // Seven Segment Digit 0
  HEX1,         // Seven Segment Digit 1
  HEX2,         // Seven Segment Digit 2
  HEX3,         // Seven Segment Digit 3
  // LED
  LEDG,         // LED Green[7:0]
  LEDR,         // LED Red[9:0]
  // VGA
  VGA_HS,       // VGA H_SYNC
  VGA_VS,       // VGA V_SYNC
  VGA_R,        // VGA Red[3:0]
  VGA_G,        // VGA Green[3:0]
  VGA_B,        // VGA Blue[3:0]
  // SRAM Interface
  SRAM_DQ,      //	SRAM Data bus 16 Bits
  SRAM_ADDR,    //	SRAM Address bus 18 Bits
  SRAM_UB_N,    //	SRAM High-byte Data Mask 
  SRAM_LB_N,    //	SRAM Low-byte Data Mask 
  SRAM_WE_N,    //	SRAM Write Enable
  SRAM_CE_N,    //	SRAM Chip Enable
  SRAM_OE_N,    //	SRAM Output Enable
);

/////////////////////////////////////////
// INPUT/OUTPUT DEFINITION GOES HERE
////////////////////////////////////
//
// Clock Input
input	[1:0]	CLOCK_27; // 27 MHz
input       CLOCK_50; // 50 MHz
// Push Button
input	[3:0]	KEY; //	Pushbutton[3:0]
// DPDT Switch
input	[9:0]	SW;	// Toggle Switch[9:0]
// 7-SEG Dispaly
output [6:0] HEX0; // Seven Segment Digit 0
output [6:0] HEX1; // Seven Segment Digit 1
output [6:0] HEX2; // Seven Segment Digit 2
output [6:0] HEX3; // Seven Segment Digit 3
// LED
output [7:0] LEDG; // LED Green[7:0]
output [9:0] LEDR; // LED Red[9:0]
// VGA
output        VGA_HS; // VGA H_SYNC
output        VGA_VS; // VGA V_SYNC
output [3:0]  VGA_R;  // VGA Red[3:0]
output [3:0]  VGA_G;  // VGA Green[3:0]
output [3:0]  VGA_B;  // VGA Blue[3:0]
// SRAM Interface
inout	 [15:0] SRAM_DQ; // SRAM Data bus 16 Bits
output [17:0] SRAM_ADDR; // SRAM Address bus 18 Bits
output        SRAM_UB_N; // SRAM High-byte Data Mask 
output        SRAM_LB_N; // SRAM Low-byte Data Mask 
output        SRAM_WE_N; // SRAM Write Enable
output        SRAM_CE_N; // SRAM Chip Enable
output        SRAM_OE_N; // SRAM Output Enable

/////////////////////////////////////////
// TESTBENCH SIGNAL DECLARATION GOES HERE
/////////////////////////////////////////
//
reg test_clock;
initial begin
  test_clock = 1;
  #10000 $finish;
end

always begin 
  #20 test_clock = ~test_clock;
end

/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//
wire pll_c0;
wire pll_locked;

wire LOCK_FD;
wire [`PC_WIDTH-1:0] PC_FD;
wire [`IR_WIDTH-1:0] IR_FD;

wire [`PC_WIDTH-1:0] BranchPC_EF;
wire BranchAddrSelect_EF;
wire DepStallSignal_DF;
wire BranchStallSignal_DF;
wire FE_Valid_FD;

   

wire [3:0] WriteBackRegIdx_WD;
wire [`VREG_ID_WIDTH-1:0] WriteBackVRegIdx_WD;   
wire [`REG_WIDTH-1:0] WritebackData_WD;
wire [`PC_WIDTH-1:0] PC_WD;

wire [1:0] 	      Idx_WD;
wire [`VREG_WIDTH-1:0] VecSrc1Value_WD;
wire [`VREG_WIDTH-1:0] VecSrc2Value_WD;
wire [`VREG_WIDTH-1:0] VecDestValue_WD;
   
wire 	       RegWEn_WD;
wire 	       VRegWEn_WD;
wire 	       CCWEn_WD;
   


wire LOCK_DE;
wire [`PC_WIDTH-1:0] PC_DE;
wire [`OPCODE_WIDTH-1:0] Opcode_DE;
wire [`IR_WIDTH-1:0] IR_DE;   
wire [`REG_WIDTH-1:0] Src1Value_DE;
wire [`REG_WIDTH-1:0] Src2Value_DE;
wire [3:0] DestRegIdx_DE;
wire [`VREG_ID_WIDTH-1:0]  DestVRegIdx_DE;
wire [`REG_WIDTH-1:0] DestValue_DE;
wire [`REG_WIDTH-1:0] Imm_DE;
wire DepStall_DE;

wire [1:0] Idx_DE;
wire [`VREG_WIDTH-1:0] VecSrc1Value_DE;
wire [`VREG_WIDTH-1:0] VecSrc2Value_DE;
wire [`VREG_WIDTH-1:0] VecDestValue_DE;

wire RegWEn_DE;
wire CCWen_DE;

wire DE_Valid_DE;

   
   
wire LOCK_EM;
wire [`OPCODE_WIDTH-1:0] Opcode_EM;
wire [`IR_WIDTH-1:0] IR_EM;      
wire [`PC_WIDTH-1:0] PC_EM;
wire [`PC_WIDTH-1:0] R15PC_EM;

wire [3:0] DestRegIdx_EM;
wire [`VREG_ID_WIDTH-1:0]  DestVRegIdx_EM;   
wire [`REG_WIDTH-1:0] DestValue_EM;
wire DestWrite_ED; 

wire [1:0] Idx_EM;
wire [`VREG_WIDTH-1:0] VecSrc1Value_EM;
wire [`VREG_WIDTH-1:0] VecSrc2Value_EM;
wire [`VREG_WIDTH-1:0] VecDestValue_EM;

wire EX_Valid_EM;
wire DestWrite_MD;

wire [`REG_WIDTH-1:0] MARValue_EM;
wire [`REG_WIDTH-1:0] MDRValue_EM;

wire 	       RegWEn_EM;
wire 	       VRegWEn_EM;
wire 	       CCWEn_EM;

wire LOCK_MW;
wire [`OPCODE_WIDTH-1:0] Opcode_MW;
wire [`IR_WIDTH-1:0] IR_MW;   
wire [`PC_WIDTH-1:0] PC_MW;   
wire [`PC_WIDTH-1:0] R15PC_MW;
wire [3:0] DestRegIdx_MW;
wire [`VREG_ID_WIDTH-1:0]  DestVRegIdx_MW; 
wire [`REG_WIDTH-1:0] DestValue_MW;  
wire EX_Valid_MW; 
wire [1:0]Idx_MW; 
wire [`VREG_WIDTH-1:0] VecSrc1Value_MW;
wire [`VREG_WIDTH-1:0] VecSrc2Value_MW;
wire [`VREG_WIDTH-1:0] VecDestValue_MW;

wire         LOCK_WG; 
wire 	       RegWEn_MW;
wire 	       VRegWEn_MW;
wire 	       CCWEn_MW;

   
wire [`GSR_WIDTH-1:0] GSRValue_WG; 
wire [`VERTEX_REG_WIDTH-1:0] VertexV1_WG;
wire [`VERTEX_REG_WIDTH-1:0] VertexV2_WG;
wire [`VERTEX_REG_WIDTH-1:0] VertexV3_WG;
wire GSRValue_Valid_WG; 


wire [2:0] 		     CCValue_DE;
wire [2:0] 		     CCValue_EM;
wire [2:0] 		     CCValue_MW;
wire [2:0] 		     CCValue_WD;         
   

wire 	GPUStallSignal_G; 

/////////////////////////////////////////
// PLL MODULE GOES HERE 
/////////////////////////////////////////
//
pll pll0 (
  .inclk0 (CLOCK_27[0]),
  .c0     (pll_c0),
  .locked (pll_locked)
);

/////////////////////////////////////////
// CPU PIPELINE MODULES GO HERE 
/////////////////////////////////////////
//
Fetch Fetch0 (
  //.I_CLOCK(pll_c0), 
  .I_CLOCK(test_clock), //Is this right for now?
  .I_LOCK(pll_locked),
  .I_BranchPC(BranchPC_EF),
  .I_BranchAddrSelect(BranchAddrSelect_EF),
  .I_BranchStallSignal(BranchStallSignal_DF),
  .I_DepStallSignal(DepStallSignal_DF),
  .I_GPUStallSignal(GPUStallSignal),
  .O_LOCK(LOCK_FD),
  .O_PC(PC_FD),
  .O_IR(IR_FD),
  .O_FE_Valid(FE_Valid_FD)	      
);

Decode Decode0 (
  .I_CLOCK(pll_c0),
  .I_LOCK(LOCK_FD),
  .I_PC(PC_FD),
  .I_IR(IR_FD),
  .I_FE_Valid(FE_Valid_FD),
  .I_WriteBackRegIdx(WriteBackRegIdx_WD),
  .I_WriteBackVRegIdx(WriteBackVRegIdx_WD),		
  .I_WriteBackData(WritebackData_WD),
  .I_CCValue(CCValue_WD), 			
  .I_WriteBackPC(PC_WD),
  .I_WriteBackPCEn(EX_Valid_MW),
  .I_VecSrc1Value(VecSrc1Value_WD),
  .I_VecSrc2Value(VecSrc2Value_WD),
  .I_VecDestValue(VecDestValue_WD),
  .I_RegWEn(RegWEn_WD),
  .I_VRegWEn(VRegWEn_WD),
  .I_CCWEn(CCWEn_WD),		      		       				  		
  .I_EDDestVRegIdx(DestVRegIdx_DE),
  .I_EDDestRegIdx(DestRegIdx_DE),
  .I_MDDestVRegIdx(DestVRegIdx_EM),
  .I_MDDestRegIdx(DestRegIdx_EM),  
  .I_EDDestWrite(RegWEn_ED),  
  .I_MDDestWrite(RegWEn_EM),
  .I_EDDestVWrite(VRegWEn_ED),
  .I_MDDestVWrite(VRegWEn_EM),  
  .I_EDCCWEn(CCWEn_ED),
  .I_MDCCWEn(CCWEn_EM),
  .I_GPUStallSignal(GPUStallSignal),
  .O_LOCK(LOCK_DE),
  .O_PC(PC_DE),
  .O_Opcode(Opcode_DE),
  .O_IR(IR_DE),		
  .O_Src1Value(Src1Value_DE),
  .O_Src2Value(Src2Value_DE),
  .O_DestRegIdx(DestRegIdx_DE),
  .O_DestVRegIdx(DestVRegIdx_DE),
  .O_Idx(Idx_DE),
  .O_Imm(Imm_DE),
  .O_DepStallSignal(DepStallSignal_DF),
  .O_BranchStallSignal(BranchStallSignal_DF),				
  .O_CCValue(CCValue_DE), 				
  .O_VecSrc1Value(VecSrc1Value_DE), 
  .O_VecSrc2Value(VecSrc2Value_DE),
  .O_DE_Valid(DE_Valid_DE) 		
);

Execute Execute0 (
  .I_CLOCK(pll_c0),
  .I_LOCK(LOCK_DE),
  .I_PC(PC_DE),
  .I_Opcode(Opcode_DE),
  .I_IR(IR_DE),		  
  .I_Src1Value(Src1Value_DE),
  .I_Src2Value(Src2Value_DE),
  .I_DestRegIdx(DestRegIdx_DE),
  .I_DestVRegIdx(DestVRegIdx_DE),
  .I_Imm(Imm_DE),
  .I_CCValue(CCValue_DE),
  .I_Idx(Idx_DE),
  .I_VecSrc1Value(VecSrc1Value_DE),
  .I_VecSrc2Value(VecSrc2Value_DE),		  
  .I_DE_Valid(DE_Valid_DE),				  
  .I_GPUStallSignal(GPUStallSignal),
  .O_LOCK(LOCK_EM),
  .O_Opcode(Opcode_EM),
  .O_IR(IR_EM),	
  .O_PC(PC_EM), 
  .O_R15PC(R15PC_EM), 
  .O_DestRegIdx(DestRegIdx_EM),
  .O_DestVRegIdx(DestVRegIdx_EM),		  
  .O_DestValue(DestValue_EM),
  .O_CCValue(CCValue_EM), 				  		  
  .O_VecSrc1Value(VecSrc1Value_EM), 
  .O_VecDestValue(VecDestValue_EM),
  .O_EX_Valid(EX_Valid_EM),
  .O_MARValue(MARValue_EM),
  .O_MDRValue(MDRValue_EM),
  .O_BranchPC_Signal(BranchPC_EF), 
  .O_BranchAddrSelect_Signal(BranchAddrSelect_EF),
  .O_RegWEn_Signal(RegWEn_ED),
  .O_VRegWEn_Signal(VRegWEn_ED),
  .O_CCWEn_Signal(CCWEn_ED),
  .O_RegWEn(RegWEn_EM),
  .O_VRegWEn(VRegWEn_EM),
  .O_CCWEn(CCWEn_EM)		      		       				  		  
);

Memory Memory0 (
  .I_CLOCK(pll_c0),
  .I_LOCK(LOCK_EM),
  .I_Opcode(Opcode_EM),
  .I_IR(IR_EM),
  .I_PC(PC_EM),  
  .I_R15PC(R15PC_EM),
  .I_DestRegIdx(DestRegIdx_EM),
  .I_DestVRegIdx(DestVRegIdx_EM),		
  .I_DestValue(DestValue_EM),
  .I_CCValue(CCValue_EM), 				  		
  .I_VecSrc1Value(VecSrc1Value_EM),
  .I_VecDestValue(VecDestValue_EM),
  .I_EX_Valid(EX_Valid_EM),		
  .I_MARValue(MARValue_EM),
  .I_MDRValue(MDRValue_EM),
  .I_RegWEn(RegWEn_EM),
  .I_VRegWEn(VRegWEn_EM),
  .I_CCWEn(CCWEn_EM),		      		       				  		
  .I_GPUStallSignal(GPUStallSignal),
  .O_LOCK(LOCK_MW),
  .O_Opcode(Opcode_MW),
  .O_IR(IR_MW),
  .O_PC(PC_MW),  
  .O_R15PC(R15PC_MW), 
  .O_DestRegIdx(DestRegIdx_MW),
  .O_DestVRegIdx(DestVRegIdx_MW),		
  .O_LEDR(LEDR),
  .O_LEDG(LEDG),
  .O_HEX0(HEX0),
  .O_HEX1(HEX1),
  .O_HEX2(HEX2),
  .O_HEX3(HEX3),  
  .O_CCValue(CCValue_MW), 				  					
  .O_VecSrc1Value(VecSrc1Value_MW), 
  .O_VecDestValue(VecDestValue_MW),
  .O_DestValue(DestValue_MW),
  .O_MEM_Valid(EX_Valid_MW),
  .O_RegWEn(RegWEn_MW),
  .O_VRegWEn(VRegWEn_MW),
  .O_CCWEn(CCWEn_MW)		      		       				  
);
   

Writeback Writeback0 (
  .I_CLOCK(pll_c0),
  .I_LOCK(LOCK_MW),
  .I_Opcode(Opcode_MW),
  .I_IR(IR_MW),	
  .I_PC(PC_MW), 
  .I_R15PC(R15PC_MW),  
  .I_DestRegIdx(DestRegIdx_MW),
  .I_DestVRegIdx(DestVRegIdx_MW),
  .I_VecSrc1Value(VecSrc1Value_MW),
  .I_DestValue(DestValue_MW),
  .I_VecDestValue(VecDestValue_MW),		      
  .I_MEM_Valid(EX_Valid_MW),
  .I_CCValue(CCValue_MW), 		      
  .I_RegWEn(RegWEn_MW),
  .I_VRegWEn(VRegWEn_MW),
  .I_CCWEn(CCWEn_MW),	
  .I_GPUStallSignal(GPUStallSignal),
  .O_LOCK(LOCK_WG),  
  .O_WriteBackRegIdx(WriteBackRegIdx_WD),
  .O_WriteBackVRegIdx(WriteBackVRegIdx_WD),		      
  .O_WriteBackData(WritebackData_WD),
  .O_CCValue(CCValue_WD), 
  .O_PC(PC_WD),  
  .O_VecDestValue(VecDestValue_WD),
  .O_GSRValue(GSRValue_WG),
  .O_GSRValue_Valid(GSRValue_Valid_WG),
  .O_VertexV1(VertexV1_WG), 
  .O_VertexV2(VertexV2_WG),
  .O_VertexV3(VertexV3_WG),
  .O_RegWEn(RegWEn_WD), 
  .O_VRegWEn(VRegWEn_WD),
  .O_CCWEn(CCWEn_WD)       	 		      
);

/////////////////////////////////////////
// TODO
// Rasterisation stage should be implemented here between writeback and gpu stages. 
// 1. Output interface of writeback stage should be extended.
// 2. Input interface of gpu stage also should be extended.
// 
// ** You don't have to modify VgaController, PixelGen and MultiSram(framebuffer) modules.
//
// ## Note
// 1. As an example code in the gpu module, you should update the output latch
// (O_GPU_DATA) of gpu module when I_VIDEO_ON is not asserted.
// 2. When I_VIDEO_ON is asserted, values stored in the framebuffer are
// displayed on the screen.
// /////////////////////////////////////////

/////////////////////////////////////////
// GPU PIPELINE MODULES GO HERE 
/////////////////////////////////////////
//
// VGA Connector Wires
wire [17:0]	mVGA_ADDR;
wire [15:0]	mVGA_DATA;
wire [9:0]  mVGA_X;
wire [9:0]  mVGA_Y;
wire [3:0]  mVGA_R;
wire [3:0]  mVGA_G;
wire [3:0]  mVGA_B;

// GPU Connector Wires
wire        mGPU_READ;
wire        mGPU_WRITE;
wire [17:0]	mGPU_ADDR;
wire [15:0]	mGPU_WRITE_DATA;
wire [15:0]	mGPU_READ_DATA;

wire VIDEO_ON; 

VgaController VgaController0 (
  // Control Signal
  .I_CLK          (pll_c0),
  .I_RST_N        (KEY[0]),
  // Host Side				
  .I_RED          (mVGA_R),
  .I_GREEN        (mVGA_G),
  .I_BLUE         (mVGA_B),
  .O_COORD_X      (mVGA_X),
  .O_COORD_Y      (mVGA_Y),
  // VGA Side
  .O_VGA_R        (VGA_R),
  .O_VGA_G        (VGA_G),
  .O_VGA_B        (VGA_B),
  .O_VGA_H_SYNC   (VGA_HS),
  .O_VGA_V_SYNC   (VGA_VS)
);

Gpu Gpu0 (
  .I_CLK          (pll_c0),
  .I_RST_N        (KEY[0]), // It should be connected with LOCK_WG
  .I_VIDEO_ON     (VIDEO_ON),
  // GPU-SRAM interface
  .I_GPU_DATA     (mGPU_READ_DATA),
	  
  .I_GSRValue(GSRValue_WG),
  .I_GSRValue_Valid(GSRValue_Valid_WG),
  .I_VertexV1(VertexV1_WG), 
  .I_VertexV2(VertexV2_WG),
  .I_VertexV3(VertexV3_WG), 		      
	  
  .O_GPU_DATA     (mGPU_WRITE_DATA),
  .O_GPU_ADDR     (mGPU_ADDR),
  .O_GPU_READ     (mGPU_READ),
  .O_GPU_WRITE    (mGPU_WRITE),
  .O_GPUStallSignal (GPUStallSignal_G)
  /*
  .O_HEX0(HEX0),
  .O_HEX1(HEX1),
  .O_HEX2(HEX2),
  .O_HEX3(HEX3) */
);

PixelGen PixelGen0 (
  // Control Signal
  .I_CLK          (pll_c0),
  .I_RST_N        (KEY[0]),
  // 
  .I_DATA         (mVGA_DATA),
  .I_COORD_X      (mVGA_X),
  .I_COORD_Y      (mVGA_Y),
  // SRAM Address Data
  .O_VIDEO_ON     (VIDEO_ON),
  .O_NEXT_ADDR    (mVGA_ADDR),
  .O_RED          (mVGA_R),
  .O_GREEN        (mVGA_G),
  .O_BLUE         (mVGA_B)
);

MultiSram MultiSram0 (	
  // VGA Side
  .I_VGA_READ     (VIDEO_ON),
  .I_VGA_ADDR     (mVGA_ADDR),
  .O_VGA_DATA     (mVGA_DATA),
  // GPU Side
  .I_GPU_ADDR     (mGPU_ADDR),
  .I_GPU_DATA     (mGPU_WRITE_DATA),
  .I_GPU_READ     (mGPU_READ), 
  .I_GPU_WRITE    (mGPU_WRITE),
  .O_GPU_DATA     (mGPU_READ_DATA),
  // SRAM
  .I_SRAM_DQ      (SRAM_DQ),
  .O_SRAM_ADDR    (SRAM_ADDR),
  .O_SRAM_UB_N    (SRAM_UB_N),
  .O_SRAM_LB_N    (SRAM_LB_N),
  .O_SRAM_WE_N    (SRAM_WE_N),
  .O_SRAM_CE_N    (SRAM_CE_N),
  .O_SRAM_OE_N    (SRAM_OE_N)
);

endmodule // module lg_highlevel

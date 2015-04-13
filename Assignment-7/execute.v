`include "global_def.h"

module Execute(
  I_CLOCK,
  I_LOCK,
  I_PC,	       
  I_Opcode,
  I_IR, 	       
  I_Src1Value,
  I_Src2Value,
  I_DestRegIdx,
  I_DestVRegIdx,
  I_Imm,
  I_CCValue, 	       
  I_Idx, 
  I_VecSrc1Value,
  I_VecSrc2Value,
  I_DE_Valid, 
  I_GPUStallSignal, 
  O_LOCK,
  O_Opcode,
  O_IR, 	 
  O_PC,   
  O_R15PC,
  O_DestRegIdx,
  O_DestVRegIdx,	 
  O_DestValue,
  O_CCValue, 	       
  O_VecSrc1Value,
  O_VecDestValue,
  O_EX_Valid, 
  O_MARValue, 
  O_MDRValue,
  O_BranchPC_Signal, 
  O_BranchAddrSelect_Signal,
  O_RegWEn,
  O_VRegWEn,
  O_CCWEn,
  O_RegWEn_Signal,
  O_VRegWEn_Signal,
  O_CCWEn_Signal  
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////
//
// Inputs from the decode stage
input I_CLOCK;
input I_LOCK;
input [`PC_WIDTH-1:0] I_PC;
input [`OPCODE_WIDTH-1:0] I_Opcode;
input [`IR_WIDTH-1:0] I_IR;   

input signed  [`REG_WIDTH-1:0] I_Src1Value;
input signed [`REG_WIDTH-1:0] I_Src2Value;
input [3:0] I_DestRegIdx;
input [`VREG_ID_WIDTH-1:0] I_DestVRegIdx;
input [`REG_WIDTH-1:0] I_Imm;
input [2:0] I_CCValue;

input [1:0] I_Idx; 
input [`VREG_WIDTH-1:0] I_VecSrc1Value; 
input [`VREG_WIDTH-1:0] I_VecSrc2Value; 

input I_DE_Valid;

// Stall signal from GPU stage    
input I_GPUStallSignal; 

// Outputs to the memory stage
output reg O_LOCK;
output reg [`OPCODE_WIDTH-1:0] O_Opcode;
output reg [`PC_WIDTH-1:0] O_PC;
output reg [`PC_WIDTH-1:0] O_R15PC;
output reg [`IR_WIDTH-1:0] O_IR;      
output reg [3:0] O_DestRegIdx;
output reg [`VREG_ID_WIDTH-1:0] O_DestVRegIdx;
output reg [`REG_WIDTH-1:0] O_DestValue;
output reg [2:0] O_CCValue;   
output reg [`VREG_WIDTH-1:0] O_VecSrc1Value; 
output reg [`VREG_WIDTH-1:0] O_VecDestValue;
output reg O_EX_Valid;

    
output reg[`REG_WIDTH-1:0] O_MARValue;
output reg[`REG_WIDTH-1:0] O_MDRValue;
    

output reg O_RegWEn;
output reg O_VRegWEn;
output reg O_CCWEn;
 		    

 // Signals to the front-end  (Note: suffix Signal means the output signal is not from reg) 
output reg [`PC_WIDTH-1:0] O_BranchPC_Signal; //changed to reg
output reg O_BranchAddrSelect_Signal; //changed to reg

// Signals to the DE stage for dependency checking    
output reg O_RegWEn_Signal; //Changed this from output to output reg
output  O_VRegWEn_Signal;
output reg O_CCWEn_Signal;   //Changed this from output to output reg 
  
/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//
reg [`REG_WIDTH-1:0] Src1Value;
reg [`REG_WIDTH-1:0] Src2Value;
reg [`REG_WIDTH-1:0] Imm;
reg [3:0] DestRegIdx;   
reg [`REG_WIDTH-1:0] DestValue;
//reg [`REG_WIDTH-1:0] RF[0:`NUM_RF-1]; // Scalar Register File (R0-R7: Integer, R8-R15: Floating-point)
reg[7:0] trav;
reg write_dest;
reg cc_write;
reg [2:0] cc;
reg [1:0] nop_count;

//assign O_RegWEn_Signal = write_dest;

initial
begin
  /* for (trav = 0; trav < `NUM_RF; trav = trav + 1'b1)
  begin
    RF[trav] = 0; 
  end*/ 
  O_RegWEn_Signal = 0;
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////
//


   always @(*) begin  
      case (I_Opcode)
	`OP_ADD_D:
	  begin 
		DestRegIdx = I_DestRegIdx; // why are these "<=" and not just "=" ?
		DestValue = I_Src1Value + I_Src2Value;
		//RF[DestRegIdx] <= DestValue;
		write_dest = 1;
	  end
	
	`OP_ADD_F:
	  begin 
		DestRegIdx = I_DestRegIdx; // why are these "<=" and not just "=" ?
		DestValue = I_Src1Value + I_Src2Value;
		//RF[DestRegIdx] <= DestValue;
		write_dest = 1;
	  end
		     
	`OP_ADDI_D:
	  begin
		DestRegIdx = I_DestRegIdx;
		DestValue = I_Src1Value + I_Imm;
		//RF[DestRegIdx] <= DestValue;
		write_dest = 1;
	  end
	
	`OP_ADDI_F:
	  begin
		DestRegIdx = I_DestRegIdx;
		DestValue = I_Src1Value + I_Imm;
		//RF[DestRegIdx] <= DestValue;
		write_dest = 1;
	  end
	
	`OP_VADD:
	  begin 

	  end
	`OP_AND_D:
	  begin
		DestRegIdx = I_DestRegIdx; // why are these "<=" and not just "=" ?
		DestValue = I_Src1Value & I_Src2Value; // does this work?
		//RF[DestRegIdx] <= DestValue;	
		write_dest = 1;
	  end
	
	 `OP_ANDI_D:
	   begin
		DestRegIdx = I_DestRegIdx;
		DestValue = I_Src1Value & I_Imm;
		//RF[DestRegIdx] <= DestValue;
		write_dest = 1;
	   end
	`OP_MOV:
	  begin 
		DestRegIdx = I_DestRegIdx;
		//RF[DestRegIdx] <= I_Src1Value;
		write_dest = 1;
	  end
	
	`OP_MOVI_D:
	  begin 
		DestRegIdx = I_DestRegIdx;
		//RF[DestRegIdx] <= I_Imm;
		write_dest = 1;
	  end
	
	`OP_MOVI_F:
	  begin 
		DestRegIdx = I_DestRegIdx;
		//RF[DestRegIdx] <= I_Imm;		
		write_dest = 1;
	  end
	
	`OP_VMOV:
	  begin 

	  end
	  
	`OP_VMOVI:
	  begin 

	  end 
	 `OP_CMP:
	   begin
	      
	   end
	
	`OP_CMPI:
	  begin
		if (I_Src1Value < I_Imm)
			cc = cc | `CC_N;
		else 
			cc = cc & 6;
		if (I_Src1Value == I_Imm)
			cc = cc | `CC_Z;
		else
			cc = cc & 5;
		if (I_Src1Value > I_Imm)
			cc = cc | `CC_P;
		else
			cc = cc & 3;
		cc_write = 1;
	  end
 
	`OP_VCOMPMOV:
	  begin
	     
	  end 
	
	`OP_VCOMPMOVI:
	  begin
	     
	  end 
	
	`OP_LDB:
	  begin

	  end
	
	`OP_LDW:
	  begin

	  end
	
	`OP_STB:
	  begin

	  end
	
	`OP_STW:
	  begin
		//BR and STW
		//RF[DestRegIdx] <= I_Imm;	
		//MDR value is the actual value
		//MAR value is the address value
		//Need some trial and error to check to see if this is correct?
		//https://piazza.com/class/i4mxk414x2b6sf?cid=51
		O_MARValue <= I_Imm + RF[I_DestRegisterIdx];
		O_MDRValue <= I_Src1Value;
	  end
	
	`OP_BRP:
	  begin
		if (I_CCValue == `CC_P) 
		begin
			O_R15PC = I_Imm;
		end
	  end
	
	`OP_BRN:
	  begin
		if (I_CCValue == `CC_N) 
		begin
			O_R15PC = I_Imm;
		end
	  end 

	`OP_BRZ:
	  begin
		if (I_CCValue == `CC_Z) 
		begin
			O_R15PC = I_Imm;
		end
	  end
	
	`OP_BRNP: 
	  begin
		if (I_CCValue == `CC_P && I_CCValue == `CC_N) 
		begin
			O_R15PC = I_Imm;
		end
	  end
	
	`OP_BRZP: 
	  begin
		if (I_CCValue == `CC_Z && I_CCValue == `CC_P) 
		begin
			O_R15PC = I_Imm;
		end	  
	  end 
	
		
	`OP_BRNZ: 
	  begin
		if (I_CCValue == `CC_N || I_CCValue == `CC_Z) 
		begin
			O_R15PC = I_Imm;
			O_BranchAddrSelect_Signal = 1;
		end	else
			O_BranchAddrSelect_Signal = 0;
	  end 

	`OP_BRNZP: 
	  begin
		if (I_CCValue == `CC_N && I_CCValue == `CC_Z && I_CCValue == `CC_P) 
		begin
			O_R15PC = I_Imm;
		end	 
	  end 

	`OP_JMP:
	  begin

	  end

	`OP_JSR:
	  begin

	  end

	`OP_JSRR:
	  begin

	  end
	     
	default:
	  begin 
		write_dest = 0;
		cc_write = 0;
		O_BranchAddrSelect_Signal = 0;
	  end 
      endcase //case (I_OPCDE) 
	  O_RegWEn_Signal = write_dest;
	  O_CCWEn_Signal = cc_write;
	  if (O_BranchAddrSelect_Signal) begin
			O_BranchPC_Signal = O_R15PC;
		end
   end // always @ begin
   
 	 



   
/////////////////////////////////////////
// ## Note ##
// - Do the appropriate ALU operations.
/////////////////////////////////////////


always @(negedge I_CLOCK)
begin
  O_LOCK <= I_LOCK;
  O_PC <= I_PC;
  O_IR <= I_IR;
  O_Opcode <= I_Opcode;
  
  if (I_LOCK == 1'b1) 
    begin
    // TODO: Complete here 
    end
  else // I_LOCK = 1'b0  
    begin 
		O_DestRegIdx <= DestRegIdx;
		O_DestValue <= DestValue;
        O_EX_Valid <= I_DE_Valid;
        O_RegWEn <= O_RegWEn_Signal;
        O_VRegWEn <= 1'b0; 
        O_CCWEn <= O_CCWEn_Signal;
		O_CCValue <= cc;
    end 
end

endmodule // module Execute

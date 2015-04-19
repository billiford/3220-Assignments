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

reg [`PC_WIDTH-1:0] R15PC;

    
output reg[`REG_WIDTH-1:0] O_MARValue;
output reg[`REG_WIDTH-1:0] O_MDRValue;

reg[`REG_WIDTH-1:0] MARValue;
reg[`REG_WIDTH-1:0] MDRValue;
    

output reg O_RegWEn;
output reg O_VRegWEn;
output reg O_CCWEn;
 		    

 // Signals to the front-end  (Note: suffix Signal means the output signal is not from reg) 
output [`PC_WIDTH-1:0] O_BranchPC_Signal; //changed to reg
output O_BranchAddrSelect_Signal; //changed to reg

// Signals to the DE stage for dependency checking    
output O_RegWEn_Signal; //Changed this from output to output reg
output O_VRegWEn_Signal;
output O_CCWEn_Signal;   //Changed this from output to output reg 
  
/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////
//
reg [`REG_WIDTH-1:0] Src1Value;
reg [`REG_WIDTH-1:0] Src2Value;
reg [`REG_WIDTH-1:0] Imm;
reg [3:0] DestRegIdx;   
reg [`REG_WIDTH-1:0] DestValue;
reg[`VREG_WIDTH-1:0] VecDestValue;
reg [`VREG_ID_WIDTH-1:0] DestVRegIdx;
//reg [`REG_WIDTH-1:0] RF[0:`NUM_RF-1]; // Scalar Register File (R0-R7: Integer, R8-R15: Floating-point)
reg[7:0] trav;
reg write_dest;
reg br_addr_signal;
reg br_pc_signal;
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
  //O_RegWEn_Signal = 0;
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////
//
integer i;
integer j;
integer k;
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
		if (I_Src1Value + I_Imm > 16'h8000)
			cc = `CC_N;
		else if (I_Src1Value + I_Imm == 16'h0000)
			cc = `CC_Z;
		else
			cc = `CC_P;
		cc_write = 1;	 
		write_dest = 1;
	  end
	
	`OP_ADDI_F:
	  begin
		DestRegIdx = I_DestRegIdx;
		DestValue = I_Src1Value + I_Imm;
		//RF[DestRegIdx] <= DestValue;
		write_dest = 1;
	  end
	
	`OP_VADD: //TODO Completeme, done-ish
	  begin
	  DestVRegIdx = I_DestVRegIdx;
		for (k = 0; k<`VREG_WIDTH; k=k+1) begin 
			VecDestValue[k] = I_VecSrc1Value[k] + I_VecSrc2Value[k]; //is this how indexing works?
		end
		write_dest = 1;
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
		DestValue = I_Src1Value;
		//RF[DestRegIdx] <= I_Src1Value;
		write_dest = 1;
	  end
	
	`OP_MOVI_D:
	  begin 
		DestRegIdx = I_DestRegIdx;
		DestValue = I_Imm;
		//RF[DestRegIdx] <= I_Imm;
		write_dest = 1;
	  end
	
	`OP_MOVI_F:
	  begin 
		DestRegIdx = I_DestRegIdx;
		DestValue = I_Imm;
		//RF[DestRegIdx] <= I_Imm;
		write_dest = 1;
	  end
	
	`OP_VMOV: //TODO COMPLETEME, possibly done
	  begin 
	  DestVRegIdx = I_DestVRegIdx;
		for (i = 0; i<`VREG_WIDTH; i=i+1) begin 
			VecDestValue[i] = I_VecSrc1Value[i]; //is this how indexing works?
		end
		write_dest = 1;
	  end
	  
	`OP_VMOVI: //TODO COMPLETEME, possibly done
	  begin 
	  DestVRegIdx = I_DestVRegIdx;
		for (j = 0; j<`VREG_WIDTH; j=j+1) begin 
			VecDestValue[j] = I_Imm; //is this how indexing works?
		end
		write_dest = 1;
	  end 
	 `OP_CMP:
	   begin
		if (I_Src1Value < I_Src2Value ||
			(I_Src1Value > 16'h8000 &&
			I_Src1Value > I_Src2Value))
			cc = `CC_N;
		else if (I_Src1Value == I_Src2Value)
			cc = `CC_Z;
		else
			cc = `CC_P;
		cc_write = 1;	      
	   end
	
	`OP_CMPI:
	  begin
		if (I_Src1Value < I_Imm ||
			(I_Src1Value > 16'h8000 &&
			I_Src1Value > I_Imm))
			cc = `CC_N;
		else if (I_Src1Value == I_Imm)
			cc = `CC_Z;
		else
			cc = `CC_P;
		cc_write = 1;
	  end
 
	`OP_VCOMPMOV: //TODO COMPLETEME
	  begin
		DestVRegIdx = I_DestVRegIdx;
		VecDestValue[I_Idx] = I_Src1Value;		
	  end 
	
	`OP_VCOMPMOVI: //TODO COMPLETEME
	  begin
		DestVRegIdx = I_DestVRegIdx;
		VecDestValue[I_Idx] = I_Imm;
	  end 
	
	`OP_LDB: //TODO COMPLETEME? 
	  begin

	  end
	
	`OP_LDW: //TODO COMPLETEME
	// ldw dest base offset
	// where is this getting assigned in memory??
	  begin
		DestRegIdx = I_DestRegIdx;
		MARValue = I_Imm + I_Src1Value;
	  end
	
	`OP_STB: //TODO COMPLETEME?
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
		MDRValue = I_Src2Value;
		MARValue = I_Imm + I_Src1Value;
	  end
	
	`OP_BRP:
	  begin
		if (I_CCValue == `CC_P) 
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;
	  end
	
	`OP_BRN:
	  begin
		if (I_CCValue == `CC_N) 
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;
	  end 

	`OP_BRZ:
	  begin
		if (I_CCValue == `CC_Z)
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;
	  end
	
	`OP_BRNP: 
	  begin
		if (I_CCValue == `CC_P || I_CCValue == `CC_N) 
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;
	  end
	
	`OP_BRZP: 
	  begin
		if (I_CCValue == `CC_Z || I_CCValue == `CC_P) 
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;	  
	  end 
	
		
	`OP_BRNZ: 
	  begin
		if (I_CCValue == `CC_N || I_CCValue == `CC_Z) 
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;
	  end 

	`OP_BRNZP: 
	  begin
		if (I_CCValue == `CC_N || I_CCValue == `CC_Z || I_CCValue == `CC_P) 
		begin
			R15PC = I_Imm;
			br_addr_signal = 1;
		end else
			br_addr_signal = 0;
	  end

	`OP_JMP: //TODO COMPLETEME
	  begin

	  end

	`OP_JSR: //TODO COMPLETEME
	  begin

	  end

	`OP_JSRR: //TODO COMPLETEME
	  begin

	  end
	     
	default:
	  begin 
		write_dest = 0;
		cc_write = 0;
		br_addr_signal = 0;
	  end 
      endcase //case (I_OPCDE) 
	  /*O_RegWEn_Signal = write_dest;
	  O_CCWEn_Signal = cc_write;
	  if (O_BranchAddrSelect_Signal) begin
			O_BranchPC_Signal = O_R15PC;
		end*/
		
	O_DestRegIdx = DestRegIdx;
	O_DestValue = DestValue;
	O_VecDestValue = VecDestValue;
	O_DestVRegIdx = DestVRegIdx;
	O_R15PC = R15PC;
   
   end // always @ begin
   
   assign O_RegWEn_Signal = write_dest;
   assign O_CCWEn_Signal = cc_write;
   assign O_BranchPC_Signal = R15PC;
   assign O_BranchAddrSelect_Signal = br_addr_signal;

   
 	 



   
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
  
  if (I_LOCK != 1'b1) 
    begin
    // TODO: Complete here 
    end
  else // I_LOCK = 1'b0  
    begin 
        O_EX_Valid <= I_DE_Valid;
        O_RegWEn <= O_RegWEn_Signal;
        O_VRegWEn <= 1'b0; 
        O_CCWEn <= O_CCWEn_Signal;
		O_CCValue <= cc;
		O_MDRValue <= MDRValue;
		O_MARValue <= MARValue;
    end 
end

endmodule // module Execute

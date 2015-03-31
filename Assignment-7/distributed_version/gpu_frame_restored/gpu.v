`include "global_def.h"

module Gpu (
  I_CLK, 
  I_RST_N,
  I_VIDEO_ON, 

  I_GPU_DATA,
  I_GSRValue,
  I_GSRValue_Valid, 
  I_VertexV1, 
  I_VertexV2, 
  I_VertexV3, 	    
  O_GPU_DATA,
  O_GPU_ADDR,
  O_GPU_READ,
  O_GPU_WRITE,
  O_GPUStallSignal, 
/*  O_HEX0,
  O_HEX1, 
  O_HEX2, 
  O_HEX3*/
);

input	I_CLK;
input I_RST_N;
input	I_VIDEO_ON;
input [`GSR_WIDTH-1:0] I_GSRValue;
input [`VERTEX_REG_WIDTH-1:0]  I_VertexV1; 
input [`VERTEX_REG_WIDTH-1:0]  I_VertexV2; 
input [`VERTEX_REG_WIDTH-1:0]  I_VertexV3;
input I_GSRValue_Valid; 
 
  
// GPU-SRAM interface
input       [15:0] I_GPU_DATA;
output reg  [15:0] O_GPU_DATA;
output reg  [17:0] O_GPU_ADDR;
output reg         O_GPU_WRITE;
output reg         O_GPU_READ;
output reg         O_GPUStallSignal; 

// 7-segment display interface 

// output [6:0] O_HEX0, O_HEX1, O_HEX2, O_HEX3;

/////////////////////////////////////////
// Example code goes here 
//
// ## Note
// It is highly recommended to play with this example code first so that you
// could get familiarized with a set of output ports. By doing so, you would
// get the hang of dealing with vector (graphics) objects in pixel frame.
/////////////////////////////////////////
//
reg [23:0] count;
reg [9:0]  rowInd;
reg [9:0]  colInd;





				
always @(posedge I_CLK or negedge I_RST_N)
begin
	if (!I_RST_N) begin
		O_GPU_ADDR <= 16'h0000;
		O_GPU_WRITE <= 1'b1;
		O_GPU_READ <= 1'b0;
		O_GPU_DATA <= {4'h0, 4'hF, 4'h0, 4'h0};
		count <= 0;

		O_GPUStallSignal <= 0; 
	end else begin
	
		if (!I_VIDEO_ON) begin
		
		  	count <= count + 1;
			
		if (count[23] == 0) begin 
		
				
				O_GPU_ADDR <= rowInd*640 + colInd;
				O_GPU_WRITE <= 1'b1;
				O_GPU_READ <= 1'b0;
				O_GPU_DATA <= {4'h0, 4'hf, 4'hf, 4'h0};
						
			end 
		 if (count[23] == 1)   begin 
		   O_GPU_ADDR <= rowInd*640 + colInd;
		   O_GPU_WRITE <= 1'b1;
		   O_GPU_READ <= 1'b0;
		   O_GPU_DATA <= {4'h0, 4'h0, 4'h0, 4'h0};
		end

		   
			
		end // if (!I_VIDEO_ON)
	   
	end // else: !if(!I_RST_N)
   
end
   


/*
SevenSeg sseg0(.OUT(O_HEX3), .IN({2'b0,points[1:0]}));
SevenSeg sseg1(.OUT(O_HEX2), .IN({3'b0, count[26]}));
SevenSeg sseg2(.OUT(O_HEX1), .IN({3'b0, count[25]}));
SevenSeg sseg3(.OUT(O_HEX0), .IN({3'b0, count[24]}));
*/


always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    colInd <= 0;
  end else begin
    if (!I_VIDEO_ON) begin
      if (colInd < 639)
        colInd <= colInd + 1;
      else
        colInd <= 0;
    end
  end
end

always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    rowInd <= 0;
  end else begin
    if (!I_VIDEO_ON) begin
      if (colInd == 0) begin
        if (rowInd < 399)
          rowInd <= rowInd + 1;
        else
          rowInd <= 0;
      end
    end
  end
end

endmodule

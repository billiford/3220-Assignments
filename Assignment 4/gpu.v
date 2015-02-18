module Gpu (
  I_CLK, 
  I_RST_N,
  I_VIDEO_ON, 
  // GPU-SRAM interface
  I_GPU_DATA, 
  O_GPU_DATA,
  O_GPU_ADDR,
  O_GPU_READ,
  O_GPU_WRITE,
  O_HEX0,
  O_HEX1, 
  O_HEX2, 
  O_HEX3, 
);

input	I_CLK;
input I_RST_N;
input	I_VIDEO_ON;

// GPU-SRAM interface
input       [15:0] I_GPU_DATA;
output reg  [15:0] O_GPU_DATA;
output reg  [17:0] O_GPU_ADDR;
output reg         O_GPU_WRITE;
output reg         O_GPU_READ;

// 7-segment display interface 

output [6:0] O_HEX0, O_HEX1, O_HEX2, O_HEX3;

/////////////////////////////////////////
// Example code goes here 
//
// ## Note
// It is highly recommended to play with this example code first so that you
// could get familiarized with a set of output ports. By doing so, you would
// get the hang of dealing with vector (graphics) objects in pixel frame.
/////////////////////////////////////////
//
reg [26:0] count;
reg [9:0]  rowInd;
reg [9:0]  colInd;

reg [9:0] p0x, p0y, p1x, p1y, temp_p0x, temp_p1x;
reg [19:0] dx, dy, incrE, incrNE; 
reg signed [20:0] d;


reg init_phase; 


initial begin 
	/* case 0 < m < 1 */
	/* p0x = 1; 
	p0y = 1; 
	p1x = 200;
	p1y = 100; */
	
	/* case x2 < x1 */
	p0x = 200;
	p0y = 1;
	p1x = 1;
	p1y = 100;
	
	temp_p0x = p0x;
	
	if (p1x < p0x) begin
		p0x = p1x;
		p1x = temp_p0x;
	end
	
	dx = p1x - p0x;
	dy = p1y - p0y;
	d = (dy * 2) - dx;
	incrE = 2 * dy;
	incrNE = (dx - dy) * 2;

end 

 
				
always @(posedge I_CLK or negedge I_RST_N)
begin
	if (!I_RST_N) begin
		O_GPU_ADDR <= 16'h0000;
		O_GPU_WRITE <= 1'b1;
		O_GPU_READ <= 1'b0;
		O_GPU_DATA <= {4'h0, 4'h0, 4'h0, 4'h0};
		count <= 0;
	end else begin
		if (!I_VIDEO_ON) begin
		  	count <= count + 1;
			if (p0x < p1x) begin
				if ((rowInd * 640 + colInd) == (p0y * 640 + p0x)) begin
					O_GPU_ADDR <= rowInd * 640 + colInd;
					O_GPU_WRITE <= 1'b1;
					O_GPU_READ <= 1'b0;
					O_GPU_DATA <= {4'h0, 4'hf, 4'hf, 4'h0};
					if (d <= 0) begin
						d <= d + incrE;
						p0x <= p0x + 1;
					end else begin
						d <= d - incrNE;
						p0x <= p0x + 1;
						p0y <= p0y + 1;
					end
				end 
				else begin
					O_GPU_ADDR <= rowInd*640 + colInd;
					O_GPU_WRITE <= 1'b1;
					O_GPU_READ <= 1'b0;
					O_GPU_DATA <= {4'h0, 4'h0, 4'h0, 4'h0};
				end
			end 
				/* reset the screen */ 		
			/*else if (count[26] == 1) begin 
			
			 
					
				O_GPU_ADDR <= rowInd*640 + colInd;
				O_GPU_WRITE <= 1'b1;
				O_GPU_READ <= 1'b0;
				O_GPU_DATA <= {4'h0, 4'h0, 4'h0, 4'h0};
			
			end */
					
		end 
	end
end



SevenSeg sseg0(.OUT(O_HEX3), .IN({3'b0, count[23]}));
SevenSeg sseg1(.OUT(O_HEX2), .IN({3'b0, count[26]}));
SevenSeg sseg2(.OUT(O_HEX1), .IN({3'b0, count[25]}));
SevenSeg sseg3(.OUT(O_HEX0), .IN({3'b0, count[24]}));


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

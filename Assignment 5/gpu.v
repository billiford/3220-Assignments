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

reg signed [15:0] p0x, p0y, p1x, p1y, p2x, p2y;
reg signed [15:0] A0, A1, A2, B0, B1, B2;
reg signed [15:0] x, y, x_min, y_min, x_max, y_max;
reg signed [15:0] e0, e1, e2;
reg [9:0] screen_clear_x, screen_clear_y;

reg init_phase; 
reg [1:0] screen_clear;

initial begin 
	/*	test case triangle 1	*/	
	//p0x = 1; p0y = 1; p1x = 200; p1y = 100; p2x = 50; p2y = 50;	
	/*	test case triangle	2*/	
	//p0x	= 100; p0y = 100; p1x =	200; p1y = 100; p2x = 200;	p2y =	200;
	/*	test	case	triangle	3*/	
	//p0x	= 100; p0y = 100; p1x =	200; p1y = 100; p2x = 200;	p2y =	1;
	/*	test	case	triangle	4*/	
	//p0x	= 20;	p0y =	20; p1x = 200; p1y =	1;	p2x =	1;	p2y =	1;
	/*	test	case	triangle	5*/	
	p0x	= 1; p0y	= 1; p1x	= 100; p1y = 90; p2x	= 20;	p2y =	100;
	
	if (p0x <= p1x && p0x <= p2x) x_min = p0x;
	else if (p1x <= p0x && p1x <= p2x) x_min = p1x;
	else x_min = p2x;
	
	if (p0y <= p1y && p0y <= p2y) y_min = p0y;
	else if (p1y <= p0y && p1y <= p2y) y_min = p1y;
	else y_min = p2y;
	
	if (p0x >= p1x && p0x >= p2x) x_max = p0x;
	else if (p1x >= p0x && p1x >= p2x) x_max = p1x;
	else x_max = p2x;
	
	if (p0y >= p1y && p0y >= p2y) y_max = p0y;
	else if (p1y >= p0y && p1y >= p2y) y_max = p1y;
	else y_max = p2y;
	
	x = x_min;
	y = y_min;
	
	A0 = -(p2y - p1y);  B0 = (p2x - p1x); 
   A1 = -(p0y - p2y);  B1 = (p0x - p2x); 
   A2 = -(p1y - p0y);  B2 = (p1x - p0x);
	
	e0 = A0 * (x - p1x) + B0 * (y - p1y); 
	e1 = A1 * (x - p2x) + B1 * (y - p2y); 
	e2 = A2 * (x - p0x) + B2 * (y - p0y);
	
	if (e0 < 0 || e1 < 0 || e2 < 0) begin
		A0 = -A0;
		B0 = -B0;
		A1 = -A1;
		B1 = -B1;
		A2 = -A2;
		B2 = -B2;
	end
	
	screen_clear = 0;
	screen_clear_x = 0;
	screen_clear_y = 0;
end 

 
				
always @(posedge I_CLK or negedge I_RST_N)
begin
	if (!I_RST_N) begin
		O_GPU_ADDR <= 16'h0000;
		O_GPU_WRITE <= 1'b1;
		O_GPU_READ <= 1'b0;
		O_GPU_DATA <= {4'h0, 4'h0, 4'h0, 4'h0};
		screen_clear <= 0;
	end
	else if (screen_clear < 2 && !I_VIDEO_ON) begin
		O_GPU_ADDR <= screen_clear_y * 640 + screen_clear_x;
		O_GPU_WRITE <= 1'b1;
		O_GPU_READ <= 1'b0;
		O_GPU_DATA <= {4'h0, 4'h0, 4'h0, 4'h0};
		if (screen_clear_x == 639 && screen_clear_y == 399)
			screen_clear <= screen_clear + 2'b1;
	end
	else begin
		if (!I_VIDEO_ON) begin
			e0 <= A0 * (x - p1x) + B0 * (y - p1y); 
			e1 <= A1 * (x - p2x) + B1 * (y - p2y); 
			e2 <= A2 * (x - p0x) + B2 * (y - p0y);
			if ((e0 >= 0) && (e1 >= 0) && (e2 >= 0)) begin
				O_GPU_ADDR <= y * 640 + x;
				O_GPU_WRITE <= 1'b1;
				O_GPU_READ <= 1'b0;
				O_GPU_DATA <= {4'h0, 4'hf, 4'hf, 4'h0};
			end
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
    x <= x_min;
	 screen_clear_x <= 0;
  end else begin
    if (!I_VIDEO_ON) begin
		if (screen_clear < 2) begin
			if (screen_clear_x < 639)
				screen_clear_x <= screen_clear_x + 1;
			else
				screen_clear_x <= 0;
		end else begin
			if (x < x_max)
			  x <= x + 1;
			else
			  x <= x_min;
		end
    end
  end
end

always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    y <= y_min;
	 screen_clear_y <= 0;
  end else begin
    if (!I_VIDEO_ON) begin
		if (screen_clear < 2) begin
			if (screen_clear_x == 0) begin
				if (screen_clear_y < 399)
					screen_clear_y <= screen_clear_y + 1;
				else
					screen_clear_y <= 0;
			end
		end else begin
			if (x == x_min) begin
			  if (y < y_max)
				 y <= y + 1;
			  else
				 y <= y_min;
			end
		end
    end
  end
end

endmodule

module PixelGen (
  // Control Signal
  I_CLK,
  I_RST_N,
  // 
  I_DATA,
  I_COORD_X,
  I_COORD_Y,
  // SRAM Address Data
  O_VIDEO_ON,
  O_NEXT_ADDR,
  O_RED,
  O_GREEN,
  O_BLUE
);

// Control Signal
input I_CLK;
input I_RST_N;

//
input [15:0] I_DATA;
input [9:0]	 I_COORD_X;
input [9:0]	 I_COORD_Y;

// SRAM Address Data
output reg        O_VIDEO_ON;
output reg [17:0] O_NEXT_ADDR; 
output reg [3:0]  O_RED;
output reg [3:0]  O_GREEN;
output reg [3:0]  O_BLUE;

always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    O_VIDEO_ON <= 1'b0;
    O_NEXT_ADDR <= 0;
  end else begin
    if (I_COORD_X == 639) begin
      if (I_COORD_Y == 39) begin
        O_VIDEO_ON <= 1;
        O_NEXT_ADDR <= 0;
      end else begin
        if (I_COORD_Y >= 440) begin
          O_VIDEO_ON <= 0;
          O_NEXT_ADDR <= 0;
        end else begin
          O_NEXT_ADDR <= (I_COORD_Y-40)*640 + I_COORD_X + 1;
        end
      end
    end else begin
      O_NEXT_ADDR <= (I_COORD_Y-40)*640 + I_COORD_X + 1;
    end
  end
end

always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    O_RED <= 0;
    O_GREEN <= 0;
    O_BLUE <= 0;
  end else begin
    if (I_COORD_Y == 39 && I_COORD_X == 639) begin
      O_RED <= I_DATA[11:8];
      O_GREEN <= I_DATA[7:4];
      O_BLUE <= I_DATA[3:0];
    end else begin
      if (I_COORD_Y < 40 || I_COORD_Y >= 440 || (I_COORD_Y == 439 && I_COORD_X == 639)) begin
        O_RED <= 0;
        O_GREEN <= 0;
        O_BLUE <= 0;
      end else begin
        O_RED <= I_DATA[11:8];
        O_GREEN <= I_DATA[7:4];
        O_BLUE <= I_DATA[3:0];
      end
    end
  end
end

endmodule

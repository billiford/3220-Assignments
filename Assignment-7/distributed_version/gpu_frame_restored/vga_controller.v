`include "global_def.h"

module VgaController (
  // Control Signal
  I_CLK,
  I_RST_N,
  // Host Side
  I_RED,
  I_GREEN,
  I_BLUE,
  O_ADDRESS,
  O_COORD_X,
  O_COORD_Y,
  // VGA Side
  O_VGA_R,
  O_VGA_G,
  O_VGA_B,
  O_VGA_SYNC,
  O_VGA_BLANK,
  O_VGA_CLOCK,
  O_VGA_H_SYNC,
  O_VGA_V_SYNC
);

// Control Signal
input I_CLK;
input I_RST_N;

// Host Side
input [3:0]	I_RED;
input [3:0]	I_GREEN;
input [3:0]	I_BLUE;
output reg [19:0]	O_ADDRESS;
output reg [9:0]  O_COORD_X;
output reg [9:0]  O_COORD_Y;

// VGA Side
output [3:0] O_VGA_R;
output [3:0] O_VGA_G;
output [3:0] O_VGA_B;
output       O_VGA_SYNC;
output       O_VGA_BLANK;
output       O_VGA_CLOCK;
output reg   O_VGA_H_SYNC;
output reg   O_VGA_V_SYNC;

// Internal Registers and Wires
reg [9:0] H_Counter;
reg [9:0] V_Counter;
reg [3:0] CursorColor_R;
reg [3:0] CursorColor_G;
reg [3:0] CursorColor_B;

assign O_VGA_BLANK = O_VGA_H_SYNC & O_VGA_V_SYNC;
assign O_VGA_SYNC  = 1'b0;
assign O_VGA_CLOCK = I_CLK;

assign O_VGA_R = (`X_START<=H_Counter && H_Counter<`X_START+`H_SYNC_ACT && `Y_START<=V_Counter && V_Counter<`Y_START+`V_SYNC_ACT) ? CursorColor_R : 0;
assign O_VGA_G = (`X_START<=H_Counter && H_Counter<`X_START+`H_SYNC_ACT && `Y_START<=V_Counter && V_Counter<`Y_START+`V_SYNC_ACT) ? CursorColor_G : 0;
assign O_VGA_B = (`X_START<=H_Counter && H_Counter<`X_START+`H_SYNC_ACT && `Y_START<=V_Counter && V_Counter<`Y_START+`V_SYNC_ACT) ? CursorColor_B : 0;

// Pixel LUT Address Generator
always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    O_ADDRESS <= 0;
    O_COORD_X <= 0;
    O_COORD_Y <= 0;
  end else begin
    if (`X_START<=H_Counter && H_Counter<`X_START+`H_SYNC_ACT && `Y_START<=V_Counter && V_Counter<`Y_START+`V_SYNC_ACT) begin
      O_ADDRESS <= O_COORD_Y*`H_SYNC_ACT+O_COORD_X-3;
      O_COORD_X <= H_Counter-`X_START;
      O_COORD_Y <= V_Counter-`Y_START;
    end
  end
end

// Cursor Generator	
always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    CursorColor_R	<= 0;
    CursorColor_G	<= 0;
    CursorColor_B	<= 0;
  end else begin
    CursorColor_R	<= I_RED;
    CursorColor_G	<= I_GREEN;
    CursorColor_B	<= I_BLUE;
  end
end

// H_Sync Generator, Ref. 25.175 MHz Clock
always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    H_Counter <=	0;
    O_VGA_H_SYNC <= 0;
  end else begin
    // H_Sync Counter
    if (H_Counter < `H_SYNC_TOTAL)
      H_Counter <=	H_Counter + 1;
    else
      H_Counter <=	0;
    // H_Sync Generator
    if (H_Counter < `H_SYNC_CYC)
      O_VGA_H_SYNC <= 0;
    else
      O_VGA_H_SYNC <= 1;
  end
end

//	V_Sync Generator, Ref. H_Sync
always @(posedge I_CLK or negedge I_RST_N)
begin
  if (!I_RST_N) begin
    V_Counter <=	0;
    O_VGA_V_SYNC <= 0;
  end else begin
    // When H_Sync Re-start
    if (H_Counter == 0) begin
      // V_Sync Counter
      if (V_Counter < `V_SYNC_TOTAL)
        V_Counter <=	V_Counter + 1;
      else
        V_Counter <=	0;
      // V_Sync Generator
      if (V_Counter < `V_SYNC_CYC)
        O_VGA_V_SYNC <= 0;
      else
        O_VGA_V_SYNC <= 1;
    end
  end
end

endmodule

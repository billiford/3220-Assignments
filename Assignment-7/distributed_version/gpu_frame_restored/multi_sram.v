module MultiSram (
  // VGA Side
  I_VGA_ADDR, 
  I_VGA_READ,
  O_VGA_DATA, 
  // GPU Side
  I_GPU_ADDR, 
  I_GPU_DATA, 
  I_GPU_READ, 
  I_GPU_WRITE, 
  O_GPU_DATA, 
  // SRAM Side
  I_SRAM_DQ,
  O_SRAM_ADDR,
  O_SRAM_UB_N,
  O_SRAM_LB_N,
  O_SRAM_WE_N,
  O_SRAM_CE_N,
  O_SRAM_OE_N
);

// VGA Side
input         I_VGA_READ;
input	 [17:0] I_VGA_ADDR;
output [15:0] O_VGA_DATA;

// GPU Side
input	 [17:0] I_GPU_ADDR;
input	 [15:0] I_GPU_DATA;
output [15:0] O_GPU_DATA;
input	        I_GPU_READ;
input	        I_GPU_WRITE;

// SRAM Side
inout	 [15:0] I_SRAM_DQ;
output [17:0] O_SRAM_ADDR;
output        O_SRAM_UB_N,
              O_SRAM_LB_N,
              O_SRAM_WE_N,
              O_SRAM_CE_N,
              O_SRAM_OE_N;
						
assign I_SRAM_DQ = O_SRAM_WE_N ? 16'hzzzz : (I_GPU_WRITE ? I_GPU_DATA : 16'hzzzz);
assign O_SRAM_ADDR = I_VGA_READ ? I_VGA_ADDR : ((I_GPU_READ | I_GPU_WRITE) ? I_GPU_ADDR : 0);
assign O_SRAM_WE_N = I_VGA_READ ? 1'b1 : (I_GPU_WRITE ? 1'b0: 1'b1);								
assign O_SRAM_CE_N = 1'b0;
assign O_SRAM_UB_N = 1'b0;
assign O_SRAM_LB_N = 1'b0;
assign O_SRAM_OE_N = I_GPU_WRITE ? 1'bx : 1'b0;

assign O_VGA_DATA = I_VGA_READ ? I_SRAM_DQ : 16'h0000;
assign O_GPU_DATA = I_GPU_READ ? I_SRAM_DQ : 16'h0000;

endmodule

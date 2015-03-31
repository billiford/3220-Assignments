library verilog;
use verilog.vl_types.all;
entity MultiSram is
    port(
        I_VGA_ADDR      : in     vl_logic_vector(17 downto 0);
        I_VGA_READ      : in     vl_logic;
        O_VGA_DATA      : out    vl_logic_vector(15 downto 0);
        I_GPU_ADDR      : in     vl_logic_vector(17 downto 0);
        I_GPU_DATA      : in     vl_logic_vector(15 downto 0);
        I_GPU_READ      : in     vl_logic;
        I_GPU_WRITE     : in     vl_logic;
        O_GPU_DATA      : out    vl_logic_vector(15 downto 0);
        I_SRAM_DQ       : inout  vl_logic_vector(15 downto 0);
        O_SRAM_ADDR     : out    vl_logic_vector(17 downto 0);
        O_SRAM_UB_N     : out    vl_logic;
        O_SRAM_LB_N     : out    vl_logic;
        O_SRAM_WE_N     : out    vl_logic;
        O_SRAM_CE_N     : out    vl_logic;
        O_SRAM_OE_N     : out    vl_logic
    );
end MultiSram;

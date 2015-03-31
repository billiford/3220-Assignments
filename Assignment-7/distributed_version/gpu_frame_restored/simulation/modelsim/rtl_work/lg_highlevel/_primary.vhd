library verilog;
use verilog.vl_types.all;
entity lg_highlevel is
    port(
        CLOCK_27        : in     vl_logic_vector(1 downto 0);
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(3 downto 0);
        SW              : in     vl_logic_vector(9 downto 0);
        HEX0            : out    vl_logic_vector(6 downto 0);
        HEX1            : out    vl_logic_vector(6 downto 0);
        HEX2            : out    vl_logic_vector(6 downto 0);
        HEX3            : out    vl_logic_vector(6 downto 0);
        LEDG            : out    vl_logic_vector(7 downto 0);
        LEDR            : out    vl_logic_vector(9 downto 0);
        VGA_HS          : out    vl_logic;
        VGA_VS          : out    vl_logic;
        VGA_R           : out    vl_logic_vector(3 downto 0);
        VGA_G           : out    vl_logic_vector(3 downto 0);
        VGA_B           : out    vl_logic_vector(3 downto 0);
        SRAM_DQ         : inout  vl_logic_vector(15 downto 0);
        SRAM_ADDR       : out    vl_logic_vector(17 downto 0);
        SRAM_UB_N       : out    vl_logic;
        SRAM_LB_N       : out    vl_logic;
        SRAM_WE_N       : out    vl_logic;
        SRAM_CE_N       : out    vl_logic;
        SRAM_OE_N       : out    vl_logic
    );
end lg_highlevel;

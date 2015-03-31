library verilog;
use verilog.vl_types.all;
entity VgaController is
    port(
        I_CLK           : in     vl_logic;
        I_RST_N         : in     vl_logic;
        I_RED           : in     vl_logic_vector(3 downto 0);
        I_GREEN         : in     vl_logic_vector(3 downto 0);
        I_BLUE          : in     vl_logic_vector(3 downto 0);
        O_ADDRESS       : out    vl_logic_vector(19 downto 0);
        O_COORD_X       : out    vl_logic_vector(9 downto 0);
        O_COORD_Y       : out    vl_logic_vector(9 downto 0);
        O_VGA_R         : out    vl_logic_vector(3 downto 0);
        O_VGA_G         : out    vl_logic_vector(3 downto 0);
        O_VGA_B         : out    vl_logic_vector(3 downto 0);
        O_VGA_SYNC      : out    vl_logic;
        O_VGA_BLANK     : out    vl_logic;
        O_VGA_CLOCK     : out    vl_logic;
        O_VGA_H_SYNC    : out    vl_logic;
        O_VGA_V_SYNC    : out    vl_logic
    );
end VgaController;

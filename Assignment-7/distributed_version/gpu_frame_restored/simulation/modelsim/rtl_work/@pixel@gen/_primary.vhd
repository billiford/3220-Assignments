library verilog;
use verilog.vl_types.all;
entity PixelGen is
    port(
        I_CLK           : in     vl_logic;
        I_RST_N         : in     vl_logic;
        I_DATA          : in     vl_logic_vector(15 downto 0);
        I_COORD_X       : in     vl_logic_vector(9 downto 0);
        I_COORD_Y       : in     vl_logic_vector(9 downto 0);
        O_VIDEO_ON      : out    vl_logic;
        O_NEXT_ADDR     : out    vl_logic_vector(17 downto 0);
        O_RED           : out    vl_logic_vector(3 downto 0);
        O_GREEN         : out    vl_logic_vector(3 downto 0);
        O_BLUE          : out    vl_logic_vector(3 downto 0)
    );
end PixelGen;

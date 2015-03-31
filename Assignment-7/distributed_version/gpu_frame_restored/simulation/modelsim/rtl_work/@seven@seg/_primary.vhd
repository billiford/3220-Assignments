library verilog;
use verilog.vl_types.all;
entity SevenSeg is
    port(
        \OUT\           : out    vl_logic_vector(6 downto 0);
        \IN\            : in     vl_logic_vector(3 downto 0)
    );
end SevenSeg;

library verilog;
use verilog.vl_types.all;
entity SignExtension is
    port(
        \In\            : in     vl_logic_vector(15 downto 0);
        \Out\           : out    vl_logic_vector(31 downto 0)
    );
end SignExtension;

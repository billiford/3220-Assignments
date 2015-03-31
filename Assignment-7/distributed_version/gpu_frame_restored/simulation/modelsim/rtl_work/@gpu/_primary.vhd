library verilog;
use verilog.vl_types.all;
entity Gpu is
    port(
        I_CLK           : in     vl_logic;
        I_RST_N         : in     vl_logic;
        I_VIDEO_ON      : in     vl_logic;
        I_GPU_DATA      : in     vl_logic_vector(15 downto 0);
        I_GSRValue      : in     vl_logic_vector(7 downto 0);
        I_GSRValue_Valid: in     vl_logic;
        I_VertexV1      : in     vl_logic_vector(63 downto 0);
        I_VertexV2      : in     vl_logic_vector(63 downto 0);
        I_VertexV3      : in     vl_logic_vector(63 downto 0);
        O_GPU_DATA      : out    vl_logic_vector(15 downto 0);
        O_GPU_ADDR      : out    vl_logic_vector(17 downto 0);
        O_GPU_READ      : out    vl_logic;
        O_GPU_WRITE     : out    vl_logic;
        O_GPUStallSignal: out    vl_logic
    );
end Gpu;

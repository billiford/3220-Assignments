library verilog;
use verilog.vl_types.all;
entity Writeback is
    port(
        I_CLOCK         : in     vl_logic;
        I_LOCK          : in     vl_logic;
        I_Opcode        : in     vl_logic_vector(7 downto 0);
        I_IR            : in     vl_logic_vector(31 downto 0);
        I_PC            : in     vl_logic_vector(15 downto 0);
        I_R15PC         : in     vl_logic_vector(15 downto 0);
        I_DestRegIdx    : in     vl_logic_vector(3 downto 0);
        I_DestVRegIdx   : in     vl_logic_vector(5 downto 0);
        I_DestValue     : in     vl_logic_vector(15 downto 0);
        I_CCValue       : in     vl_logic_vector(2 downto 0);
        I_VecSrc1Value  : in     vl_logic_vector(63 downto 0);
        I_VecDestValue  : in     vl_logic_vector(63 downto 0);
        I_MEM_Valid     : in     vl_logic;
        I_RegWEn        : in     vl_logic;
        I_VRegWEn       : in     vl_logic;
        I_CCWEn         : in     vl_logic;
        I_GPUStallSignal: in     vl_logic;
        O_LOCK          : out    vl_logic;
        O_WriteBackRegIdx: out    vl_logic_vector(3 downto 0);
        O_WriteBackVRegIdx: out    vl_logic_vector(5 downto 0);
        O_WriteBackData : out    vl_logic_vector(15 downto 0);
        O_PC            : out    vl_logic_vector(15 downto 0);
        O_CCValue       : out    vl_logic_vector(2 downto 0);
        O_VecDestValue  : out    vl_logic_vector(63 downto 0);
        O_GSRValue      : out    vl_logic_vector(7 downto 0);
        O_GSRValue_Valid: out    vl_logic;
        O_VertexV1      : out    vl_logic_vector(63 downto 0);
        O_VertexV2      : out    vl_logic_vector(63 downto 0);
        O_VertexV3      : out    vl_logic_vector(63 downto 0);
        O_RegWEn        : out    vl_logic;
        O_VRegWEn       : out    vl_logic;
        O_CCWEn         : out    vl_logic
    );
end Writeback;

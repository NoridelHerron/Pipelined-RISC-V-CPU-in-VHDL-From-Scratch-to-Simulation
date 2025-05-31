----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Pipeline_Types is

    -- NOP
    constant NOP    : std_logic_vector(31 downto 0) := x"00000013";
    -- OPCODE TYPE
    constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMME : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";
    
    constant ENABLE_FORWARDING : boolean := true;
    --constant ENABLE_FORWARDING : boolean := false;
    
    -- You can also define constants 
    constant DATA_WIDTH     : integer := 32;
    constant REG_ADDR_WIDTH : integer := 5;
    constant FUNCT3_WIDTH   : integer := 3;
    constant FUNCT7_WIDTH   : integer := 7;
    constant OPCODE_WIDTH   : integer := 7;
    constant FLAG_WIDTH     : integer := 4;
    constant DEPTH          : integer := 4;
    constant LOG2DEPTH      : integer := 2;
    constant IMM_WIDTH      : integer := 12;
    constant STALL_WIDTH    : integer := 2;
      
    -- Forwarding control type
    type ForwardingType is (
        FORWARD_NONE,       -- "00" 
        FORWARD_MEM_WB,     -- "01"
        FORWARD_EX_MEM      -- "10"
        );
        
    type numStall is (
        STALL_NONE,     -- "00" 
        STALL_MEM_WB,   -- "01"
        STALL_EX_MEM    -- "10"
        );
        
    type FORWARD is record
        A : ForwardingType;
        B : ForwardingType;
    end record;

    type reg_Type is record
        reg_data1   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- register source 1 value
        reg_data2   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- register source 2 value
    end record;

    type PipelineStages_Inst_PC is record
        instr       : std_logic_vector(DATA_WIDTH-1 downto 0);      -- instructions
        pc          : std_logic_vector(DATA_WIDTH-1 downto 0);      -- program counter
    end record;

    type ID_EX_Type is record
        op          : std_logic_vector(OPCODE_WIDTH-1 downto 0);    -- opcode  
        funct3      : std_logic_vector(FUNCT3_WIDTH-1 downto 0);    -- type of operation
        funct7      : std_logic_vector(FUNCT7_WIDTH-1 downto 0);    -- type of operation under funct3 
        store_rs2   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- for store 
        rs1         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);  -- register source 1
	    rs2         : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);  -- register source 2
        rd          : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);  -- register destination
        reg_write   : std_logic;
        mem_read    : std_logic;
        mem_write   : std_logic;
    end record;
    
    type EX_MEM_Type is record
        reg_data1   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- register source 1 value
        reg_data2   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- register source 2 value
        result      : std_logic_vector(DATA_WIDTH-1 downto 0);      -- ALU result
        flags       : std_logic_vector(FLAG_WIDTH-1 downto 0);      -- ZVNC Flags
        op          : std_logic_vector(OPCODE_WIDTH-1 downto 0);    -- opcode  
        rd          : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);  -- register destination
        store_rs2   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- for store 
        reg_write   : std_logic;
        mem_read    : std_logic;
        mem_write   : std_logic;
    end record;
    
    type MEM_WB_Type is record
        alu_result  : std_logic_vector(DATA_WIDTH-1 downto 0);      -- ALU result
        mem_result  : std_logic_vector(DATA_WIDTH-1 downto 0);      -- MEM result
        rd          : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);  -- register destination
        op          : std_logic_vector(OPCODE_WIDTH-1 downto 0);    -- opcode  
        reg_write   : std_logic;
        mem_read    : std_logic;    
        mem_write   : std_logic;
    end record;
    
    type WB_Type is record
        write       : std_logic;      -- ALU result
        data        : std_logic_vector(DATA_WIDTH-1 downto 0); 
        rd          : std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
    end record;

    -- Initialize all to 0
    constant EMPTY_inst_pc : PipelineStages_Inst_PC := (
        instr       => (others => '0'),
        pc          => (others => '0')
    );
    
    constant EMPTY_ID_EX_Type : ID_EX_Type := (
        op          => (others => '0'),
        funct3      => (others => '0'),
        funct7      => (others => '0'),  
        store_rs2   => (others => '0'),
        rs1         => (others => '0'),
        rs2         => (others => '0'),
        rd          => (others => '0'), 
        reg_write   => '0',
        mem_read    => '0',
        mem_write   => '0'
    );
    
    constant EMPTY_EX_MEM_Type : EX_MEM_Type := (
        reg_data1   => (others => '0'),
        reg_data2   => (others => '0'),
        result      => (others => '0'),
        flags       => (others => '0'),  
        op          => (others => '0'),
        rd          => (others => '0'),
        store_rs2   => (others => '0'),
        reg_write   => '0',
        mem_read    => '0',
        mem_write   => '0'     
    );
    
    constant EMPTY_MEM_WB_Type : MEM_WB_Type := (
        alu_result  => (others => '0'),
        mem_result  => (others => '0'),
        rd          => (others => '0'),
        op          => (others => '0'),  
        reg_write   => '0',
        mem_read    => '0',
        mem_write   => '0'     
    );
    
    constant EMPTY_WB_Type : WB_Type := (
        write       => '0',
        data        => (others => '0'),
        rd          => (others => '0')
    );
    
    constant EMPTY_reg_Type : reg_Type := (
        reg_data1   => (others => '0'),
        reg_data2   => (others => '0')
    );

    constant EMPTY_FORW_Type : FORWARD := (
        A   => FORWARD_NONE,
        B   => FORWARD_NONE
    );  
    
    constant INSERT_NOP : PipelineStages_Inst_PC := (
    pc    => (others => '0'),
    instr => x"00000013"  -- Real NOP!
    );

end package;
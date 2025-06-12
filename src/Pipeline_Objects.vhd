----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.const_Types.all;

package Pipeline_Types is

    -- Forwarding control type
    type ForwardingType is (
        FORWARD_NONE,       -- "00" 
        FORWARD_MEM_WB,     -- "01"
        FORWARD_EX_MEM      -- "10"
        );
        
   type control_types is (
        VALID, NOT_VALID, FLUSH, STALL, NONE
        );
        
    type FORWARD is record
        A           : ForwardingType;
        B           : ForwardingType;
    end record;
    
    type control_sig is record
        flush       : control_types;      
        stall       : control_types;    
    end record;

    type reg_Type is record
        reg_data1   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- register source 1 value
        reg_data2   : std_logic_vector(DATA_WIDTH-1 downto 0);      -- register source 2 value
    end record;

    type PipelineStages_Inst_PC is record
        valid       : control_types; 
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
        imm         : std_logic_vector(IMM_WIDTH-1 downto 0); 
        immJ        : std_logic_vector(19 downto 0);
        reg_write   : std_logic;
        mem_read    : std_logic;
        mem_write   : std_logic;
        br_target   : std_logic_vector(DATA_WIDTH-1 downto 0); 
        is_branch   : std_logic;
        ret_address : std_logic_vector(DATA_WIDTH-1 downto 0); 
    end record;
    
    type EX_MEM_Type is record
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

end package;
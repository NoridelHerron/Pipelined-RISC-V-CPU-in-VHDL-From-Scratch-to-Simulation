
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.Pipeline_Types.all;

package initialize_Types is
    
    -- Initialize all 
    constant EMPTY_inst_pc : PipelineStages_Inst_PC := (
        instr       => x"00000013",
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
        imm         => (others => '0'), 
        immJ        => (others => '0'), 
        reg_write   => '0',
        mem_read    => '0',
        mem_write   => '0',
        br_target   => (others => '0'), 
        is_branch   => '0',
        ret_address => (others => '0')
    );
    
    constant EMPTY_EX_MEM_Type : EX_MEM_Type := (  
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
    
    constant insert_NOP : ID_EX_Type := (
        op          => "0010011",
        funct3      => (others => '0'),
        funct7      => (others => '0'),  
        store_rs2   => (others => '0'),
        rs1         => (others => '0'),
        rs2         => (others => '0'),
        rd          => (others => '0'), 
        imm         => (others => '0'), 
        immJ        => (others => '0'), 
        reg_write   => '0',
        mem_read    => '0',
        mem_write   => '0',
        br_target   => (others => '0'), 
        is_branch   => '0',
        ret_address => (others => '0')
    );
      
end package;
-- Author      : Noridel Herron
-- Date        : 5/4/25
-- Description : Execution (EX) Stage with EX/MEM pipeline register
--               - Performs ALU operations
--               - Registers all outputs to support pipeline flow
--               - Supports future hazard detection and instruction tracing

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity EX_STAGE is
    Port (
            ID_EX_STAGE : in  PipelineStages_Inst_PC; 
            EX_MEM      : in  EX_MEM_Type;
            WB          : in  WB_Type; 
            ID_EX       : in  ID_EX_Type; 
            Forward     : in  FORWARD;      
            reg_in      : in  reg_Type;  
            EX          : out EX_MEM_Type;
            reg_out     : out reg_Type;
            is_flush    : out control_types         
          );
end EX_STAGE;

architecture behavior of EX_STAGE is

    -- Internal signals
    signal EX_reg      : EX_MEM_Type    := EMPTY_EX_MEM_Type;
    signal reg         : reg_Type       := EMPTY_reg_Type;
    signal Ci_Bi       : std_logic      := '0';  -- Carry-in or B-invert flag, can be expanded
    signal flush_reg   : control_types  := NONE; 
    signal is_branch   : std_logic      := '0'; 

begin
    
    -- Forward the right data of the register source
    FWD : entity work.Forwarding port map (
        ID_EX_STAGE     => ID_EX_STAGE,
        EX_MEM          => EX_MEM,
        WB              => WB,
        ID_EX           => ID_EX,
        Forward         => Forward,
        reg_in          => reg_in,
        reg_out         => reg
    );
    
    -- ALU computation
    alu_inst : entity work.ALU port map (
            A        => reg.reg_data1,
            B        => reg.reg_data2,
            Ci_Bi    => Ci_Bi,
            f3       => ID_EX.funct3,
            f7       => ID_EX.funct7,
            result   => EX_reg.result,
            Z_flag   => EX_reg.flags(FLAG_WIDTH - 1),
            V_flag   => EX_reg.flags(FLAG_WIDTH - 2),
            C_flag   => EX_reg.flags(FLAG_WIDTH - 3),
            N_flag   => EX_reg.flags(FLAG_WIDTH - 4)
        );

    is_branch <= ID_EX.is_branch; 
    
    -- determine if branch condition is true
    BRANCH : entity work.BRANCHING port map (
        reg             => reg,
        is_branch       => is_branch, 
        f3              => ID_EX.funct3,
        is_flush        => flush_reg
    ); 
 
    -- determine which flush instruction based on opcode type
    process (flush_reg, ID_EX.op)
    begin
        if ID_EX.op = B_TYPE then
            is_flush      <= flush_reg;  
        elsif ID_EX.op = J_TYPE then
            is_flush      <= FLUSH;  
        else
            is_flush      <= NONE; 
        end if;
    end process;
           
    reg_out         <= reg; -- this is for debugging purpose
    EX.result       <= ID_EX.ret_address when ID_EX.op = J_TYPE else EX_reg.result;
    EX.flags        <= EX_reg.flags;   
    EX.op           <= ID_EX.op;
    EX.rd           <= ID_EX.rd;
    EX.store_rs2    <= ID_EX.store_rs2;
    EX.reg_write    <= ID_EX.reg_write;
    EX.mem_read     <= ID_EX.mem_read;
    EX.mem_write    <= ID_EX.mem_write;
    
end behavior;
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
            reg         : in reg_Type;
            ID_EX       : in ID_EX_Type;
            EX          : out EX_MEM_Type
          );
end EX_STAGE;

architecture behavior of EX_STAGE is

    -- Internal signals
    signal EX_reg      : EX_MEM_Type    := EMPTY_EX_MEM_Type;
    signal Ci_Bi       : std_logic      := '0';  -- Carry-in or B-invert flag, can be expanded

begin
    
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
        
    EX.reg_data1  <= reg.reg_data1;
    EX.reg_data2  <= reg.reg_data2;
    EX.result     <= EX_reg.result;
    EX.flags      <= EX_reg.flags;   
    EX.op         <= ID_EX.op;
    EX.rd         <= ID_EX.rd;
    EX.store_rs2  <= ID_EX.store_rs2;
    EX.reg_write  <= ID_EX.reg_write;
    EX.mem_read   <= ID_EX.mem_read;
    EX.mem_write  <= ID_EX.mem_write;
end behavior;
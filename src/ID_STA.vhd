----------------------------------------------------------------------------------
-- Noridel Herron
-- 6/2/2025
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity ID_STA is
    Port ( 
            clk             : in  std_logic; 
            reset           : in  std_logic;  -- added reset input  
            ID_STAGE        : in  PipelineStages_Inst_PC;   
            WB              : in  WB_Type; 
            ID_EX           : in ID_EX_Type;
            EX_MEM          : in EX_MEM_Type;
            MEM_WB          : in MEM_WB_Type;
            ID              : out ID_EX_Type; 
            Forward_out     : out FORWARD;
            stall_out       : out numStall;
            reg_out         : out reg_Type
        );
end ID_STA;

architecture Behavioral of ID_STA is

signal ID_reg          : ID_EX_Type := EMPTY_ID_EX_Type;
begin
    
    DECODE : entity work.DECODER port map (
        clk             => clk,
        reset           => reset,
        IF_ID_STAGE     => ID_STAGE,
        WB              => WB,
        ID              => ID_reg, 
        reg_out         => reg_out 
    );
    
    HDU : entity work.Haz_det_unit port map (    
        ID              => ID_reg, 
        ID_EX           => ID_EX,
        EX_MEM          => EX_MEM, 
        MEM_WB          => MEM_WB, 
        Forward         => Forward_out,
        stall_out       => stall_out
    );
    
    ID <= ID_reg;

end Behavioral;

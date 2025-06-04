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

entity EX_STAG is
    Port ( 
            ID_EX_STAGE : in  PipelineStages_Inst_PC; 
            EX_MEM      : in  EX_MEM_Type;
            WB          : in  WB_Type; 
            ID_EX       : in  ID_EX_Type; 
            Forward     : in  FORWARD;      
            reg_in      : in  reg_Type;  
            EX          : out EX_MEM_Type      
        );
end EX_STAG;

architecture Behavioral of EX_STAG is

signal EX_reg     :  reg_Type   := EMPTY_reg_Type;

begin

    FWD : entity work.Forwarding port map (
        ID_EX_STAGE     => ID_EX_STAGE,
        EX_MEM          => EX_MEM,
        WB              => WB,
        ID_EX           => ID_EX,
        Forward         => Forward,
        reg_in          => reg_in,
        reg_out         => EX_reg
    );
    
    EXECUTION : entity work.EX_STAGE port map (
        reg             => EX_reg,
        ID_EX           => ID_EX,
        EX              => EX   
    );    

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity EX_TO_MEM is
    Port ( 
            clk             : in  std_logic; 
            reset           : in  std_logic;  -- added reset input
            EX_STAGE        : in  PipelineStages_Inst_PC; 
            EX              : in  EX_MEM_Type;
            EX_MEM_STAGE    : out PipelineStages_Inst_PC; 
            EX_MEM          : out EX_MEM_Type
          );
end EX_TO_MEM;

architecture Behavioral of EX_TO_MEM is

signal EX_MEM_STAGE_reg : PipelineStages_Inst_PC := EMPTY_inst_pc;
signal EX_MEM_reg       : EX_MEM_Type            := EMPTY_EX_MEM_Type;

begin
    process(clk, reset)
    begin
        if reset = '1' then  
            EX_MEM_STAGE_reg <= EMPTY_inst_pc;
            EX_MEM_reg       <= EMPTY_EX_MEM_Type;
        elsif rising_edge(clk) then
            EX_MEM_STAGE_reg <= EX_STAGE;
            EX_MEM_reg       <= EX;
        end if;    
    end process;

    EX_MEM_STAGE    <= EX_MEM_STAGE_reg;
    EX_MEM          <= EX_MEM_reg;

end Behavioral;

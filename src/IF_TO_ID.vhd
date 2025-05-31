----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;

entity IF_TO_ID is
    Port (
            clk             : in  std_logic; 
            reset           : in  std_logic;  
            stall           : in  numStall;   
            IF_STAGE        : in  PipelineStages_Inst_PC;
            IF_ID_STAGE     : out PipelineStages_Inst_PC
          );
end IF_TO_ID;

architecture Behavioral of IF_TO_ID is
    signal IF_ID_STAGE_reg : PipelineStages_Inst_PC := EMPTY_inst_pc;
begin

    process(clk, reset)
    begin
        if reset = '1' then  
            IF_ID_STAGE_reg <= EMPTY_inst_pc;
        elsif rising_edge(clk) then
            if stall = STALL_NONE then
                IF_ID_STAGE_reg <= IF_STAGE;  -- normal update
            else
                IF_ID_STAGE_reg <= IF_ID_STAGE_reg;  -- HOLD → prevents skip!!!
            end if;
        end if;
    end process;


    -- Drive the output port outside the process
    IF_ID_STAGE <= IF_ID_STAGE_reg;

end Behavioral;

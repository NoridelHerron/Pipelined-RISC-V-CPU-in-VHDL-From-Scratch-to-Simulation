----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity ID_TO_EX is
    Port (
            clk             : in  std_logic; 
            reset           : in  std_logic; 
            is_bubble       : in  control_sig;
            ID_STAGE        : in  PipelineStages_Inst_PC;
            ID              : in  ID_EX_Type;     
            ID_EX_STAGE     : out PipelineStages_Inst_PC;  
            ID_EX           : out ID_EX_Type 
          );
end ID_TO_EX;

architecture Behavioral of ID_TO_EX is

signal ID_EX_STAGE_reg : PipelineStages_Inst_PC := EMPTY_inst_pc;
signal ID_EX_reg       : ID_EX_Type             := EMPTY_ID_EX_Type;

begin
    process(clk, reset)
    begin
        if reset = '1' then
            ID_EX_STAGE_reg <= EMPTY_inst_pc;
            ID_EX_reg       <= EMPTY_ID_EX_Type;
        elsif rising_edge(clk) then
            if is_bubble.stall = STALL then
                -- STALL → insert NOP into ID_EX
                ID_EX_STAGE_reg   <= EMPTY_inst_pc;
                ID_EX_reg         <= insert_NOP;    
                   
            else
                if is_bubble.flush = FLUSH then   
                   ID_EX_STAGE_reg   <= EMPTY_inst_pc;
                   ID_EX_reg         <= insert_NOP;  
                     
                else   
                    -- Normal advance
                    if ID_STAGE.valid = VALID then
                        ID_EX_STAGE_reg <= ID_STAGE;
                        ID_EX_reg       <= ID;     
                    else
                        -- do nothing
                    end if;
                end if;
            end if;
        end if;
    end process;

    ID_EX_STAGE     <= ID_EX_STAGE_reg;
    ID_EX           <= ID_EX_reg;
end Behavioral;
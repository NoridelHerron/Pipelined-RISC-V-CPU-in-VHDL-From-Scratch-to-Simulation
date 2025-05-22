
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;

entity MEM_TO_WB is
    Port ( 
            clk             : in  std_logic; 
            reset           : in  std_logic;
            EX_MEM          : in EX_MEM_Type;
            MEM             : in MEM_WB_Type;
            EX_MEM_STAGE    : in PipelineStages_Inst_PC; 
            MEM_WB          : out MEM_WB_Type;
            MEM_WB_STAGE    : out PipelineStages_Inst_PC
          );
end MEM_TO_WB;

architecture Behavioral of MEM_TO_WB is

signal MEM_WB_STAGE_reg : PipelineStages_Inst_PC := EMPTY_inst_pc;
signal MEM_WB_reg       : MEM_WB_Type            := EMPTY_MEM_WB_Type;

begin
    process(clk, reset)
    begin
        if reset = '1' then  
             MEM_WB_STAGE_reg   <= EMPTY_inst_pc;
             MEM_WB_reg         <= EMPTY_MEM_WB_Type; 
        elsif rising_edge(clk) then
             MEM_WB_STAGE_reg   <= EX_MEM_STAGE;
             if MEM.mem_read = '1' then
                MEM_WB_reg.mem_result <= MEM.mem_result; 
             else
                MEM_WB_reg.alu_result <= EX_MEM.result;
             end if;  
        end if;    
    end process;

    MEM_WB_STAGE    <= MEM_WB_STAGE_reg;
    MEM_WB          <= MEM_WB_reg;
    
end Behavioral;

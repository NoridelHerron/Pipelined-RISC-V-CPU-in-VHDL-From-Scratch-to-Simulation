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
             MEM_WB_reg.mem_result <= MEM.mem_result; 
             MEM_WB_reg.alu_result <= EX_MEM.result; 
             MEM_WB_reg.rd         <= EX_MEM.rd;
             MEM_WB_reg.op         <= EX_MEM.op;
             MEM_WB_reg.reg_write  <= EX_MEM.reg_write;
             MEM_WB_reg.mem_read   <= EX_MEM.mem_read;
             MEM_WB_reg.mem_write  <= EX_MEM.mem_write;       
        end if;    
    end process;

    MEM_WB_STAGE    <= MEM_WB_STAGE_reg;
    MEM_WB          <= MEM_WB_reg;
    
end Behavioral;
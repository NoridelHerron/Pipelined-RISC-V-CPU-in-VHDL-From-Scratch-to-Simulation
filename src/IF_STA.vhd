----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity IF_STA is
    Port ( 
           clk             : in  std_logic; 
           reset           : in  std_logic;         
           stall           : in  numStall;                 
           IF_STAGE        : out PipelineStages_Inst_PC
         ); 

end IF_STA;

architecture behavior of IF_STA is

    -- we need a stable signal to hold the instruction before it gets send out
    signal temp_reg : PipelineStages_Inst_PC := EMPTY_inst_pc;
    
    begin
    -- PC update and stall logic
   process(clk)
    begin
        if reset = '1' then
            temp_reg.pc <= (others => '0');
        elsif rising_edge(clk) then  
            if stall /= STALL_NONE then
                temp_reg.pc <= temp_reg.pc;
            else
                temp_reg.pc <= std_logic_vector(unsigned(temp_reg.pc) + 4);
            end if;
        end if;
    end process;
    
    -- Get the instruction from memory
    MEM : entity work.INST_MEM port map (
            clk   => clk,
            reset => reset,
            addr  => temp_reg.pc, 
            instr => IF_STAGE.instr
        );
  
    -- Output to decoder
    IF_STAGE.pc     <= temp_reg.pc;
      
end behavior;
----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
-- No branch, flush, or stall handling
-- PC increments by 4 each cycle
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_STAGE is

    Port ( --inputs
           clk, rst         : in  std_logic;                           
           -- outputs
           instr_out        : out std_logic_vector(31 downto 0);  -- Instruction to be send for decoder
           pc_out           : out std_logic_vector(31 downto 0)   -- good for debugging, but this is optional
         ); 

end IF_STAGE;

architecture behavior of IF_STAGE is

    -- we need a stable signal to hold the instruction before it gets send out
    signal pc    : std_logic_vector(31 downto 0) := (others => '0');
    signal inst  : std_logic_vector(31 downto 0) := (others => '0');
    
    begin
    -- PC update and stall logic
   process(clk)
    begin
        if rst = '1' then  
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= std_logic_vector(unsigned(pc) + 4);
        end if;
    end process;
    
    -- Get the instruction from memory
    MEM : entity work.INST_MEM
        port map (
            addr  => pc, 
            instr => inst
        );
  
    -- Output to decoder
    pc_out         <= pc;
    instr_out      <= inst;
      
end behavior;


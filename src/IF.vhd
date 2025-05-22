----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
-- No branch, flush, or stall handling
-- PC increments by 4 each cycle
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF is
  Port ( --inputs
           clk, rst         : in  std_logic;                        
           num_stall_in     : in  std_logic_vector(1 downto 0);   -- For stalling
           -- outputs
           num_stall_out    : out  std_logic_vector(1 downto 0);  -- For stalling
           instr_out        : out std_logic_vector(31 downto 0);  -- Instruction to be send for decoder
           pc_out           : out std_logic_vector(31 downto 0)   -- good for debugging, but this is optional
        ); 
end IF;

architecture behavior of IF is

begin


end behavior;

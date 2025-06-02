----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;
use work.const_Types.all;

entity MEM_STA is 
    Port (   
            clk             : in  std_logic; 
            reset           : in  std_logic;  -- added reset input
            EX_MEM          : in  EX_MEM_Type;  -- Result from ALU  
            -- Outputs to MEM/WB pipeline register
            MEM             : out MEM_WB_Type
          );
end MEM_STA;

architecture Behavioral of MEM_STA is

signal mem_address    : std_logic_vector(LOG2DEPTH - 1 downto 0)    := (others => '0');

begin

    -- Extract address bits [11:2] for word-aligned access
    mem_address <= EX_MEM.result(LOG2DEPTH + 1 downto 2);

    -- Memory instance
    memory_block : entity work.DATA_MEM
        port map (
                    clk         => clk,
                    mem_read    => EX_MEM.mem_read,
                    mem_write   => EX_MEM.mem_write,
                    address     => mem_address,
                    write_data  => EX_MEM.store_rs2,
                    read_data   => MEM.mem_result
                );
   
end Behavioral;

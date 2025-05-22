----------------------------------------------------------------------------------
-- Noridel Herron
-- DataMemory.vhd
-- 5/5/2025
--
-- Description:
-- 32-bit word-addressable data memory module for use in the MEM stage of a 
-- pipelined CPU. Supports synchronous write and asynchronous read operations.
-- Can hold 1024 words (4KB total). Read and write controlled via mem_read and 
-- mem_write signals. 
--
-- Interface:
--   clk        : System clock input
--   mem_read   : Enables reading from memory
--   mem_write  : Enables writing to memory
--   address    : 10-bit memory address (word-indexed)
--   write_data : 32-bit data to be written on write
--   read_data  : 32-bit output from memory on read
--
-- Notes:
-- - Write occurs on rising clock edge when mem_write = '1'.
-- - Read is combinational when mem_read = '1'.
-- - On mem_read = '0', output is zeroed.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;

entity DATA_MEM is
    Generic( DEPTH      : natural    := DEPTH;
			 DATA_WIDTH : natural    := DATA_WIDTH;
			 LOG2DEPTH  : natural    := LOG2DEPTH
			);
    Port(
          clk        : in  std_logic; -- Clock input, used to trigger synchronous writes
          mem_read   : in  std_logic; -- Control signal - if '1', read from memory
          mem_write  : in  std_logic; -- Control signal - if '1', write to memory
          address    : in  std_logic_vector(LOG2DEPTH - 1 downto 0); -- 10-bit address (1024 words)
          write_data : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- 32-bit input - the data to write to memory
          read_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0) --  32-bit output - the data being read
         );
end DATA_MEM;

architecture Behavioral of DATA_MEM is
    -- Declare the memory_array and initialize each element to 0
    type memory_array is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0); 
    signal mem : memory_array := (others => (others => '0')); 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- if mem_write = '1' then write to the memory 
            if mem_write = '1' then               
                mem(to_integer(unsigned(address))) <= write_data;
            end if;
        end if;
    end process;

    read_data <= mem(to_integer(unsigned(address))) when mem_read = '1' else (others => '0');
        
end Behavioral;

----------------------------------------------------------------------------------
-- Noridel Herron
-- InstructionMemory.vhd
-- Created: [Insert today's date]
--
-- Description:
--   Standalone instruction memory module for my personal 5-stage RISC-V pipeline.
--   Stores up to 256 32-bit instructions in a simple word-addressable ROM.
--   Returns the instruction corresponding to the input PC address (word-aligned).
--
-- Design Notes:
--   - Used for simulation and testbench development.
--   - Instructions are currently hardcoded for quick testing.
--   - Future version may support file loading or external memory access.
--
-- Personal Project:
--   This is part of my custom CPU design and pipeline experiment.
--   Not intended for distribution or production use.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity INST_MEM is
    Port ( addr   : in  std_logic_vector(31 downto 0);  -- input: byte address to fetch instruction
           instr  : out std_logic_vector(31 downto 0)); -- output: instruction at the given address
end INST_MEM;

architecture behavior of INST_MEM is

    type memory_array is array (0 to 255) of std_logic_vector(31 downto 0);
    -- list of instructions
    signal rom : memory_array := (
        0   => x"00A00093", -- addi x1, x0, 10
        1   => x"01400113", -- addi x2, x0, 20   
        2   => x"00118333", -- add x6, x3, x1 
        3   => x"002082B3", -- add x5, x1, x2         
        others => x"00000013"   -- NOP (addi x0, x0, 0)
    );

begin
    -- Fetch instruction using word-aligned address (addr / 4)
    instr <= rom(to_integer(unsigned(addr(9 downto 2))));
end behavior;
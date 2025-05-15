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
        2   => x"00590193", -- addi x3, x18, 5
        3   => x"0000a983", -- lw x19, 0(x1)
        4   => x"00012a03", -- lw x20, 0(x2)
        5   => x"002082B3", -- add x5, x1, x2  
        6   => x"01400113", -- addi x2, x0, 20 
        7   => x"00118333", -- add x6, x3, x1 
        8   => x"0030ecb3", -- or x25, x1, x3    
        9   => x"0022fb33", -- and x22, x5, x2
        10  => x"0030cbb3", -- xor x23, x1, x3
        11  => x"00309c33", -- sll x24, x1, x3 
        12  => x"0030dcb3", -- xor x23, x1, x3  
        13  => x"4030dd33", -- sra x26, x1, x3
        14  => x"40308db3", -- sub x27, x1, x3 
        15  => x"0030ae33", -- slt x28, x1, x3
        16  => x"0030beb3", -- sltu x29, x1, x3  
        others => x"00000013"   
    );

begin
    -- Fetch instruction using word-aligned address (addr / 4)
    instr <= rom(to_integer(unsigned(addr(9 downto 2))));
end behavior;
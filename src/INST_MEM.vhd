----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Pipeline_Types.all;
use work.const_Types.all;

entity INST_MEM is
    Port (
            clk    : in  std_logic;        
            addr   : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- byte address input
            instr  : out std_logic_vector(DATA_WIDTH-1 downto 0)   -- instruction output
        );
end INST_MEM;

architecture read_only of INST_MEM is

    type memory_array is array (0 to 255) of std_logic_vector(31 downto 0);
    signal rom : memory_array := (
        0 => x"00A00093", -- addi x1, x0, 10
        1 => x"01400113", -- addi x2, x0, 20
       -- 2 => x"0000a183", -- lw x3, 0(x1)  <-- LOAD → WILL CAUSE STALL!!!
        2 => x"0080a183", -- lw x3, 8(x1)  <-- LOAD → WILL CAUSE STALL!!!
        3 => x"00118333", -- add x6, x3, x1 --> DEPENDENT on x3 → NOP will be inserted here!
        4 => x"002082B3",  -- add x5, x1, x2 (independent → should proceed normally)    
        others => x"00000013"  -- nop (ADDI x0, x0, 0)
    );

    signal instr_reg : std_logic_vector(31 downto 0);

begin

    -- synchronous read process
    process(clk)
    begin
        if rising_edge(clk) then  
            instr_reg <= rom(to_integer(unsigned(addr(9 downto 2))));
        end if;
    end process;

    instr <= instr_reg;

end read_only;
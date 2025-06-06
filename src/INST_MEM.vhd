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
        0  => x"00010A63", -- beq x2, x0, 10
        1  => x"00A00093", -- addi x1, x0, 10
        2  => x"01400193", -- addi x3, x0, 20  
        3  => x"00008063", -- beq x1, x0, 0 
        4  => x"00100213",  -- addi x4, x0, 1
        5  => x"00200293", -- addi x5, x0, 2
        6  => x"00300313", -- addi x6, x0, 3
        7  => x"00400393", -- addi x7, x0, 4
        8  => x"004000EF", -- jal x1, 4 
        9  => x"00500413",  -- addi x8, x0, 5
        10 => x"00600493",  -- addi x9, x0, 6 
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
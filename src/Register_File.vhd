----------------------------------------------------------------------------------
-- Noridel Herron
-- 32x32-bit Register File for CPU
-- 4/27/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;


entity RegisterFile is
    Generic( DATA_WIDTH     : natural    := DATA_WIDTH;
             REG_ADDR_WIDTH : natural    := REG_ADDR_WIDTH
			);
    Port ( -- inputs
           clk          : in  std_logic;
           -- Read or write
           write_enable : in  std_logic;
           -- For store
           write_addr   : in  std_logic_vector(REG_ADDR_WIDTH - 1 downto 0);
           -- For load
            write_data   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
           -- register addresses 
           read_addr1   : in  std_logic_vector(REG_ADDR_WIDTH - 1 downto 0);
           read_addr2   : in  std_logic_vector(REG_ADDR_WIDTH - 1 downto 0);
           -- output register values
           read_data1   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
           read_data2   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
end RegisterFile;

architecture Behavioral of RegisterFile is

    -- 32 registers, each 32 bits wide
    type reg_array is array (DATA_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal registers : reg_array := (others => (others => '0')); -- initialize all to 0

begin

    -- Write process
    process(clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                if write_addr /= ZERO_5bits then  -- prevent writing to x0
                    registers(to_integer(unsigned(write_addr))) <= write_data;
                end if;
            end if;
        end if;
    end process;

    -- Read assignments (asynchronous)
    read_data1 <= registers(to_integer(unsigned(read_addr1)));
    read_data2 <= registers(to_integer(unsigned(read_addr2)));

end Behavioral;

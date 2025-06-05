----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.const_Types.all;

package funct_Types is
    
    constant BEQ  : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "000";
    constant BNE  : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "001";
    constant BLT  : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "100";
    constant BGE  : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "101";
    constant BLTU : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "110";
    constant BGEU : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "111";
      
end package;
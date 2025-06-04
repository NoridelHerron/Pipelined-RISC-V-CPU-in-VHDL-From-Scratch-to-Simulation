----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.const_Types.all;

package funct_Types is
    
    type BRANCH_Type is (
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU
    );
      
end package;
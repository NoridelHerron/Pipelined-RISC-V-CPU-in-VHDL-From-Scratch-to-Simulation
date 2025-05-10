----------------------------------------------------------------------------------
-- Noridel Herron
-- Function Declaration
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package reusable_function is
    -- List of function
    function to_hexstring(sig: std_logic_vector) return string;
end package reusable_function;
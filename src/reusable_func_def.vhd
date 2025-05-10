----------------------------------------------------------------------------------
-- Noridel Herron
-- Function Declaration
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package body reusable_function is
    -- convert the instruction to hex
    function to_hexstring(sig: std_logic_vector) return string is
        variable hex_chars : string(1 to sig'length / 4);
        variable val : std_logic_vector(sig'range) := sig;
    begin
        for i in 0 to hex_chars'length - 1 loop
            case val((sig'length - 1 - (i * 4)) downto (sig'length - 4 - (i * 4))) is
                when "0000" => hex_chars(i+1) := '0'; when "0001" => hex_chars(i+1) := '1';
                when "0010" => hex_chars(i+1) := '2'; when "0011" => hex_chars(i+1) := '3';
                when "0100" => hex_chars(i+1) := '4'; when "0101" => hex_chars(i+1) := '5';
                when "0110" => hex_chars(i+1) := '6'; when "0111" => hex_chars(i+1) := '7';
                when "1000" => hex_chars(i+1) := '8'; when "1001" => hex_chars(i+1) := '9';
                when "1010" => hex_chars(i+1) := 'A'; when "1011" => hex_chars(i+1) := 'B';
                when "1100" => hex_chars(i+1) := 'C'; when "1101" => hex_chars(i+1) := 'D';
                when "1110" => hex_chars(i+1) := 'E'; when others   => hex_chars(i+1) := 'F';
            end case;
        end loop;
        return hex_chars;
    end function;
end package body reusable_function;
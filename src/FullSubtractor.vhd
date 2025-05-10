----------------------------------------------------------------------------------
-- Noridel Herron
-- FullAdder for ALU
-- 4/25/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullSubtractor is 
    Port ( X, Y, Bin : in std_logic; 
            Bout, D: out std_logic); 
end FullSubtractor; 

architecture Behavior of FullSubtractor is 
begin 
    Bout <= ((not X) and Y) or (Bin and not (X xor Y)); 
    D <= X xor Y xor Bin; 
end behavior;  

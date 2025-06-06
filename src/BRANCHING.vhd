
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;
use work.funct_Types.all;

entity BRANCHING is
  Port ( 
         flags           : in std_logic_vector(FLAG_WIDTH-1 downto 0); 
         is_branch       : in std_logic; 
         f3              : in std_logic_vector(FUNCT3_WIDTH-1 downto 0); 
         is_flush        : out std_logic  
        );
end BRANCHING;

architecture Behavioral of BRANCHING is

begin
    process (flags, is_branch, f3)
    begin
        if is_branch = '1' then
            case f3 is
                when BEQ  =>    
                    if flags(FLAG_WIDTH-1) = '1' then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                when BNE  =>
                    if flags(FLAG_WIDTH-1) /= '1' then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                when BLT  =>
                    if (flags(FLAG_WIDTH-2) xor flags(FLAG_WIDTH-4)) = '1' then 
                        is_flush <= '1';    
                    else
                        is_flush <= '0';
                    end if;
                when BGE  =>
                    if (flags(FLAG_WIDTH-2) xor flags(FLAG_WIDTH-4)) = '0' then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                
                when others => is_flush <= '0';
            end case;
        else
            is_flush <= '0';
        end if;
    end process;

end Behavioral;

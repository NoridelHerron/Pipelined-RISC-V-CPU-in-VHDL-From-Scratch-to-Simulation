
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
         reg             : in reg_Type;
         is_branch       : in std_logic; 
         f3              : in std_logic_vector(FUNCT3_WIDTH-1 downto 0); 
         is_flush        : out std_logic  
        );
end BRANCHING;

architecture Behavioral of BRANCHING is

begin
    process (reg, is_branch, f3)
    begin
        if is_branch = '1' then
            case f3 is
                when BEQ  =>    
                    if signed(reg.reg_data1) = signed(reg.reg_data2) then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                when BNE  =>
                    if signed(reg.reg_data1) /= signed(reg.reg_data2) then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                when BLT  =>
                    if signed(reg.reg_data1) < signed(reg.reg_data2) then
                        is_flush <= '1';    
                    else
                        is_flush <= '0';
                    end if;
                when BGE  =>
                    if signed(reg.reg_data1) > signed(reg.reg_data2) then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                when BLTU =>
                    if unsigned(reg.reg_data1) < unsigned(reg.reg_data2) then
                        is_flush <= '1';
                    else
                        is_flush <= '0';
                    end if;
                when BGEU =>
                    if unsigned(reg.reg_data1) > unsigned(reg.reg_data2) then
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

----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;

entity WB_STA is
    Port (
            MEM_WB          : in MEM_WB_Type;
            WB              : out WB_Type
         );
end WB_STA;

architecture Behavioral of WB_STA is

begin

    process(MEM_WB)
    begin
        if MEM_WB.reg_write = '1' and MEM_WB.mem_read = '1'then
            WB.data     <= MEM_WB.mem_result;       
        else
             WB.data     <= MEM_WB.alu_result;          
        end if;
        WB.rd       <= MEM_WB.rd;
        WB.write    <= MEM_WB.reg_write;
    end process;
    
end Behavioral;
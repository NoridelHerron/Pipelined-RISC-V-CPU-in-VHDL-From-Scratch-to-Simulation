
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
WB.data <= MEM_WB.alu_result when MEM_WB.ALU_write = '1' else MEM_WB.mem_result;
WB.write <= '1' when MEM_WB.op /= S_TYPE;
end Behavioral;

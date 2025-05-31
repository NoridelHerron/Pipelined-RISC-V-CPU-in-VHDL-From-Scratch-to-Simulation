----------------------------------------------------------------------------------
-- Noridel Herron
-- 05/31/25
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity Haz_det_unit is
    Port ( 
            ID              : in  ID_EX_Type;
            ID_EX           : in  ID_EX_Type;
            EX_MEM          : in  EX_MEM_Type;
            MEM_WB          : in  MEM_WB_Type;
       --     stall_in        : in  numStall;
            Forward         : out FORWARD; 
            stall_out       : out numStall
          );
end Haz_det_unit;

architecture Behavioral of Haz_det_unit is
signal stall            : numStall                     := STALL_NONE;
begin
    process (ID_EX, EX_MEM, MEM_WB, stall)
    begin   
        -- Forwarding logic, ALWAYS ACTIVE (you can deactivate it in my customized library)
        if EX_MEM.reg_write = '1' and EX_MEM.rd /= "00000" and EX_MEM.rd = ID_EX.rs1 then
            Forward.A <= FORWARD_EX_MEM;                     
        elsif MEM_WB.reg_write = '1' and MEM_WB.rd /= "00000" and MEM_WB.rd = ID_EX.rs1 then
            Forward.A <= FORWARD_MEM_WB;
        else
            Forward.A <= FORWARD_NONE; 
        end if;
        
        if EX_MEM.reg_write = '1' and EX_MEM.rd /= "00000" and EX_MEM.rd = ID_EX.rs2 then
            Forward.B <= FORWARD_EX_MEM;        
        elsif MEM_WB.reg_write = '1' and MEM_WB.rd /= "00000" and MEM_WB.rd = ID_EX.rs2 then
            Forward.B <= FORWARD_MEM_WB; 
        else
            Forward.B <= FORWARD_NONE;       
        end if;

        -- Stall logic for LOAD-USE hazard
        if ID_EX.mem_read = '1' and 
            (ID_EX.rd = ID.rs1 or ID_EX.rd = ID.rs2) then
            stall_out <= STALL_EX_MEM;
        elsif stall > STALL_NONE then
            if stall = STALL_EX_MEM then
                stall_out <= STALL_MEM_WB;
            else
                stall_out <= STALL_NONE;
            end if;
        end if;
        stall_out <= stall;
     end process;
        

end Behavioral;

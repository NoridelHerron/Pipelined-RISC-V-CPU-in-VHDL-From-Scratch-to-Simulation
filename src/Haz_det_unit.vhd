----------------------------------------------------------------------------------
-- Noridel Herron
-- 05/31/25
-- Last known working HDU version (Forwarding was working, Stall was almost working)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity Haz_det_unit is
    Port (  
        IF_ID_STAGE     : in PipelineStages_Inst_PC;
        ID_EX           : in ID_EX_Type;
        EX_MEM          : in EX_MEM_Type;
        MEM_WB          : in MEM_WB_Type;
        stall_in        : in numStall;
        Forward         : out FORWARD;
        stall_out       : out numStall
    );
end Haz_det_unit;

architecture Behavioral of Haz_det_unit is
signal rs1_addr  : std_logic_vector(REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal rs2_addr  : std_logic_vector(REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

    process (IF_ID_STAGE, EX_MEM, MEM_WB, stall_in)
    begin
        rs1_addr <= IF_ID_STAGE.instr(19 downto 15);
        rs2_addr <= IF_ID_STAGE.instr(24 downto 20); 
        -- Forwarding logic (always active)
        -- Forward A
        if EX_MEM.reg_write = '1' and EX_MEM.rd /= "00000" and EX_MEM.rd = rs1_addr then
            Forward.A <= FORWARD_EX_MEM;
        elsif MEM_WB.reg_write = '1' and MEM_WB.rd /= "00000" and MEM_WB.rd = rs1_addr then
            Forward.A <= FORWARD_MEM_WB;
        else
            Forward.A <= FORWARD_NONE;
        end if;

        -- Forward B
        if EX_MEM.reg_write = '1' and EX_MEM.rd /= "00000" and EX_MEM.rd = rs2_addr then
            Forward.B <= FORWARD_EX_MEM;
        elsif MEM_WB.reg_write = '1' and MEM_WB.rd /= "00000" and MEM_WB.rd = rs2_addr then
            Forward.B <= FORWARD_MEM_WB;
        else
            Forward.B <= FORWARD_NONE;
        end if;

        -- Stall logic for LOAD-USE hazard
        if ID_EX.mem_read = '1' and 
            (ID_EX.rd = IF_ID_STAGE.instr(19 downto 15) or ID_EX.rd = IF_ID_STAGE.instr(24 downto 20)) then
            stall_out <= STALL_EX_MEM;
        elsif stall_in = STALL_EX_MEM then
            stall_out <= STALL_NONE;
        else
            stall_out <= STALL_NONE;
        end if;
    end process;

end Behavioral;

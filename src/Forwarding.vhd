
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;

entity Forwarding is
    Port ( 
        ID_EX_STAGE : in  PipelineStages_Inst_PC; 
        EX_MEM      : in  EX_MEM_Type;
        WB          : in  WB_Type; 
        ID_EX       : in  ID_EX_Type; 
        Forward     : in  FORWARD;      
        reg_in      : in  reg_Type;  
        reg_out     : out reg_Type
    );
end Forwarding;

architecture mux of Forwarding is
begin

process (ID_EX_STAGE, Forward, EX_MEM, WB, reg_in, ID_EX)
begin

    -- Default: zero both outputs during stall (NOP is being injected)
    if ID_EX_STAGE.instr = NOP or ID_EX.op = B_TYPE or ID_EX.op = J_TYPE then
        reg_out.reg_data1 <= ZERO_32bits;
        reg_out.reg_data2 <= ZERO_32bits;

    else
        -- FORWARD A
        case Forward.A is
            when FORWARD_EX_MEM => 
                reg_out.reg_data1 <= EX_MEM.result;
            when FORWARD_MEM_WB => 
                reg_out.reg_data1 <= WB.data;
            when others => 
                reg_out.reg_data1 <= reg_in.reg_data1;
        end case;

        -- FORWARD B
        case Forward.B is
            when FORWARD_EX_MEM => 
                reg_out.reg_data2 <= EX_MEM.result;
            when FORWARD_MEM_WB => 
                reg_out.reg_data2 <= WB.data;
            when others =>
                -- Only select immediate if op requires it
                case ID_EX.op is
                    when R_TYPE => 
                        reg_out.reg_data2 <= reg_in.reg_data2;
                    when I_IMME | LOAD =>
                        reg_out.reg_data2 <= std_logic_vector(resize(signed(ID_EX.imm), 32));
                    when S_TYPE => 
                        reg_out.reg_data2 <= std_logic_vector(resize(signed(ID_EX.imm), 32));
                    when others => 
                        reg_out.reg_data2 <= (others => '0');
                end case;
        end case;

    end if;

end process;

end mux;

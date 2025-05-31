----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity Forwarding is
    Port ( 
            EX_MEM          : in  EX_MEM_Type;
            WB              : in  WB_Type; 
            ID_EX           : in ID_EX_Type; 
            Forward         : in FORWARD;      
            reg_in          : in reg_Type;  
            reg_out         : out reg_Type
        );
end Forwarding;

architecture mux of Forwarding is

begin
process (EX_MEM, WB, Forward)
begin
     -- FORWARD_A
    case Forward.A is
        when FORWARD_EX_MEM => reg_out.reg_data1 <= EX_MEM.result;
        when FORWARD_MEM_WB => reg_out.reg_data1 <= WB.data;         
        when others => reg_out.reg_data1 <= reg_in.reg_data1;
    end case;
        
        -- FORWARD_B
    case Forward.B is     
        when FORWARD_EX_MEM => reg_out.reg_data2 <= EX_MEM.result;    
        when FORWARD_MEM_WB => reg_out.reg_data2 <= WB.data;    
        when others => 
            case ID_EX.op is
                when R_TYPE => reg_out.reg_data2 <= reg_in.reg_data2;    
                when I_IMME => reg_out.reg_data2 <= std_logic_vector(resize(signed(ID_EX.funct7 & ID_EX.rs2), 32));             
                when LOAD => reg_out.reg_data2 <= std_logic_vector(resize(signed(ID_EX.funct7 & ID_EX.rs2), 32));      
                when S_TYPE => reg_out.reg_data2 <= std_logic_vector(resize(signed(ID_EX.funct7 & ID_EX.rd), 32));       
                when others => reg_out.reg_data2 <= (others => '0');  
            end case;
    end case;
end process;

end mux;
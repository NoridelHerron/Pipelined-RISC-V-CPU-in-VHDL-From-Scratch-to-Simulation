-- Noridel Herron
-- Date        : 05/03/2025
-- Description : Instruction Decode (ID) Stage for 5-Stage RISC-V Pipeline CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DECODER is
    Port (  -- inputs
            FORWARDING      : in  std_logic;
            instr_in        : in  std_logic_vector(31 downto 0);
            EX_MEM_rd       : in std_logic_vector(4 downto 0);
            EX_MEM_op       : in std_logic_vector(6 downto 0);
            MEM_WB_op       : in std_logic_vector(6 downto 0);
            MEM_WB_rd       : in std_logic_vector(4 downto 0);     
            Forward_A       : out std_logic_vector(1 downto 0);
            Forward_B       : out std_logic_vector(1 downto 0);
            num_NOP         : out std_logic_vector(1 downto 0);
            op              : out std_logic_vector(6 downto 0);
            f3              : out std_logic_vector(2 downto 0);
            f7              : out std_logic_vector(6 downto 0);   
            -- register destination
            rd              : out std_logic_vector(4 downto 0);     
            -- optional, but good for debugging
            rs1             : out std_logic_vector(4 downto 0);
            rs2             : out std_logic_vector(4 downto 0);
            -- for IF stage and for debugging 
            S_immediate     : out std_logic_vector(11 downto 0);
            I_immediate     : out std_logic_vector(11 downto 0)
        );
end DECODER;

architecture behavior of DECODER is

    -- optional, but makes my code cleaner 
    constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMM  : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";

begin  
    process (FORWARDING,instr_in, EX_MEM_rd, EX_MEM_op, MEM_WB_op, MEM_WB_rd)
    variable store_value        : std_logic_vector(31 downto 0) := (others => '0');
    variable opcode_v  : std_logic_vector(6 downto 0)  := (others => '0');
    variable rs1_temp  : std_logic_vector(4 downto 0)  := (others => '0');
    variable rs2_temp  : std_logic_vector(4 downto 0)  := (others => '0');
    variable rd_temp   : std_logic_vector(4 downto 0)  := (others => '0');
    variable f3_temp   : std_logic_vector(2 downto 0)  := (others => '0');
    variable f7_temp   : std_logic_vector(6 downto 0)  := (others => '0');
    variable S_imm     : std_logic_vector(11 downto 0) := (others => '0');
    variable I_imm     : std_logic_vector(11 downto 0) := (others => '0');
    begin 
        f7_temp   := instr_in(31 downto 25);
        rs2_temp  := instr_in(24 downto 20);
        rs1_temp  := instr_in(19 downto 15);
        f3_temp   := instr_in(14 downto 12);
        rd_temp   := instr_in(11 downto 7);
        opcode_v  := instr_in(6 downto 0);
        S_imm     := f7_temp & rd_temp;
        I_imm     := f7_temp & rs2_temp;  
    if FORWARDING = '1' then     
        if EX_MEM_op /= S_TYPE and EX_MEM_rd /= "00000" and EX_MEM_rd = rs1_temp then
            Forward_A <= "10";                     
        elsif MEM_WB_op /= S_TYPE and MEM_WB_rd /= "00000" and MEM_WB_rd = rs1_temp then
            Forward_A <= "01";
        else
            Forward_A <= "00"; 
        end if;
        
        -- Forwarding logic for rs2:
        -- If rs2 depends on a value being written back by one of the two previous instructions,
        -- forward from EX/MEM (priority) or MEM/WB as needed
        if EX_MEM_op /= S_TYPE and EX_MEM_rd /= "00000" and EX_MEM_rd = rs2_temp then
            Forward_B <= "10";     
        elsif MEM_WB_op /= S_TYPE and MEM_WB_rd /= "00000" and MEM_WB_rd = rs2_temp then
            Forward_B <= "01";  
        else
            Forward_B <= "00";       
        end if;
    else
        -- If forwarding is disabled, check for RAW (read-after-write) hazards.
        -- A stall is needed if either rs1 or rs2 matches the destination register
        -- of the previous (EX_MEM) or second previous (MEM_WB) instruction,
        -- and the register is not x0 (register 0).
        -- 
        -- Priority: EX_MEM hazards stall for 2 cycles ("11"), 
        --           MEM_WB hazards stall for 1 cycle ("10"), 
        --           otherwise propagate stall input.
        if EX_MEM_op /= S_TYPE and EX_MEM_rd /= "00000" and (EX_MEM_rd = rs1_temp or EX_MEM_rd = rs2_temp) then
           num_NOP <= "11";
        elsif MEM_WB_op /= S_TYPE and MEM_WB_rd /= "00000" and (MEM_WB_rd = rs1_temp or MEM_WB_rd = rs2_temp) then
           num_NOP <= "10";
        else
           num_NOP <= "00"; 
        end if;
    end if;
    
        rs1         <= rs1_temp;
        rs2         <= rs2_temp;
        rd          <= rd_temp;
        op          <= opcode_v;
        f3          <= f3_temp;
        f7          <= f7_temp;
        S_immediate <= S_imm;
        I_immediate <= I_imm;

    end process;
end behavior;

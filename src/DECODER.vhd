-- Noridel Herron
-- Date        : 05/03/2025
-- Description : Instruction Decode (ID) Stage for 5-Stage RISC-V Pipeline CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity DECODER is
    Port (  -- inputs
            clk             : in  std_logic; 
            reset           : in  std_logic;  -- added reset input   
            IF_ID_STAGE     : in  PipelineStages_Inst_PC;   
            WB              : in  WB_Type; 
            ID              : out ID_EX_Type;       
            reg_out         : out reg_Type
        );
end DECODER;

architecture behavior of DECODER is

signal ID_reg    : ID_EX_Type                                    := EMPTY_ID_EX_Type;
signal reg       : reg_Type                                      := EMPTY_reg_Type;
signal rs1_addr  : std_logic_vector(REG_ADDR_WIDTH - 1 downto 0) := ZERO_5bits;
signal rs2_addr  : std_logic_vector(REG_ADDR_WIDTH - 1 downto 0) := ZERO_5bits;
 
begin 
    REGISTER_UUT: entity work.RegisterFile
        port map ( clk            => clk,  
                   write_enable   => WB.write, 
                   write_addr     => WB.rd, 
                   write_data     => WB.data, 
                   read_addr1     => rs1_addr, 
                   read_addr2     => rs2_addr, 
                   read_data1     => reg.reg_data1, 
                   read_data2     => reg.reg_data2
                   );  
                   
    process (IF_ID_STAGE)
    variable ID_temp        : ID_EX_Type                              := EMPTY_ID_EX_Type;   
    variable imm_J          : std_logic_vector(IMMJ_WIDTH-1 downto 0) := (others => '0');
    variable imm_B          : std_logic_vector(IMM_WIDTH-1 downto 0)  := (others => '0');
    begin 
        if IF_ID_STAGE.instr = NOP then
            ID_temp := EMPTY_ID_EX_Type;    
        else
            ID_temp.funct7          := IF_ID_STAGE.instr(31 downto 25);
            ID_temp.rs2             := IF_ID_STAGE.instr(24 downto 20);
            ID_temp.rs1             := IF_ID_STAGE.instr(19 downto 15);
            ID_temp.funct3          := IF_ID_STAGE.instr(14 downto 12);
            ID_temp.rd              := IF_ID_STAGE.instr(11 downto 7);
            ID_temp.op              := IF_ID_STAGE.instr(6 downto 0);
    
            -- defaults
            ID_temp.br_target       := ZERO_32bits; 
            ID_temp.ret_address     := ZERO_32bits;     
            ID_temp.store_rs2       := ZERO_32bits; 
            imm_J                   := ZERO_20bits; 
            ID_temp.imm             := ZERO_12bits; 
            imm_B                   := ZERO_12bits; 
            ID_temp.mem_write       := '0';
            ID_temp.mem_read        := '0';
            ID_temp.reg_write       := '1';
            ID_temp.is_branch    := '0'; 
      
            case ID_temp.op is
                when I_IMME =>
                    ID_temp.imm          := ID_temp.funct7 & ID_temp.rs2;
                    ID_temp.funct7       := ZERO_7bits;
                    ID_temp.rs2          := ZERO_5bits;
                when LOAD   =>
                    ID_temp.imm          := ID_temp.funct7 & ID_temp.rs2;  
                    ID_temp.mem_read     := '1';
                    ID_temp.funct3       := ZERO_3bits;
                    ID_temp.funct7       := ZERO_7bits;
                    ID_temp.rs2          := ZERO_5bits;
                when S_TYPE =>
                    ID_temp.imm          := ID_temp.funct7 & ID_temp.rd;
                    ID_temp.mem_write    := '1';
                    ID_temp.reg_write    := '0';
                    ID_temp.store_rs2    := reg.reg_data2;
                    ID_temp.funct3       := ZERO_3bits;
                    ID_temp.funct7       := ZERO_7bits;
                    ID_temp.rd           := ZERO_5bits;
                when B_TYPE =>
                    ID_temp.is_branch    := '1'; 
                    ID_temp.reg_write    := '0';
                    imm_B                := ID_temp.funct7 & ID_temp.rd;
                    ID_temp.imm          := imm_B(11) & imm_B(0) & imm_B(10 downto 5) & imm_B(4 downto 1);
                    ID_temp.br_target    := std_logic_vector( signed(IF_ID_STAGE.pc) + resize(signed(ID_temp.imm & '0'), 32));
                    ID_temp.rd           := ZERO_5bits;
                    ID_temp.funct7       := ZERO_7bits;
                when J_TYPE =>
                    imm_J                := ID_temp.funct7 & ID_temp.rs2 & ID_temp.rs1 & ID_temp.funct3;  
                    ID_temp.immJ         := imm_J(19) & imm_J(7 downto 0) & imm_J(8) & imm_J(18 downto 9);
                    ID_temp.br_target    := std_logic_vector( signed(IF_ID_STAGE.pc) + resize(signed(ID_temp.immJ & '0'), 32));
                    ID_temp.ret_address  := std_logic_vector( signed(IF_ID_STAGE.pc) + 4);
                    ID_temp.funct7       := ZERO_7bits;
                    ID_temp.rs2          := ZERO_5bits;
                    ID_temp.rs1          := ZERO_5bits;
                    ID_temp.funct3       := ZERO_3bits;  
                    ID_temp.is_branch    := '1';     
                when others =>
                    ID_temp.reg_write    := '0';    
            end case;  
        end if;
        reg_out.reg_data1       <= reg.reg_data1;
        reg_out.reg_data2       <= reg.reg_data2;
        rs1_addr                <= ID_temp.rs1;
        rs2_addr                <= ID_temp.rs2;
        ID                      <= ID_temp;

    end process;
end behavior;
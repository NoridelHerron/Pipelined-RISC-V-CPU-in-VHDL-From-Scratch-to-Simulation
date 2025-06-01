-- Noridel Herron
-- Date        : 05/03/2025
-- Description : Instruction Decode (ID) Stage for 5-Stage RISC-V Pipeline CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

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
signal rs1_addr  : std_logic_vector(REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal rs2_addr  : std_logic_vector(REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
 
begin 
    REGISTER_UUT: entity work.RegisterFile
        port map ( clk            => clk, 
                   rst            => reset, 
                   write_enable   => WB.write, 
                   write_addr     => WB.rd, 
                   write_data     => WB.data, 
                   read_addr1     => rs1_addr, 
                   read_addr2     => rs2_addr, 
                   read_data1     => reg.reg_data1, 
                   read_data2     => reg.reg_data2
                   );  
    process (IF_ID_STAGE)
    variable ID_temp        : ID_EX_Type            := EMPTY_ID_EX_Type;   
    begin 
    
        ID_temp.funct7   := IF_ID_STAGE.instr(31 downto 25);
        ID_temp.rs2      := IF_ID_STAGE.instr(24 downto 20);
        ID_temp.rs1      := IF_ID_STAGE.instr(19 downto 15);
        ID_temp.funct3   := IF_ID_STAGE.instr(14 downto 12);
        ID_temp.rd       := IF_ID_STAGE.instr(11 downto 7);
        ID_temp.op       := IF_ID_STAGE.instr(6 downto 0);

        -- defaults
        ID_temp.store_rs2 := (others => '0'); 
        ID_temp.mem_write := '0';
        ID_temp.mem_read  := '0';
        ID_temp.reg_write := '1';
  
        if ID_temp.op = LOAD then 
            ID_temp.mem_read := '1';
        end if;
    
        if ID_temp.op = S_TYPE then 
            ID_temp.mem_write := '1';
            ID_temp.store_rs2 := reg.reg_data2;
        end if;   
    
        rs1_addr                <= ID_temp.rs1;
        rs2_addr                <= ID_temp.rs2;
        ID.rs1                  <= ID_temp.rs1;
        ID.rs2                  <= ID_temp.rs2;
        reg_out.reg_data1       <= reg.reg_data1;
        reg_out.reg_data2       <= reg.reg_data2;
        ID.store_rs2            <= ID_temp.store_rs2;
        ID.op                   <= ID_temp.op;
        ID.funct3               <= ID_temp.funct3;
        ID.funct7               <= ID_temp.funct7;
        ID.rd                   <= ID_temp.rd;
        ID.reg_write            <= ID_temp.reg_write;
        ID.mem_read             <= ID_temp.mem_read;
        ID.mem_write            <= ID_temp.mem_write;
    end process;
end behavior;
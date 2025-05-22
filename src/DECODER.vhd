-- Noridel Herron
-- Date        : 05/03/2025
-- Description : Instruction Decode (ID) Stage for 5-Stage RISC-V Pipeline CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity DECODER is
    Generic( REG_ADDR_WIDTH : natural    := REG_ADDR_WIDTH;
             DATA_WIDTH     : natural    := DATA_WIDTH
            );
    Port (  -- inputs
            clk             : in  std_logic; 
            reset           : in  std_logic;  -- added reset input
            IF_ID_STAGE     : in  PipelineStages_Inst_PC; 
            EX_MEM          : in  EX_MEM_Type;
            MEM_WB          : in  MEM_WB_Type;
            WB              : in  WB_Type; 
            ID              : out ID_EX_Type; 
            Forward_A       : out ForwardingType; 
            Forward_B       : out ForwardingType; 
            stall           : out numStall
        );
end DECODER;

architecture behavior of DECODER is

signal ID_reg    : ID_EX_Type                                    := EMPTY_ID_EX_Type;
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
                   read_data1     => ID_reg.reg_data1, 
                   read_data2     => ID_reg.reg_data2
                   );  
    process (IF_ID_STAGE, EX_MEM, MEM_WB, WB)
    variable ID_temp        : ID_EX_Type            := EMPTY_ID_EX_Type;
    variable ForwardA       : ForwardingType        := FORWARD_NONE;
    variable ForwardB       : ForwardingType        := FORWARD_NONE;
    
    begin 
        ID_temp.funct7   := IF_ID_STAGE.instr(31 downto 25);
        ID_temp.rs2      := IF_ID_STAGE.instr(24 downto 20);
        ID_temp.rs1      := IF_ID_STAGE.instr(19 downto 15);
        ID_temp.funct3   := IF_ID_STAGE.instr(14 downto 12);
        ID_temp.rd       := IF_ID_STAGE.instr(11 downto 7);
        ID_temp.op       := IF_ID_STAGE.instr(6 downto 0);

        ID_temp.reg_write := '1';
        ID_temp.store_rs2 := (others => '0');
        
    if ENABLE_FORWARDING then     
        if EX_MEM.op /= S_TYPE and EX_MEM.rd /= "00000" and EX_MEM.rd = ID_temp.rs1 then
            ForwardA := FORWARD_EX_MEM;                     
        elsif MEM_WB.op /= S_TYPE and MEM_WB.rd /= "00000" and MEM_WB.rd = ID_temp.rs1 then
            ForwardA := FORWARD_MEM_WB;
        else
            ForwardA := FORWARD_NONE; 
        end if;
        Forward_A <= ForwardA;
        
        if EX_MEM.op /= S_TYPE and EX_MEM.rd /= "00000" and EX_MEM.rd = ID_temp.rs2 then
            ForwardB := FORWARD_EX_MEM;        
        elsif MEM_WB.op /= S_TYPE and MEM_WB.rd /= "00000" and MEM_WB.rd = ID_temp.rs2 then
            ForwardB := FORWARD_MEM_WB; 
        else
            ForwardB := FORWARD_NONE;       
        end if;
        Forward_B <= ForwardB;
    else
        if EX_MEM.op /= S_TYPE and EX_MEM.rd /= "00000" and (EX_MEM.rd = ID_temp.rs1 or EX_MEM.rd = ID_temp.rs2) then
           stall <= STALL_EX_MEM;
        elsif MEM_WB.op /= S_TYPE and MEM_WB.rd /= "00000" and (MEM_WB.rd = ID_temp.rs1 or MEM_WB.rd = ID_temp.rs2) then
           stall <= STALL_MEM_WB;
        else
           stall <= STALL_NONE;
        end if;
    end if;
    
    if ENABLE_FORWARDING then
    
        -- FORWARD_A
        case ForwardA is
            when FORWARD_NONE =>
                ID_temp.reg_data1 := ID_reg.reg_data1;
        
            when FORWARD_EX_MEM =>
                ID_temp.reg_data1 := EX_MEM.result;
        
            when FORWARD_MEM_WB =>
                ID_temp.reg_data1 := WB.data;         
        
            when others =>
                ID_temp.reg_data1 := (others => '0');
        end case;

        
        case ForwardB is
            when FORWARD_NONE =>
                case ID_temp.op is
                    when R_TYPE => -- R-type: use second register value
                        ID_temp.reg_data2 := ID_reg.reg_data2;
                        
                    when I_IMME =>  -- I-type: immediate is in bits [31:20], sign-extended 
                        ID_temp.reg_data2 := std_logic_vector(resize(signed(ID_temp.funct7 & ID_temp.rs2), 32));
                        
                    when LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                        ID_temp.reg_data2 := std_logic_vector(resize(signed(ID_temp.funct7 & ID_temp.rs2), 32));
                        ID_temp.mem_write := '1';
                        
                    when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                        ID_temp.reg_data2 := std_logic_vector(resize(signed(ID_temp.funct7 & ID_temp.rd), 32));
                        ID.store_rs2  <= ID_reg.reg_data2;
                        ID_temp.mem_read  := '1';
                        ID_temp.reg_write := '0';
                    when others => 
                        ID_temp.reg_data2 := (others => '0');
                end case;
            when FORWARD_EX_MEM => -- from MEM_WB stage
                ID_temp.reg_data2 := EX_MEM.result;
                
            when FORWARD_MEM_WB => -- from EX_MEM stage
                ID_temp.reg_data2 := WB.data;    
            when others => 
                ID_temp.reg_data2 := (others => '0');
        end case;
        
    else
        ID_temp.reg_data1 := ID_reg.reg_data1;
        case ID_temp.op is
            when R_TYPE => -- R-type: use second register value
                ID_temp.reg_data2 := ID_reg.reg_data2;
                
            when I_IMME =>  -- I-type: immediate is in bits [31:20], sign-extended 
                ID_temp.reg_data2 := std_logic_vector(resize(signed(ID_temp.funct7 & ID_temp.rs2), 32));
                
            when LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                ID_temp.reg_data2 := std_logic_vector(resize(signed(ID_temp.funct7 & ID_temp.rs2), 32));
                ID_temp.mem_write := '1';
                
            when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                ID_temp.reg_data2 := std_logic_vector(resize(signed(ID_temp.funct7 & ID_temp.rd), 32));
                ID_temp.store_rs2  := ID_reg.reg_data2;
                ID_temp.mem_read  := '1';
                ID_temp.reg_write := '0';
            when others => 
                ID_temp.reg_data2 := (others => '0');
        end case;
    end if;   
    
    rs1_addr        <= ID_temp.rs1;
    rs2_addr        <= ID_temp.rs2;
    ID.rs1          <= ID_temp.rs1;
    ID.rs2          <= ID_temp.rs2;
    ID.reg_data1    <= ID_temp.reg_data1;
    ID.reg_data2    <= ID_temp.reg_data2;
    ID.store_rs2    <= ID_temp.store_rs2;
    ID.op           <= ID_temp.op;
    ID.funct3       <= ID_temp.funct3;
    ID.funct7       <= ID_temp.funct7;
    ID.rd           <= ID_temp.rd;
    ID.reg_write    <= ID_temp.reg_write;
    ID.mem_read     <= ID_temp.mem_read;
    ID.mem_write    <= ID_temp.mem_write;
    Forward_A       <= ForwardA;
    Forward_B       <= ForwardB;
    end process;
end behavior;
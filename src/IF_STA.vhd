----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity IF_STA is
    Port ( 
           clk             : in  std_logic; 
           reset           : in  std_logic;         
           stall           : in  numStall;                 
           IF_STAGE        : out PipelineStages_Inst_PC
         ); 

end IF_STA;

architecture behavior of IF_STA is
    
    signal pc_fetch         : std_logic_vector(DATA_WIDTH-1 downto 0) := ZERO_32bits;
    signal instr_fetched    : std_logic_vector(DATA_WIDTH-1 downto 0) := ZERO_32bits;
    signal temp_reg         : PipelineStages_Inst_PC                  := EMPTY_inst_pc;
    
begin

    process(clk)
    begin
        if reset = '1' then
        
            pc_fetch     <= ZERO_32bits;
            temp_reg.pc  <= ZERO_32bits;
            temp_reg.instr  <= NOP;
            
        elsif rising_edge(clk) then
        
            if stall = STALL_NONE then
                -- make sure that the pc_fetch is in phase with instr_fetch, debugging purpose
                temp_reg.pc     <= pc_fetch; 
                temp_reg.instr  <= instr_fetched;
                pc_fetch        <= std_logic_vector(unsigned(pc_fetch) + 4);
            end if;
            
        end if;
    end process;

    MEM : entity work.INST_MEM port map (
        clk   => clk,
        addr  => pc_fetch,
        instr => instr_fetched
    );

    IF_STAGE <= temp_reg;
end behavior;

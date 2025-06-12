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
           is_bubble       : in  control_sig;
           br_target       : in  std_logic_vector(DATA_WIDTH-1 downto 0);         
           IF_STAGE        : out PipelineStages_Inst_PC; 
           after_flush     : out control_Types
         ); 

end IF_STA;

architecture behavior of IF_STA is
    
    signal pc_fetch         : std_logic_vector(DATA_WIDTH-1 downto 0) := ZERO_32bits;
    signal pc_current       : std_logic_vector(DATA_WIDTH-1 downto 0) := ZERO_32bits;
    signal instr_reg        : std_logic_vector(DATA_WIDTH-1 downto 0) := ZERO_32bits;
    signal instr_fetched    : std_logic_vector(DATA_WIDTH-1 downto 0) := ZERO_32bits;
    signal temp_reg         : PipelineStages_Inst_PC                  := EMPTY_inst_pc;

begin

    process(clk)
    begin
        if reset = '1' then
            pc_fetch        <= ZERO_32bits;
            pc_current      <= pc_fetch; 
            temp_reg        <= EMPTY_inst_pc;
            
        elsif rising_edge(clk) then
            
        
            if is_bubble.flush = FLUSH then      
                pc_fetch        <= br_target;  
                temp_reg        <= EMPTY_inst_pc;
                pc_current      <= pc_fetch; 
                instr_reg       <= NOP;
               
            elsif is_bubble.stall = NONE then   
                -- normal flow
                if pc_fetch = ZERO_32bits or pc_current = ZERO_32bits then
                    temp_reg.valid  <= NOT_VALID;       
                else  
                    temp_reg.valid  <= VALID;   
                end if; 
                
                instr_reg       <= instr_fetched;
                pc_fetch        <= std_logic_vector(unsigned(pc_fetch) + 4);
                pc_current      <= pc_fetch;
                temp_reg.pc     <= pc_current;
                temp_reg.instr  <= instr_reg; 
                
             else
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
----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
-- No branch, flush, or stall handling
-- PC increments by 4 each cycle
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_STAGE is
    Port ( -- Inputs
           clk, rst         : in  std_logic;      
           --bubble_in        : in  std_logic;                       
           num_stall_in     : in  std_logic_vector(1 downto 0); 
           -- Outputs
           instr_out        : out std_logic_vector(31 downto 0);   
           pc_out           : out std_logic_vector(31 downto 0)  
         ); 
end IF_STAGE;

architecture behavior of IF_STAGE is

    component INST_MEM
        Port ( addr   : in  std_logic_vector(31 downto 0);  
               instr  : out std_logic_vector(31 downto 0));
    end component;

    signal pc        : std_logic_vector(31 downto 0) := (others => '0');
    signal addr      : std_logic_vector(31 downto 0) := (others => '0');
    signal inst      : std_logic_vector(31 downto 0);
    signal stall_cnt : integer := 0;
    signal NOP       : std_logic_vector(31 downto 0) := x"00000013";

begin
    
    -- PC update and stall logic
    process(clk)
    begin
        -- PC update process: triggered on rising edge of clock
        if rising_edge(clk) then
            if rst = '1' then
                pc        <= (others => '0');
                stall_cnt <= 0;
            elsif num_stall_in /= "00" then
                case num_stall_in is
                    when "00" => stall_cnt <= 0;
                    when "01" => stall_cnt <= 1; 
                    when "11" => stall_cnt <= 2;
                    when "10" => stall_cnt <= 3;
                    when others => null;      
                end case;
                if stall_cnt > 0 then
                    stall_cnt <= stall_cnt - 1;
                end if;   
            else
                -- increment PC by 4 (next instruction)
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;
        end if;
    end process;

    -- Get the instruction from the memory based on the PC
    MEM : INST_MEM port map (pc, inst);
    
    -- Clean, separate driver
    instr_out <= NOP when stall_cnt > 0 else inst;
    pc_out    <= pc;

end behavior;

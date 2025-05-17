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

    Port ( --inputs
           clk, rst         : in  std_logic;                        
           num_stall_in     : in  std_logic_vector(1 downto 0);   -- For stalling
           -- outputs
           num_stall_out    : out  std_logic_vector(1 downto 0);  -- For stalling
           instr_out        : out std_logic_vector(31 downto 0);  -- Instruction to be send for decoder
           pc_out           : out std_logic_vector(31 downto 0)   -- good for debugging, but this is optional
         ); 

end IF_STAGE;

architecture behavior of IF_STAGE is

    component INST_MEM -- combinational
        Port ( addr   : in  std_logic_vector(31 downto 0);  -- input: byte address to fetch instruction
               instr  : out std_logic_vector(31 downto 0)); -- output: instruction at the given address
    end component;

    -- we need a stable signal to hold the instruction before it gets send out
    signal pc : std_logic_vector(31 downto 0) := (others => '0');
    signal inst : std_logic_vector(31 downto 0);
begin
    -- PC update and stall logic
   process(clk)

    begin
        -- PC update process: triggered on rising edge of clock
        if rising_edge(clk) then
            if rst = '1' then
                pc <= (others => '0');
            else
                -- increment PC by 4 (next instruction)
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;
        end if;
    end process;

    -- Get the instruction from the memory based on the PC
    MEM : INST_MEM 
        port map ( addr  => pc, 
                   instr => inst);
    
    -- output that goes to the decoder
    instr_out <= inst;     -- Clean, separate driver
    pc_out <= pc;
    num_stall_out <= num_stall_in;
end behavior;


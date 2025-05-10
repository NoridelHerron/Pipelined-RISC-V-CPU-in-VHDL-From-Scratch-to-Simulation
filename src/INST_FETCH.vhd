----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
-- No branch, flush, or stall handling
-- PC increments by 4 each cycle
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity INST_FETCH is
    Port ( clk, rst  : in  std_logic;   
           instr_out : out std_logic_vector(31 downto 0); -- output instr_out- 32-bit instruction forwarded to Decode stage
           pc_out    : out std_logic_vector(31 downto 0) );
end INST_FETCH;

architecture behavior of INST_FETCH is

    component INST_MEM
        Port ( addr   : in  std_logic_vector(31 downto 0);  -- input: byte address to fetch instruction
               instr  : out std_logic_vector(31 downto 0)); -- output: instruction at the given address
    end component;

    -- Internal signal for program counter (PC)
    signal pc : std_logic_vector(31 downto 0) := (others => '0');
    signal inst : std_logic_vector(31 downto 0);


begin
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
    MEM : INST_MEM port map (pc, inst);
    
    instr_out <= inst;     -- Clean, separate driver
    pc_out <= pc;

end behavior;

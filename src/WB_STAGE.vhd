
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- WB Stage: Selects final data to write back to the register file and passes control signals

entity WB_STAGE is
    Port (
        -- Inputs from MEM/WB pipeline register    
        ALU_in         : in  std_logic_vector(31 downto 0);  -- ALU result from EX stage (e.g., for add, addi, jal, etc.)
        mem_in         : in  std_logic_vector(31 downto 0);  -- Data read from memory (for load instructions)
        reg_write_in   : in  std_logic;                      
        MemToReg_in    : in  std_logic;                     

        -- Outputs to register file or decode stage
        data_out       : out std_logic_vector(31 downto 0);  -- Final data to be written to register file
        reg_write_out  : out std_logic                       -- Write enable (passed through)
    );
end WB_STAGE;

architecture behavior of WB_STAGE is
begin

    --------------------------------------------------------------------------
    -- Select the correct source for register write-back:
    -- - If MemToReg is '1', the instruction is a load => use memory data
    -- - If MemToReg is '0', use ALU result (for R-type, I-type, jal, etc.)
    --------------------------------------------------------------------------
    data_out <= mem_in when MemToReg_in = '1' else ALU_in;

    --------------------------------------------------------------------------
    -- Pass through the control signals and register destination to maintain
    -- synchronization with the pipeline
    --------------------------------------------------------------------------
    reg_write_out <= reg_write_in;   -- Write enable flag

end behavior;

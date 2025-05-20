--  Title       : MEM_STAGE.vhd
--  Description : Memory stage of a 5-stage pipelined RISC-V processor.
--                Interfaces with DATA_MEM to handle load/store instructions.
--                Converts ALU result into memory address and performs memory
--                read/write operations based on control signals.
--
--  Author      : Noridel Herron
--  Date        : May 6, 2025
--  Dependencies: DATA_MEM.vhd
--
--  Notes       : 
--    - Assumes word-aligned addressing (ALU result shifted by 2 bits).
--    - mem_read and mem_write should be mutually exclusive.
--    - For ALU operations (e.g. R/I-type), mem_out simply passes alu_result forward.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_STAGE is
    Port (
        -- Inputs from EX/MEM pipeline register
        clk            : in  std_logic;
        alu_result     : in  std_logic_vector(31 downto 0);  -- Result from ALU
        write_data     : in  std_logic_vector(31 downto 0); -- From EX stage (store)    
        op_in          : in  std_logic_vector(6 downto 0);   -- Instruction opcode

        -- Outputs to MEM/WB pipeline register
        mem_out        : out std_logic_vector(31 downto 0);  -- Data to write back to register file
        reg_write_out  : out std_logic;                      -- Register write enable
        mem_reg_out    : out std_logic                      -- Register write enable  
    );
end MEM_STAGE;

architecture behavior of MEM_STAGE is

    signal mem_address    : std_logic_vector(9 downto 0)    := (others => '0');
    signal mem_read_sig   : std_logic                       := '0';
    signal mem_write_sig  : std_logic                       := '0';
    signal mem_read_data  : std_logic_vector(31 downto 0)   := (others => '0');

    -- Opcode constants for easier matching
    constant R_TYPE : std_logic_vector(6 downto 0)          := "0110011";
    constant I_IMM  : std_logic_vector(6 downto 0)          := "0010011";
    constant LOAD   : std_logic_vector(6 downto 0)          := "0000011";
    constant S_TYPE : std_logic_vector(6 downto 0)          := "0100011";

begin
    
    -- Extract address bits [11:2] for word-aligned access
    mem_address <= alu_result(11 downto 2);

    -- Control logic to determine memory operation
    mem_read_sig  <= '1' when op_in = LOAD else '0';
    mem_write_sig <= '1' when op_in = S_TYPE else '0';

    -- Memory instance
    memory_block : entity work.DATA_MEM
        port map (
            clk         => clk,
            mem_read    => mem_read_sig,
            mem_write   => mem_write_sig,
            address     => mem_address,
            write_data  => write_data,
            read_data   => mem_read_data
        );

    -- Determine output to write-back stage
    process(op_in, alu_result, mem_read_data)
    begin
        if op_in = LOAD then
            mem_out <= mem_read_data;  -- Load
        else
            mem_out <= alu_result;     -- Pass ALU result forward for R/I-type
        end if;
    end process;

    -- Pass-through instruction and destination register
    reg_write_out <= '1' when op_in = R_TYPE or op_in = I_IMM;
    mem_reg_out <= '1' when op_in = LOAD else '0';

end behavior;

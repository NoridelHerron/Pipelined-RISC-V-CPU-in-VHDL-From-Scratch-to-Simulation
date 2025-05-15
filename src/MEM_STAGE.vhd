----------------------------------------------------------------------------------
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
--    - For ALU operations (op = "001"), mem_out simply passes alu_result forward.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_STAGE is
    Port (  -- inputs
            clk           : in  std_logic;  
            -- input from EX/MEM REGISTERs
            alu_result    : in  std_logic_vector(31 downto 0); -- From EX stage
            write_data    : in  std_logic_vector(31 downto 0); -- From EX stage (store)
            op_in         : in  std_logic_vector(2 downto 0);  -- Control signal
            rd_in         : in  std_logic_vector(4 downto 0);  -- Destination register
            -- Outputs to MEM/WB REGISTERs
            mem_out       : out std_logic_vector(31 downto 0); -- Load data or passthrough ALU result
            reg_write_out : out std_logic;                     -- Register write enable
            rd_out        : out std_logic_vector(4 downto 0));   -- Pass-through
end MEM_STAGE;

architecture behavior of MEM_STAGE is

    component DATA_MEM
        Port (
            clk        : in  std_logic;
            mem_read   : in  std_logic;
            mem_write  : in  std_logic;
            address    : in  std_logic_vector(9 downto 0);
            write_data : in  std_logic_vector(31 downto 0);
            read_data  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal mem_address   : std_logic_vector(9 downto 0);
    signal mem_read_sig  : std_logic;
    signal mem_write_sig : std_logic;
    signal mem_read_data : std_logic_vector(31 downto 0);

begin

    -- Word-aligned address from ALU result (drop lower 2 bits)
    mem_address <= alu_result(11 downto 2);

    -- Set control signals for memory
    mem_read_sig  <= '1' when op_in = "010" else '0'; -- Load
    mem_write_sig <= '1' when op_in = "011" else '0'; -- Store

    -- Instantiate memory block
    memory_block : DATA_MEM
        port map ( clk, mem_read_sig, mem_write_sig, mem_address, write_data, mem_read_data );

    -- Memory output logic
    process(op_in, alu_result, mem_read_data)
    begin
        case op_in is
            when "010" =>  -- Load: output comes from memory
                mem_out <= mem_read_data;
            when "001" =>  -- ALU: output passes through from ALU
                mem_out <= alu_result;
            when others => -- Store or NOP: output is irrelevant or 0
                mem_out <= (others => '0');
        end case;
    end process;

    -- Register write enable (only ALU or Load)
    reg_write_out <= '1' when op_in = "001" or op_in = "010" else '0';
    -- Pass destination register
    rd_out      <= rd_in;
end behavior;

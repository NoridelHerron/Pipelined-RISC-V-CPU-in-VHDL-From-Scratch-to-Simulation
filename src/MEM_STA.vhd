
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity MEM_STA is 
    Port (   
            clk             : in  std_logic; 
            reset           : in  std_logic;  -- added reset input
            EX_MEM          : in  EX_MEM_Type;  -- Result from ALU  
            -- Outputs to MEM/WB pipeline register
            MEM             : out MEM_WB_Type
          );
end MEM_STA;

architecture Behavioral of MEM_STA is

signal mem_address    : std_logic_vector(LOG2DEPTH - 1 downto 0)    := (others => '0');
signal mem_read_sig   : std_logic                                   := '0';
signal mem_write_sig  : std_logic                                   := '0';
signal mem_read_data  : std_logic_vector(DATA_WIDTH - 1 downto 0)    := (others => '0');

begin
    

    -- Extract address bits [11:2] for word-aligned access
    mem_address <= EX_MEM.result(11 downto 2);

    -- Control logic to determine memory operation
    mem_read_sig  <= '1' when EX_MEM.op = LOAD else '0';
    mem_write_sig <= '1' when EX_MEM.op = S_TYPE else '0';

    -- Memory instance
    memory_block : entity work.DATA_MEM
        Generic map ( DEPTH         => DEPTH,
                      DATA_WIDTH    => DATA_WIDTH,
                      LOG2DEPTH     => LOG2DEPTH
                     )
        port map (
                    clk         => clk,
                    mem_read    => mem_read_sig,
                    mem_write   => mem_write_sig,
                    address     => mem_address,
                    write_data  => EX_MEM.store_rs2,
                    read_data   => mem_read_data
                );

    MEM.mem_result  <= mem_read_data when EX_MEM.op = LOAD else (others => '0');  
    MEM.ALU_write   <= '1' when EX_MEM.op = R_TYPE or EX_MEM.op = I_IMME else '0';
    MEM.rd          <= EX_MEM.rd;
    MEM.op          <= EX_MEM.op;
end Behavioral;

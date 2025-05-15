----------------------------------------------------------------------------------
--  Title       : WB_STAGE.vhd
--  Description : Write-back stage of a 5-stage pipelined RISC-V processor.
--                Passes the final result to the register file.
--
--  Author      : Noridel Herron
--  Date        : May 9, 2025
--  Notes       : Assumes MEM_STAGE has already selected between ALU/memory output.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WB_STAGE is
    Port (  
            clk             : in  std_logic;
            rst             : in  std_logic;
            -- inputs from MEM/WB REGISTER
            data_in       : in  std_logic_vector(31 downto 0);     -- Final result from MEM_STAGE
            rd_in         : in  std_logic_vector(4 downto 0);      -- Destination register
            reg_write_in  : in  std_logic;                         -- Write enable signal from MEM_STAGE
            -- output to ID STAGE
            data_out      : out std_logic_vector(31 downto 0);     -- Data to write to register file
            rd_out        : out std_logic_vector(4 downto 0);      -- Register index
            reg_write_out : out std_logic);
end WB_STAGE;

architecture behavior of WB_STAGE is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            data_out        <= (others => '0');   
            reg_write_out   <= '0';
            rd_out          <= (others => '0');   
           
        elsif rising_edge(clk) then
            data_out         <= data_in;
            reg_write_out   <= reg_write_in;
            rd_out          <= rd_in;
        end if;
    end process; 
end behavior;

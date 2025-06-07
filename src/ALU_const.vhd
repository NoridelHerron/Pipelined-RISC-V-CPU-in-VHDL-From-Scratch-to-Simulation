----------------------------------------------------------------------------------
-- Noridel Herron
-- ALU Constants Package
-- 5/31/2025
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.const_Types.all;
use ieee.numeric_std.all;

package ALU_Constants_Pkg is

    -- FUNCT3 codes
    constant FUNC3_ADD_SUB : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "000";
    constant FUNC3_SLL     : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "001";
    constant FUNC3_SLT     : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "010";
    constant FUNC3_SLTU    : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "011";
    constant FUNC3_XOR     : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "100";
    constant FUNC3_SRL_SRA : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "101";
    constant FUNC3_OR      : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "110";
    constant FUNC3_AND     : std_logic_vector(FUNCT3_WIDTH-1 downto 0) := "111";

    -- FUNCT7 codes
    constant FUNC7_ADD     : std_logic_vector(FUNCT7_WIDTH-1 downto 0) := "0000000";  -- For ADD
    constant FUNC7_SUB     : std_logic_vector(FUNCT7_WIDTH-1 downto 0) := "0100000";  -- For SUB
    constant FUNC7_SRL     : std_logic_vector(FUNCT7_WIDTH-1 downto 0) := "0000000";  -- For SRL
    constant FUNC7_SRA     : std_logic_vector(FUNCT7_WIDTH-1 downto 0) := "0100000";  -- For SRA

end ALU_Constants_Pkg;
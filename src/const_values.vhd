----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package const_Types is
    
    -- You can also define constants 
    constant DATA_WIDTH     : integer := 32;
    constant REG_ADDR_WIDTH : integer := 5;
    constant FUNCT3_WIDTH   : integer := 3;
    constant FUNCT7_WIDTH   : integer := 7;
    constant OPCODE_WIDTH   : integer := 7;
    constant FLAG_WIDTH     : integer := 4;
    constant DEPTH          : integer := 4;
    constant LOG2DEPTH      : integer := 2;
    constant IMM_WIDTH      : integer := 12;
    
    constant ZERO_32bits    : std_logic_vector(DATA_WIDTH-1 downto 0)     := (others => '0');
    constant ZERO_12bits    : std_logic_vector(IMM_WIDTH-1 downto 0)      := (others => '0');
    constant ZERO_5bits     : std_logic_vector(REG_ADDR_WIDTH-1 downto 0) := (others => '0');
    constant ZERO_7bits     : std_logic_vector(FUNCT7_WIDTH-1 downto 0)   := (others => '0');
    constant ZERO_3bits     : std_logic_vector(FUNCT3_WIDTH-1 downto 0)   := (others => '0');
    constant ZERO_1bit      : std_logic                                   := '0';
    
    -- NOP
    constant NOP    : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000013";
    -- OPCODE TYPE
    constant R_TYPE : std_logic_vector(OPCODE_WIDTH-1 downto 0) := "0110011";
    constant I_IMME : std_logic_vector(OPCODE_WIDTH-1 downto 0) := "0010011";
    constant LOAD   : std_logic_vector(OPCODE_WIDTH-1 downto 0) := "0000011";
    constant S_TYPE : std_logic_vector(OPCODE_WIDTH-1 downto 0) := "0100011";
    constant B_TYPE : std_logic_vector(OPCODE_WIDTH-1 downto 0) := "1100011";
    
    constant ENABLE_FORWARDING : boolean := true;
    --constant ENABLE_FORWARDING : boolean := false;
      
end package;
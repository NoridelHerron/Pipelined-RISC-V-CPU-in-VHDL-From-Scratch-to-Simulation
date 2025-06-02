----------------------------------------------------------------------------------
-- Noridel Herron
-- FullAdder for ALU (32-bit Version)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;
use work.const_Types.all;

-- 32-bit ripple-carry adder
entity adder_32bits is
    Generic( DATA_WIDTH     : natural    := DATA_WIDTH );
    Port (
            A, B           : in std_logic_vector (DATA_WIDTH - 1 downto 0);
            Ci             : in std_logic;
            Sum            : out std_logic_vector (DATA_WIDTH - 1 downto 0);
            Z_flag, V_flag, C_flag, N_flag : out std_logic
        ); 
end adder_32bits;

architecture Equation of adder_32bits is

    -- Internal signals
    signal Co : std_logic;
    signal C  : std_logic_vector (DATA_WIDTH - 1 downto 1);
    signal S  : std_logic_vector (DATA_WIDTH - 1 downto 0);

begin
    -- Instantiate FullAdders for 32-bit addition
    -- First Full Adder manually (no previous carry-in signal)
    FA0: entity work.FullAdder port map (
        A => A(0),
        B => B(0),
        Ci => Ci,
        Co => C(1),
        S => S(0)
    );

    -- Generate Full Adders for bits 1 to 30
    FA_Gen: for i in 1 to 30 generate
        FA: entity work.FullAdder port map (
            A => A(i),
            B => B(i),
            Ci => C(i),
            Co => C(i+1),
            S => S(i)
        );
    end generate;

    -- Last Full Adder (bit 31) outputs to Co
    FA31: entity work.FullAdder port map (
        A => A(DATA_WIDTH - 1),
        B => B(DATA_WIDTH - 1),
        Ci => C(DATA_WIDTH - 1),
        Co => Co,
        S => S(DATA_WIDTH - 1)
    );

    process(S, A(DATA_WIDTH - 1), B(DATA_WIDTH - 1), Co)
    begin
        Sum <= S;

        -- Zero flag
        if S = "00000000000000000000000000000000" then
            Z_flag <= '1';
        else
            Z_flag <= '0';
        end if;

        -- Overflow flag for addition
        if ((A(DATA_WIDTH - 1) = B(DATA_WIDTH - 1)) and (S(DATA_WIDTH - 1) /= A(DATA_WIDTH - 1))) then
            V_flag <= '1';
        else
            V_flag <= '0';
        end if;

        -- Carry flag
        C_flag <= Co;

        -- Negative flag
        N_flag <= S(DATA_WIDTH - 1);
    end process;

end Equation;
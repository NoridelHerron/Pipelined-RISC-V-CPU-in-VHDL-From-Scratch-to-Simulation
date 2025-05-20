----------------------------------------------------------------------------------
-- Noridel Herron
-- FullAdder for ALU (32-bit Version)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 32-bit ripple-carry adder
entity adder_32bits is
    Port (
            A, B           : in std_logic_vector (31 downto 0);
            Ci             : in std_logic;
            Sum            : out std_logic_vector (31 downto 0);
            Z_flag, V_flag, C_flag, N_flag : out std_logic
        ); 
end adder_32bits;

architecture Equation of adder_32bits is

    component FullAdder is 
        port(
            A, B, Ci : in std_logic;
            Co, S    : out std_logic
        );
    end component; 

    -- Internal signals
    signal Co : std_logic;
    signal C  : std_logic_vector (31 downto 1);
    signal S  : std_logic_vector (31 downto 0);

begin
    -- Instantiate FullAdders for 32-bit addition
    -- First Full Adder manually (no previous carry-in signal)
    FA0: FullAdder port map (
        A => A(0),
        B => B(0),
        Ci => Ci,
        Co => C(1),
        S => S(0)
    );

    -- Generate Full Adders for bits 1 to 30
    FA_Gen: for i in 1 to 30 generate
        FA: FullAdder port map (
            A => A(i),
            B => B(i),
            Ci => C(i),
            Co => C(i+1),
            S => S(i)
        );
    end generate;

    -- Last Full Adder (bit 31) outputs to Co
    FA31: FullAdder port map (
        A => A(31),
        B => B(31),
        Ci => C(31),
        Co => Co,
        S => S(31)
    );

    process(S, A(31), B(31), Co)
    begin
        Sum <= S;

        -- Zero flag
        if S = "00000000000000000000000000000000" then
            Z_flag <= '1';
        else
            Z_flag <= '0';
        end if;

        -- Overflow flag for addition
        if ((A(31) = B(31)) and (S(31) /= A(31))) then
            V_flag <= '1';
        else
            V_flag <= '0';
        end if;

        -- Carry flag
        C_flag <= Co;

        -- Negative flag
        N_flag <= S(31);
    end process;

end Equation;
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
    FA1 : FullAdder port map (A(0), B(0), Ci, C(1), S(0));
    FA2 : FullAdder port map (A(1), B(1), C(1), C(2), S(1));
    FA3 : FullAdder port map (A(2), B(2), C(2), C(3), S(2));
    FA4 : FullAdder port map (A(3), B(3), C(3), C(4), S(3));
    FA5 : FullAdder port map (A(4), B(4), C(4), C(5), S(4));
    FA6 : FullAdder port map (A(5), B(5), C(5), C(6), S(5));
    FA7 : FullAdder port map (A(6), B(6), C(6), C(7), S(6));
    FA8 : FullAdder port map (A(7), B(7), C(7), C(8), S(7));
    FA9 : FullAdder port map (A(8), B(8), C(8), C(9), S(8));
    FA10: FullAdder port map (A(9), B(9), C(9), C(10), S(9));
    FA11: FullAdder port map (A(10), B(10), C(10), C(11), S(10));
    FA12: FullAdder port map (A(11), B(11), C(11), C(12), S(11));
    FA13: FullAdder port map (A(12), B(12), C(12), C(13), S(12));
    FA14: FullAdder port map (A(13), B(13), C(13), C(14), S(13));
    FA15: FullAdder port map (A(14), B(14), C(14), C(15), S(14));
    FA16: FullAdder port map (A(15), B(15), C(15), C(16), S(15));
    FA17: FullAdder port map (A(16), B(16), C(16), C(17), S(16));
    FA18: FullAdder port map (A(17), B(17), C(17), C(18), S(17));
    FA19: FullAdder port map (A(18), B(18), C(18), C(19), S(18));
    FA20: FullAdder port map (A(19), B(19), C(19), C(20), S(19));
    FA21: FullAdder port map (A(20), B(20), C(20), C(21), S(20));
    FA22: FullAdder port map (A(21), B(21), C(21), C(22), S(21));
    FA23: FullAdder port map (A(22), B(22), C(22), C(23), S(22));
    FA24: FullAdder port map (A(23), B(23), C(23), C(24), S(23));
    FA25: FullAdder port map (A(24), B(24), C(24), C(25), S(24));
    FA26: FullAdder port map (A(25), B(25), C(25), C(26), S(25));
    FA27: FullAdder port map (A(26), B(26), C(26), C(27), S(26));
    FA28: FullAdder port map (A(27), B(27), C(27), C(28), S(27));
    FA29: FullAdder port map (A(28), B(28), C(28), C(29), S(28));
    FA30: FullAdder port map (A(29), B(29), C(29), C(30), S(29));
    FA31: FullAdder port map (A(30), B(30), C(30), C(31), S(30));
    FA32: FullAdder port map (A(31), B(31), C(31), Co,    S(31));

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

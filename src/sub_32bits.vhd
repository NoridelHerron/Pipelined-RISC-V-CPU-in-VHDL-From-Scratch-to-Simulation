----------------------------------------------------------------------------------
-- Noridel Herron
-- Full 32-bit Subtractor for ALU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sub_32bits is
    Port (
        A, B          : in std_logic_vector (31 downto 0);  -- 32-bits inputs
        Bi            : in std_logic;                       -- Initial borrow-in
        difference    : out std_logic_vector (31 downto 0); -- Subtraction result
        Z_flag, V_flag, C_flag, N_flag : out std_logic      -- Flags
    ); 
end sub_32bits;

architecture equation of sub_32bits is

    component FullSubtractor 
        port (
            X, Y, Bin : in std_logic; 
            Bout, D   : out std_logic
        ); 
    end component;  

    -- Internal signals
    signal Bo : std_logic;
    signal Br  : std_logic_vector (31 downto 1); 
    signal Do  : std_logic_vector (31 downto 0); 

begin 
    -- Instantiate the FullSubtractor chain
    FS1:  FullSubtractor port map (A(0), B(0), Bi,     Br(31), Do(0)); 
    FS2:  FullSubtractor port map (A(1), B(1), Br(31), Br(30), Do(1)); 
    FS3:  FullSubtractor port map (A(2), B(2), Br(30), Br(29), Do(2)); 
    FS4:  FullSubtractor port map (A(3), B(3), Br(29), Br(28), Do(3)); 
    FS5:  FullSubtractor port map (A(4), B(4), Br(28), Br(27), Do(4)); 
    FS6:  FullSubtractor port map (A(5), B(5), Br(27), Br(26), Do(5)); 
    FS7:  FullSubtractor port map (A(6), B(6), Br(26), Br(25), Do(6)); 
    FS8:  FullSubtractor port map (A(7), B(7), Br(25), Br(24), Do(7));  
    FS9:  FullSubtractor port map (A(8), B(8), Br(24), Br(23), Do(8)); 
    FS10: FullSubtractor port map (A(9), B(9), Br(23), Br(22), Do(9)); 
    FS11: FullSubtractor port map (A(10), B(10), Br(22), Br(21), Do(10)); 
    FS12: FullSubtractor port map (A(11), B(11), Br(21), Br(20), Do(11)); 
    FS13: FullSubtractor port map (A(12), B(12), Br(20), Br(19), Do(12)); 
    FS14: FullSubtractor port map (A(13), B(13), Br(19), Br(18), Do(13)); 
    FS15: FullSubtractor port map (A(14), B(14), Br(18), Br(17), Do(14)); 
    FS16: FullSubtractor port map (A(15), B(15), Br(17), Br(16), Do(15)); 
    FS17: FullSubtractor port map (A(16), B(16), Br(16), Br(15), Do(16)); 
    FS18: FullSubtractor port map (A(17), B(17), Br(15), Br(14), Do(17));  
    FS19: FullSubtractor port map (A(18), B(18), Br(14), Br(13), Do(18)); 
    FS20: FullSubtractor port map (A(19), B(19), Br(13), Br(12), Do(19)); 
    FS21: FullSubtractor port map (A(20), B(20), Br(12), Br(11), Do(20));
    FS22: FullSubtractor port map (A(21), B(21), Br(11), Br(10), Do(21)); 
    FS23: FullSubtractor port map (A(22), B(22), Br(10), Br(9), Do(22));  
    FS24: FullSubtractor port map (A(23), B(23), Br(9), Br(8), Do(23)); 
    FS25: FullSubtractor port map (A(24), B(24), Br(8), Br(7), Do(24)); 
    FS26: FullSubtractor port map (A(25), B(25), Br(7), Br(6), Do(25)); 
    FS27: FullSubtractor port map (A(26), B(26), Br(6), Br(5), Do(26)); 
    FS28: FullSubtractor port map (A(27), B(27), Br(5), Br(4), Do(27));  
    FS29: FullSubtractor port map (A(28), B(28), Br(4), Br(3), Do(28)); 
    FS30: FullSubtractor port map (A(29), B(29), Br(3), Br(2), Do(29)); 
    FS31: FullSubtractor port map (A(30), B(30), Br(2), Br(1), Do(30)); 
    FS32: FullSubtractor port map (A(31), B(31), Br(1), Bo,    Do(31)); 

    process(Do, A, B, Bo)
    begin
        difference <= Do;

        -- Zero flag
        if Do = "00000000000000000000000000000000" then
            Z_flag <= '1';
        else
            Z_flag <= '0';
        end if;

        -- Overflow flag for subtraction
        if (A(31) /= B(31)) and (Do(31) /= A(31)) then
            V_flag <= '1';
        else
            V_flag <= '0';
        end if;

        -- Carry flag (borrow out)
        C_flag <= not Bo;

        -- Negative flag
        N_flag <= Do(31);
    end process;

end equation;

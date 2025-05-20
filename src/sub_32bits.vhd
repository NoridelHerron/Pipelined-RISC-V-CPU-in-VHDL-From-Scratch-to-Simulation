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
    
    -- -- First Full Subtractor manually
    FS0: FullSubtractor port map (
        X       => A(0),
        Y       => B(0),
        Bin     => Bi,
        Bout    => Br(31),
        D       => Do(0)
    );

    -- Generate Full Adders for bits 1 to 30
    FS_Gen: for i in 1 to 30 generate
        FS: FullSubtractor port map (
        X       => A(i),
        Y       => B(i),
        Bin     => Br(32-i),
        Bout    => Br(31-i),
        D       => Do(i)
        );
    end generate;

    -- Last Full Subtractor 
    FS31: FullSubtractor port map (
        X       => A(31),
        Y       => B(31),
        Bin     => Br(1),
        Bout    => Bo,
        D       => Do(31)
    );


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

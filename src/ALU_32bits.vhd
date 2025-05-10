----------------------------------------------------------------------------------
-- Noridel Herron
-- ALU 32-bit with Flags (for multistage pipeline)
-- 4/26/2025 (Updated to 32-bit)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A, B       : in std_logic_vector (31 downto 0);  -- 32-bit inputs
        Ci_Bi      : in std_logic;                      -- 1-bit carry/borrow input
        f3         : in std_logic_vector (2 downto 0);  -- 3-bit ALU opcode (funct3)
        f7         : in std_logic_vector (6 downto 0);  -- 7-bit extended opcode (funct7)
        result     : out std_logic_vector (31 downto 0);-- 32-bit result
        Z_flag, V_flag, C_flag, N_flag : out std_logic  -- Flags
    );
end ALU;

architecture operations of ALU is

    -- Adder
    component adder_32bits
        Port (A,B : in std_logic_vector(31 downto 0);           -- 32-bits inputs
              Ci  : in std_logic;                              -- 1-bit input
              Sum : out std_logic_vector(31 downto 0);          -- 32-bits outputs
              Z_flag, V_flag, C_flag, N_flag : out std_logic); -- 1-bit output
    end component;
    
    -- Subtractor
    component sub_32bits
        Port (A,B : in std_logic_vector(31 downto 0);            -- 32-bits inputs
              Bi  : in std_logic;                               -- 1-bit input
              difference : out std_logic_vector(31 downto 0);    -- 32-bits outputs
              Z_flag, V_flag, C_flag, N_flag : out std_logic);  -- 1-bit output
    end component;
    
    -- Internal signals
    signal func_3 : integer range 0 to 7;
    signal func_7 : integer range 0 to 32;
    signal Z, V, C, N, Za, Va, Ca, Na, Zs, Vs, Cs, Ns : std_logic;
    signal res_add, res_sub, res_temp : std_logic_vector(31 downto 0);

begin
    -- Instantiate adder and subtractor
    Add: adder_32bits port map (A, B, Ci_Bi, res_add, Za, Va, Ca, Na);
    Sub: sub_32bits port map (A, B, Ci_Bi, res_sub, Zs, Vs, Cs, Ns);
    
    -- Convert opcodes to integers
    func_3 <= TO_INTEGER(unsigned(f3));
    func_7 <= TO_INTEGER(unsigned(f7));


    -- Main datapath process
    process (func_3, func_7, A, B, res_add, res_sub)
    begin
        case func_3 is
            when 0 =>  -- ADD/SUB
                case func_7 is
                    when 0 =>    -- ADD
                        res_temp <= res_add;
                        Z_flag <= Za;
                        V_flag <= Va;
                        C_flag <= Ca;
                        N_flag <= Na;
                    when 32 =>   -- SUB (RISC-V uses 0b0100000 = 32 decimal)
                        res_temp <= res_sub;
                        Z_flag <= Zs;
                        V_flag <= Vs;
                        C_flag <= Cs;
                        N_flag <= Ns;
                    when others =>
                        res_temp <= (others => '0');
                        Z_flag <= '0'; V_flag <= '0'; C_flag <= '0'; N_flag <= '0';
                end case;

            when 1 =>  -- SLL
                res_temp <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));

            when 2 =>  -- SLT
                if signed(A) < signed(B) then
                    res_temp <= (31 downto 1 => '0') & '1';
                else
                    res_temp <= (others => '0');
                end if;

            when 3 =>  -- SLTU
                if unsigned(A) < unsigned(B) then
                    res_temp <= (31 downto 1 => '0') & '1';
                else
                    res_temp <= (others => '0');
                end if;

            when 4 =>  -- XOR
                res_temp <= A xor B;

            when 5 =>  -- SRL/SRA
                case func_7 is
                    when 0 =>    -- SRL
                        res_temp <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                    when 32 =>   -- SRA
                        res_temp <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
                    when others =>
                        res_temp <= (others => '0');
                end case;

            when 6 =>  -- OR
                res_temp <= A or B;

            when 7 =>  -- AND
                res_temp <= A and B;

            when others =>
                res_temp <= (others => '0');
        end case;

        -- Common flag logic for non-ADD/SUB operations
        if func_3 /= 0then         
            if res_temp = "00000000000000000000000000000000" then
                Z_flag <= '1';
            else
                Z_flag <= '0';
            end if;
            N_flag <= res_temp(31); 
            V_flag <= '0'; 
            C_flag <= '0';      
        end if;
    end process;

    result <= res_temp;

end operations;

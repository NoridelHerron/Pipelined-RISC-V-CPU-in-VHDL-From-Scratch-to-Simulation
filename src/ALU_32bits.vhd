----------------------------------------------------------------------------------
-- Noridel Herron
-- ALU 32-bit with Flags (for multistage pipeline)
-- 5/20/2025 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.ALU_Constants_Pkg.all; 

entity ALU is
    Generic( REG_ADDR_WIDTH : natural    := REG_ADDR_WIDTH;
             DATA_WIDTH     : natural    := DATA_WIDTH;
			 F7_WIDTH       : natural    := FUNCT7_WIDTH;
             F3_WIDTH       : natural    := FUNCT3_WIDTH;
			 OP_WIDTH       : natural    := OPCODE_WIDTH;
			 IMM_WIDTH      : natural    := IMM_WIDTH
			);
    Port ( -- inputs
           A, B       : in std_logic_vector (DATA_WIDTH - 1 downto 0);  -- 32-bit inputs
           Ci_Bi      : in std_logic;                       -- 1-bit carry/borrow input 
           f3         : in std_logic_vector (F3_WIDTH - 1 downto 0);   -- 3-bit ALU opcode (funct3)
           f7         : in std_logic_vector (F7_WIDTH - 1 downto 0);   -- 7-bit extended opcode (funct7)
           -- outputs
           result     : out std_logic_vector (DATA_WIDTH - 1 downto 0);  -- 32-bit result
           Z_flag, V_flag, C_flag, N_flag : out std_logic    -- Flags
        );
end ALU;

architecture operations of ALU is

    -- Internal signals
    signal func_3                            : integer range 0 to 7;
    signal func_7                            : integer range 0 to 32;
    signal Za, Va, Ca, Na, Zs, Vs, Cs, Ns    : std_logic; -- prevents multiple drivers
    signal res_add, res_sub, res_temp        : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin
    -- Instantiate adder and subtractor
    Add: entity work.adder_32bits port map (
            A           => A, 
            B           => B, 
            Ci          => Ci_Bi, 
            Sum         => res_add, 
            Z_flag      => Za, 
            V_flag      => Va, 
            C_flag      => Ca, 
            N_flag      => Na
        );
    Sub: entity work.sub_32bits port map (
          A          => A, 
          B          => B, 
          Bi         => Ci_Bi, 
          difference => res_sub, 
          Z_flag     => Zs, 
          V_flag     => Vs, 
          C_flag     => Cs, 
          N_flag     => Ns
    );

    -- Main datapath process
    process (f3, f7, A, B, res_add, res_sub, Za, Va, Ca, Na, Zs, Vs, Cs, Ns)
    begin
        case f3 is
            when FUNC3_ADD_SUB =>  -- ADD/SUB
                case f7 is
                    when FUNC7_ADD =>    -- ADD
                        res_temp <= res_add;
                        Z_flag <= Za;
                        V_flag <= Va;
                        C_flag <= Ca;
                        N_flag <= Na;
                    when FUNC7_SUB =>   -- SUB (RISC-V uses 0b0100000 = 32 decimal)
                        res_temp <= res_sub;
                        Z_flag <= Zs;
                        V_flag <= Vs;
                        C_flag <= Cs;
                        N_flag <= Ns;
                    when others =>
                        res_temp <= (others => '0');
                        Z_flag <= '0'; V_flag <= '0'; C_flag <= '0'; N_flag <= '0';
                end case;

            when FUNC3_SLL =>  -- SLL
                res_temp <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(REG_ADDR_WIDTH - 1 downto 0)))));

            when FUNC3_SLT =>  -- SLT
                if signed(A) < signed(B) then
                    res_temp <= (DATA_WIDTH - 1 downto 1 => '0') & '1';
                else
                    res_temp <= (others => '0');
                end if;

            when FUNC3_SLTU =>  -- SLTU
                if unsigned(A) < unsigned(B) then
                    res_temp <= (DATA_WIDTH - 1 downto 1 => '0') & '1';
                else
                    res_temp <= (others => '0');
                end if;

            when FUNC3_XOR =>  -- XOR
                res_temp <= A xor B;

            when FUNC3_SRL_SRA =>  -- SRL/SRA
                case f7 is
                    when FUNC7_SRL =>    -- SRL
                        res_temp <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(REG_ADDR_WIDTH - 1 downto 0)))));
                    when FUNC7_SRA =>   -- SRA
                        res_temp <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(REG_ADDR_WIDTH - 1 downto 0)))));
                    when others =>
                        res_temp <= (others => '0');
                end case;

            when FUNC3_OR =>  -- OR
                res_temp <= A or B;

            when FUNC3_AND =>  -- AND
                res_temp <= A and B;

            when others =>
                res_temp <= (others => '0');
        end case;

        -- Common flag logic for non-ADD/SUB operations
        if func_3 /= 0then         
            if res_temp = ZERO_32bits then
                Z_flag <= '1';
            else
                Z_flag <= '0';
            end if;
            N_flag <= res_temp(DATA_WIDTH - 1); 
            V_flag <= '0'; 
            C_flag <= '0';      
        end if;
    end process;

    result <= res_temp;

end operations;

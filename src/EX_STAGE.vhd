-- Author      : Noridel Herron
-- Date        : 5/4/25
-- Description : Execution (EX) Stage with EX/MEM pipeline register
--               - Registers all inputs for stability and forwarding
--               - Supports future hazard detection and instruction tracing
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity EX_STAGE is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;

        -- Inputs from ID/EX       
        reg_data1_in  : in  std_logic_vector(31 downto 0);
        reg_data2_in  : in  std_logic_vector(31 downto 0);
        op_in         : in  std_logic_vector(2 downto 0);
        f3_in         : in  std_logic_vector(2 downto 0);
        f7_in         : in  std_logic_vector(6 downto 0); 
        rd_in         : in  std_logic_vector(4 downto 0);
        store_rs2_in  : in  std_logic_vector(31 downto 0);
        
        -- Outputs to MEM stage    
        result_out    : out std_logic_vector(31 downto 0);
        Z_flag_out    : out std_logic;
        V_flag_out    : out std_logic;
        C_flag_out    : out std_logic;
        N_flag_out    : out std_logic;
        write_data_out: out std_logic_vector(31 downto 0); -- Pass reg_data2 for store instructions

        -- pass through the next stage
        op_out        : out  std_logic_vector(2 downto 0);
        rd_out        : out std_logic_vector(4 downto 0)
    );
end EX_STAGE;

architecture behavior of EX_STAGE is

    component ALU
        Port (
            A, B       : in std_logic_vector(31 downto 0);
            Ci_Bi      : in std_logic;
            f3         : in std_logic_vector(2 downto 0);
            f7         : in std_logic_vector(6 downto 0);
            result     : out std_logic_vector(31 downto 0);
            Z_flag     : out std_logic;
            V_flag     : out std_logic;
            C_flag     : out std_logic;
            N_flag     : out std_logic
        );
    end component;

    -- Internal pipeline registers (EX/MEM)   
    signal result_reg     : std_logic_vector(31 downto 0);
    signal Z_flag_reg     : std_logic;
    signal V_flag_reg     : std_logic;
    signal C_flag_reg     : std_logic;
    signal N_flag_reg     : std_logic;
    signal op_reg         : std_logic_vector(2 downto 0);
    signal rd_reg         : std_logic_vector(4 downto 0);
    signal write_data_reg : std_logic_vector(31 downto 0);

    -- ALU wires
    signal alu_result     : std_logic_vector(31 downto 0);
    signal Z_flag_wire    : std_logic;
    signal V_flag_wire    : std_logic;
    signal C_flag_wire    : std_logic;
    signal N_flag_wire    : std_logic;
    signal Ci_Bi          : std_logic := '0';

begin

    -- ALU instance
    alu_inst : ALU port map (reg_data1_in, reg_data2_in, Ci_Bi, f3_in, f7_in, 
                 alu_result, Z_flag_wire, V_flag_wire, C_flag_wire, N_flag_wire);

    -- Pipeline register for EX/MEM
    process(clk, rst)
    begin
        if rst = '1' then  
            -- value will reset         
            result_reg     <= (others => '0');
            Z_flag_reg     <= '0';
            V_flag_reg     <= '0';
            C_flag_reg     <= '0';
            N_flag_reg     <= '0';
            op_reg         <= "000";     
            rd_reg         <= (others => '0');
            write_data_reg <= (others => '0');

        elsif rising_edge(clk) then
            -- update on the rising edge
            result_reg     <= alu_result;
            Z_flag_reg     <= Z_flag_wire;
            V_flag_reg     <= V_flag_wire;
            C_flag_reg     <= C_flag_wire;
            N_flag_reg     <= N_flag_wire;
            op_reg         <= op_in;
            rd_reg         <= rd_in;
            write_data_reg <= store_rs2_in; -- Capture rs2 value
        end if;
    end process;

    -- Output assignments
    result_out     <= result_reg;
    Z_flag_out     <= Z_flag_reg;
    V_flag_out     <= V_flag_reg;
    C_flag_out     <= C_flag_reg;
    N_flag_out     <= N_flag_reg;
    op_out         <= op_reg;
    rd_out         <= rd_reg;
    write_data_out <= write_data_reg;

end behavior;

-- Author      : Noridel Herron
-- Date        : 5/4/25
-- Description : Execution (EX) Stage with EX/MEM pipeline register
--               - Performs ALU operations
--               - Registers all outputs to support pipeline flow
--               - Supports future hazard detection and instruction tracing

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

entity EX_STAGE is
    Generic( DATA_WIDTH  : natural    := DATA_WIDTH;
             F7_WIDTH    : natural    := FUNCT7_WIDTH;
             F3_WIDTH    : natural    := FUNCT3_WIDTH;
             OP_WIDTH    : natural    := OPCODE_WIDTH
             
			);
    Port (
        -- Inputs from ID/EX pipeline register 
        
        reg_data1_in    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        reg_data2_in    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        op_in           : in  std_logic_vector(OP_WIDTH - 1 downto 0);
        f3_in           : in  std_logic_vector(F3_WIDTH - 1 downto 0);
        f7_in           : in  std_logic_vector(F7_WIDTH - 1 downto 0); 
        
        result_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        Z_flag_out      : out std_logic;
        V_flag_out      : out std_logic;
        C_flag_out      : out std_logic;
        N_flag_out      : out std_logic;
        op_out          : out std_logic_vector(OP_WIDTH - 1 downto 0) 
    );
end EX_STAGE;

architecture behavior of EX_STAGE is

    -- ALU component declaration
    component ALU
        Port (
            A, B       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            Ci_Bi      : in  std_logic;
            f3         : in  std_logic_vector(F3_WIDTH - 1 downto 0);
            f7         : in  std_logic_vector(F7_WIDTH - 1 downto 0);
            result     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            Z_flag     : out std_logic;
            V_flag     : out std_logic;
            C_flag     : out std_logic;
            N_flag     : out std_logic
        );
    end component;

    -- Internal signals
    signal alu_result     : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');  
    signal Z_flag_wire    : std_logic                                 := '0';
    signal V_flag_wire    : std_logic                                 := '0';
    signal C_flag_wire    : std_logic                                 := '0';
    signal N_flag_wire    : std_logic                                 := '0';
    signal Ci_Bi          : std_logic                                 := '0';  -- Carry-in or B-invert flag, can be expanded

begin

    -- ALU computation
    alu_inst : ALU
        port map (
            A        => reg_data1_in,
            B        => reg_data2_in,
            Ci_Bi    => Ci_Bi,
            f3       => f3_in,
            f7       => f7_in,
            result   => alu_result,
            Z_flag   => Z_flag_wire,
            V_flag   => V_flag_wire,
            C_flag   => C_flag_wire,
            N_flag   => N_flag_wire
        );

    -- EX/MEM pipeline outputs (combinational)
    process (alu_result, Z_flag_wire, V_flag_wire, C_flag_wire, N_flag_wire,
             op_in)
    begin
        result_out     <= alu_result;
        Z_flag_out     <= Z_flag_wire;
        V_flag_out     <= V_flag_wire;
        C_flag_out     <= C_flag_wire;
        N_flag_out     <= N_flag_wire;
        op_out         <= op_in;
    end process;

end behavior;

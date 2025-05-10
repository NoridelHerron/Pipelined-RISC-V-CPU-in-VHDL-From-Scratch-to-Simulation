----------------------------------------------------------------------------------
-- Create Date: 05/09/2025 04:59:38 AM
-- Design Name: Multi-Stage Pipeline
-- Module Name: CPU_RISCV - FLOW
-- Project Name: Noridel Herron
-- Description: Top-level integration of 5-stage RISC-V pipeline
--
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU_RISCV is
    Port (
        clk                    : in std_logic;
        reset                  : in std_logic;

        -- IF
        IF_inst_out            : out std_logic_vector(31 downto 0);
        IF_pc_out              : out std_logic_vector(31 downto 0);

        -- ID
        ID_EX_op_out           : out std_logic_vector(2 downto 0);
        ID_EX_f3_out           : out std_logic_vector(2 downto 0);
        ID_EX_f7_out           : out std_logic_vector(6 downto 0);
        ID_EX_reg_data1_out    : out std_logic_vector(31 downto 0);
        ID_EX_reg_data2_out    : out std_logic_vector(31 downto 0);
        ID_EX_store_rs2_out    : out std_logic_vector(31 downto 0);
        ID_EX_rd_out           : out std_logic_vector(4 downto 0);

        -- EX
        EX_MEM_result_out      : out std_logic_vector(31 downto 0);
        Z_out, N_out           : out std_logic;
        C_out, V_out           : out std_logic;
        EX_MEM_op_out          : out std_logic_vector(2 downto 0);
        EX_MEM_rd_out          : out std_logic_vector(4 downto 0);
        EX_MEM_store_rs2_out   : out std_logic_vector(31 downto 0);

        -- MEM
        MEM_WB_mem_out_out     : out std_logic_vector(31 downto 0);
        MEM_WB_write_out       : out std_logic;
        MEM_WB_rd_out          : out std_logic_vector(4 downto 0);

        -- WB
        WB_ID_data_out         : out std_logic_vector(31 downto 0);
        WB_ID_rd_out           : out std_logic_vector(4 downto 0);
        WB_ID_write_out        : out std_logic
    );
end CPU_RISCV;

architecture FLOW of CPU_RISCV is

    component INST_FETCH
        Port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            instr_out : out std_logic_vector(31 downto 0);
            pc_out    : out std_logic_vector(31 downto 0)
        );
    end component;

    component DECODER
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            instr_in     : in  std_logic_vector(31 downto 0);
            data_in      : in  std_logic_vector(31 downto 0);
            wb_rd        : in  std_logic_vector(4 downto 0);
            wb_reg_write : in  std_logic;
            op           : out std_logic_vector(2 downto 0);
            f3           : out std_logic_vector(2 downto 0);
            f7           : out std_logic_vector(6 downto 0);
            reg_data1    : out std_logic_vector(31 downto 0);
            reg_data2    : out std_logic_vector(31 downto 0);
            store_rs2    : out std_logic_vector(31 downto 0);
            rd_out       : out std_logic_vector(4 downto 0)
        );
    end component;

    component EX_STAGE
        Port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            reg_data1_in    : in  std_logic_vector(31 downto 0);
            reg_data2_in    : in  std_logic_vector(31 downto 0);
            op_in           : in  std_logic_vector(2 downto 0);
            f3_in           : in  std_logic_vector(2 downto 0);
            f7_in           : in  std_logic_vector(6 downto 0);
            rd_in           : in  std_logic_vector(4 downto 0);
            store_rs2_in    : in  std_logic_vector(31 downto 0);
            result_out      : out std_logic_vector(31 downto 0);
            Z_flag_out      : out std_logic;
            V_flag_out      : out std_logic;
            C_flag_out      : out std_logic;
            N_flag_out      : out std_logic;
            write_data_out  : out std_logic_vector(31 downto 0);
            op_out          : out std_logic_vector(2 downto 0);
            rd_out          : out std_logic_vector(4 downto 0)
        );
    end component;

    component MEM_STAGE
        Port (
            clk           : in  std_logic;
            alu_result    : in  std_logic_vector(31 downto 0);
            write_data    : in  std_logic_vector(31 downto 0);
            op_in         : in  std_logic_vector(2 downto 0);
            rd_in         : in  std_logic_vector(4 downto 0);
            mem_out       : out std_logic_vector(31 downto 0);
            reg_write_out : out std_logic;
            rd_out        : out std_logic_vector(4 downto 0)
        );
    end component;

    component WB_STAGE
        Port (
            data_in        : in  std_logic_vector(31 downto 0);
            rd_in          : in  std_logic_vector(4 downto 0);
            reg_write_in   : in  std_logic;
            data_out       : out std_logic_vector(31 downto 0);
            rd_out         : out std_logic_vector(4 downto 0);
            reg_write_out  : out std_logic
        );
    end component;

    -- Internal pipeline signals
    signal IF_instruction       : std_logic_vector(31 downto 0);
    signal IF_pc_out1           : std_logic_vector(31 downto 0);

    signal ID_EX_op             : std_logic_vector(2 downto 0);
    signal ID_EX_f3             : std_logic_vector(2 downto 0);
    signal ID_EX_f7             : std_logic_vector(6 downto 0);
    signal ID_EX_reg_data1      : std_logic_vector(31 downto 0);
    signal ID_EX_reg_data2      : std_logic_vector(31 downto 0);
    signal ID_EX_store_rs2      : std_logic_vector(31 downto 0);
    signal ID_EX_rd             : std_logic_vector(4 downto 0);

    signal EX_MEM_result        : std_logic_vector(31 downto 0);
    signal Z, N, C, V           : std_logic;
    signal EX_MEM_op            : std_logic_vector(2 downto 0);
    signal EX_MEM_rd            : std_logic_vector(4 downto 0);
    signal EX_MEM_store_rs2     : std_logic_vector(31 downto 0);

    signal MEM_WB_mem_out       : std_logic_vector(31 downto 0);
    signal MEM_WB_write         : std_logic;
    signal MEM_WB_rd            : std_logic_vector(4 downto 0);

    signal WB_ID_data           : std_logic_vector(31 downto 0);
    signal WB_ID_rd             : std_logic_vector(4 downto 0);
    signal WB_ID_write          : std_logic;

begin

    IF_STAGE_UUT : INST_FETCH
        port map (
            clk       => clk,
            rst       => reset,
            instr_out => IF_instruction,
            pc_out    => IF_pc_out1
        );

    ID_STAGE_UUT : DECODER
        port map (
            clk          => clk,
            rst          => reset,
            instr_in     => IF_instruction,
            data_in      => WB_ID_data,
            wb_rd        => WB_ID_rd,
            wb_reg_write => WB_ID_write,
            op           => ID_EX_op,
            f3           => ID_EX_f3,
            f7           => ID_EX_f7,
            reg_data1    => ID_EX_reg_data1,
            reg_data2    => ID_EX_reg_data2,
            store_rs2    => ID_EX_store_rs2,
            rd_out       => ID_EX_rd
        );

    EX_STAGE_UUT : EX_STAGE
        port map (
            clk             => clk,
            rst             => reset,
            reg_data1_in    => ID_EX_reg_data1,
            reg_data2_in    => ID_EX_reg_data2,
            op_in           => ID_EX_op,
            f3_in           => ID_EX_f3,
            f7_in           => ID_EX_f7,
            rd_in           => ID_EX_rd,
            store_rs2_in    => ID_EX_store_rs2,
            result_out      => EX_MEM_result,
            Z_flag_out      => Z,
            V_flag_out      => V,
            C_flag_out      => C,
            N_flag_out      => N,
            write_data_out  => EX_MEM_store_rs2,
            op_out          => EX_MEM_op,
            rd_out          => EX_MEM_rd
        );

    MEM_STAGE_UUT : MEM_STAGE
        port map (
            clk           => clk,
            alu_result    => EX_MEM_result,
            write_data    => EX_MEM_store_rs2,
            op_in         => EX_MEM_op,
            rd_in         => EX_MEM_rd,
            mem_out       => MEM_WB_mem_out,
            reg_write_out => MEM_WB_write,
            rd_out        => MEM_WB_rd
        );

    WB_STAGE_UUT : WB_STAGE
        port map (
            data_in       => MEM_WB_mem_out,
            rd_in         => MEM_WB_rd,
            reg_write_in  => MEM_WB_write,
            data_out      => WB_ID_data,
            rd_out        => WB_ID_rd,
            reg_write_out => WB_ID_write
        );

    -- Assign to top-level outputs
    IF_inst_out             <= IF_instruction;
    IF_pc_out               <= IF_pc_out1;
    ID_EX_op_out            <= ID_EX_op;
    ID_EX_f3_out            <= ID_EX_f3;
    ID_EX_f7_out            <= ID_EX_f7;
    ID_EX_reg_data1_out     <= ID_EX_reg_data1;
    ID_EX_reg_data2_out     <= ID_EX_reg_data2;
    ID_EX_store_rs2_out     <= ID_EX_store_rs2;
    ID_EX_rd_out            <= ID_EX_rd;
    EX_MEM_result_out       <= EX_MEM_result;
    Z_out                   <= Z;
    N_out                   <= N;
    C_out                   <= C;
    V_out                   <= V;
    EX_MEM_op_out           <= EX_MEM_op;
    EX_MEM_rd_out           <= EX_MEM_rd;
    EX_MEM_store_rs2_out    <= EX_MEM_store_rs2;
    MEM_WB_mem_out_out      <= MEM_WB_mem_out;
    MEM_WB_write_out        <= MEM_WB_write;
    MEM_WB_rd_out           <= MEM_WB_rd;
    WB_ID_data_out          <= WB_ID_data;
    WB_ID_rd_out            <= WB_ID_rd;
    WB_ID_write_out         <= WB_ID_write;

end FLOW;

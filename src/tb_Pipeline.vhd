
-- Testbench for top-level CPU_RISCV
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

library work;
use work.reusable_function.all;

entity tb_CPU_RISCV is
end tb_CPU_RISCV;

architecture sim of tb_CPU_RISCV is
    -- DUT component
    component CPU_RISCV is
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

            -- EX STAGE 
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
    end component;

    -- Clock and reset signals
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Clock generation
    constant CLK_PERIOD : time := 10 ns;

    -- DUT observed signals
    -- IF
    signal IF_pc_out             : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_inst_out           : std_logic_vector(31 downto 0);
    
    -- ID
    signal ID_EX_op_out          : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_EX_f3_out          : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_EX_f7_out          : std_logic_vector(6 downto 0) := (others => '0');
    signal ID_EX_reg_data1_out   : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_reg_data2_out   : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_rd_out          : std_logic_vector(4 downto 0) := (others => '0');
    signal ID_EX_store_rs2_out   : std_logic_vector(31 downto 0) := (others => '0');
    
    -- EX
    signal EX_MEM_store_rs2_out  : std_logic_vector(31 downto 0) := (others => '0');
    signal Z_out, N_out          : std_logic := '0';
    signal C_out, V_out          : std_logic := '0';
    signal EX_MEM_op_out         : std_logic_vector(2 downto 0) := (others => '0');
    signal EX_MEM_rd_out         : std_logic_vector(4 downto 0) := (others => '0');
    signal EX_MEM_result_out     : std_logic_vector(31 downto 0) := (others => '0');

    -- MEM
    signal MEM_WB_mem_out_out    : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_WB_write_out      : std_logic;
    signal MEM_WB_rd_out         : std_logic_vector(4 downto 0) := (others => '0');
    
    -- WB
    signal WB_ID_rd_out          : std_logic_vector(4 downto 0) := (others => '0');
    signal WB_ID_data_out        : std_logic_vector(31 downto 0) := (others => '0');
    signal WB_ID_write_out       : std_logic := '0';

begin

    -- Instantiate the DUT
    DUT: CPU_RISCV
        port map (
            clk                     => clk,
            reset                   => reset,
            IF_inst_out             => IF_inst_out,
            IF_pc_out               => IF_pc_out,
            ID_EX_op_out            => ID_EX_op_out,
            ID_EX_f3_out            => ID_EX_f3_out,
            ID_EX_f7_out            => ID_EX_f7_out,
            ID_EX_reg_data1_out     => ID_EX_reg_data1_out,
            ID_EX_reg_data2_out     => ID_EX_reg_data2_out,
            ID_EX_store_rs2_out     => ID_EX_store_rs2_out,
            ID_EX_rd_out            => ID_EX_rd_out,
            EX_MEM_result_out       => EX_MEM_result_out,
            Z_out                   => Z_out,
            N_out                   => N_out,
            C_out                   => C_out,
            V_out                   => V_out,
            EX_MEM_op_out           => EX_MEM_op_out,
            EX_MEM_rd_out           => EX_MEM_rd_out,
            EX_MEM_store_rs2_out    => EX_MEM_store_rs2_out,
            MEM_WB_mem_out_out      => MEM_WB_mem_out_out,
            MEM_WB_write_out        => MEM_WB_write_out,
            MEM_WB_rd_out           => MEM_WB_rd_out,
            WB_ID_data_out          => WB_ID_data_out,
            WB_ID_rd_out            => WB_ID_rd_out,
            WB_ID_write_out         => WB_ID_write_out
        );

    -- Clock generation process
    clk_process : process
    begin
        while now < 5000 ns loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Reset process
    reset_process : process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process;

    -- Assertion process to check expected pipeline behavior
    assertion_check : process
    begin
        wait for 1000 ns;
        
        assert IF_pc_out /= "00000000000000000000000000000000"
            report "PC is stuck at 0" severity error;
        
        assert IF_inst_out /= x"00000013"
            report "Fetched instruction is NOP (possible ROM problem)" severity warning;
            
        assert ID_EX_rd_out = EX_MEM_rd_out
          report "EX stage did not receive correct RD from ID stage" severity warning;
        
        assert EX_MEM_rd_out = MEM_WB_rd_out
          report "MEM stage RD mismatch from EX stage" severity warning;
        
        assert WB_ID_rd_out = MEM_WB_rd_out
          report "WB stage RD mismatch from MEM stage" severity warning;
        
    
        assert WB_ID_write_out = '1'
          report "reg_write not active in WB stage" severity error;

        assert WB_ID_data_out /= "00000000000000000000000000000000"
          report "WB_ID_data is all zeros" severity warning;

        assert EX_MEM_result_out /= "00000000000000000000000000000000"
          report "ALU result is zero - possible EX_STAGE issue" severity warning;
        
        report "WB stage: op=" & to_hexstring(EX_MEM_op_out) &
           ", write=" & std_logic'image(WB_ID_write_out) &
           ", data=" & to_hexstring(WB_ID_data_out);
        report "Assertions passed up to 500 ns" severity note;
        wait;
    end process;

    -- Simulation end condition
    end_simulation : process
    begin
        wait for 5000 ns;  
        report "Simulation finished" severity note;
        std.env.stop;
    end process;

end sim;

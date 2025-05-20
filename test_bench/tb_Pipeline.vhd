
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
    
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk                  : std_logic := '0';
    signal reset                : std_logic := '1';

    signal FORWARDING           : std_logic := '1';
    signal stall_count          : std_logic_vector(1 downto 0) := (others => '0');
    signal FORWARDA             : std_logic_vector(1 downto 0) := (others => '0');
    signal FORWARDB             : std_logic_vector(1 downto 0) := (others => '0');

    signal IF_pc                : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_inst              : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_ID_inst           : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_inst           : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_MEM_inst          : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_WB_inst          : std_logic_vector(31 downto 0) := (others => '0');
    
    signal rs1, rs2             : std_logic_vector(4 downto 0) := (others => '0');
    signal ID_EX_rd             : std_logic_vector(4 downto 0) := (others => '0');
    signal EX_MEM_rd            : std_logic_vector(4 downto 0) := (others => '0');
    signal MEM_WB_rd            : std_logic_vector(4 downto 0) := (others => '0');
    
    signal ID_EX_reg_data1      : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_reg_data2      : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_MEM_result        : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_WB_mem           : std_logic_vector(31 downto 0) := (others => '0');
    signal WB_ID_data           : std_logic_vector(31 downto 0) := (others => '0');
    
    signal ID_EX_store_rs2      : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_MEM_store_rs2     : std_logic_vector(31 downto 0) := (others => '0');
    
    signal MEM_WB_write         : std_logic := '0';
    signal WB_ID_write          : std_logic := '0';
    signal ID_EX_f3             : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_EX_f7             : std_logic_vector(6 downto 0) := (others => '0');
    signal ID_EX_op             : std_logic_vector(6 downto 0) := (others => '0');
    signal EX_MEM_op            : std_logic_vector(6 downto 0)  := (others => '0');
    signal Flags                : std_logic_vector(3 downto 0) := (others => '0');
   
begin
    DUT: entity work.CPU_RISCV
        port map (
            clk                     => clk,
            reset                   => reset,
            ENABLE_FORWARDING       => FORWARDING,
            -- IF
            IF_inst_out             => IF_inst,
            IF_ID_inst_out          => IF_ID_inst,
            IF_pc_out               => IF_pc,
            -- ID
            ID_EX_inst_out          => ID_EX_inst,
            ID_EX_op_out            => ID_EX_op,
            ID_EX_f3_out            => ID_EX_f3,
            ID_EX_f7_out            => ID_EX_f7,
            ID_EX_reg_data1_out     => ID_EX_reg_data1,
            ID_EX_reg_data2_out     => ID_EX_reg_data2,
            ID_EX_store_rs2_out     => ID_EX_store_rs2,
            ID_EX_rd_out            => ID_EX_rd,
            rs1                     => rs1,
            rs2                     => rs2,
            -- EX
            EX_MEM_inst_out         => EX_MEM_inst,
            EX_MEM_result_out       => EX_MEM_result,
            Flags_out               => Flags,
            EX_MEM_op_out           => EX_MEM_op,
            EX_MEM_rd_out           => EX_MEM_rd,
            EX_MEM_store_rs2_out    => EX_MEM_store_rs2,
            -- MEM
            MEM_WB_inst_out         => MEM_WB_inst,
            MEM_WB_mem_out_out      => MEM_WB_mem,
            MEM_WB_write_out        => MEM_WB_write,
            MEM_WB_rd_out           => MEM_WB_rd,
            -- WB
            WB_ID_data_out          => WB_ID_data,
            WB_ID_write_out         => WB_ID_write,
            num_stall               => stall_count,
            ForwardA_out            => FORWARDA,
            ForwardB_out            => FORWARDB
        );



    clk_process : process
    begin
        while now < 5000 ns loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    reset_process : process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process;
    
    end_simulation : process
    begin
        wait for 5000 ns;
        report "Simulation finished" severity note;
        std.env.stop;
    end process;

end sim;
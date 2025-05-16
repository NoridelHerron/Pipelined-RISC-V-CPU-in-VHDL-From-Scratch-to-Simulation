
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
            -- For forwarding
           -- ENABLE_FORWARDING      : in std_logic;
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
            --ID_pc_out              : out std_logic_vector(31 downto 0);
    
            -- EX
            EX_MEM_result_out      : out std_logic_vector(31 downto 0);
            -- Flags(3) = Z flag; Flags(2) = N flag; Flags(1) = C flag; Flags(0) = V flag
            Flags_out              : out std_logic_vector(3 downto 0);      
            EX_MEM_op_out          : out std_logic_vector(2 downto 0);
            EX_MEM_rd_out          : out std_logic_vector(4 downto 0);
            EX_MEM_store_rs2_out   : out std_logic_vector(31 downto 0);
            --EX_pc_out              : out std_logic_vector(31 downto 0);
    
            -- MEM
            MEM_WB_mem_out_out     : out std_logic_vector(31 downto 0);
            MEM_WB_write_out       : out std_logic;
            MEM_WB_rd_out          : out std_logic_vector(4 downto 0);
            --MEM_pc_out             : out std_logic_vector(31 downto 0);
            
            -- WB
            WB_ID_data_out         : out std_logic_vector(31 downto 0);
            WB_ID_rd_out           : out std_logic_vector(4 downto 0);
            WB_ID_write_out        : out std_logic
            --WB_pc_out              : out std_logic_vector(31 downto 0);
            
            --Forward_A              : out std_logic_vector(1 downto 0);
            --Forward_B              : out std_logic_vector(1 downto 0);                    
            --num_stall_out          : out  std_logic_vector(1 downto 0)
            --bubble_out             : out  std_logic    
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '1';
    --signal FORWARDING       : std_logic := '0';
    
    signal Flags            : std_logic_vector(3 downto 0);
    signal ID_EX_f3         : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_EX_f7         : std_logic_vector(6 downto 0) := (others => '0');
    signal ID_EX_op         : std_logic_vector(2 downto 0) := (others => '0');
    
    signal IF_pc            : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_inst          : std_logic_vector(31 downto 0);     
    signal EX_MEM_op        : std_logic_vector(2 downto 0) := (others => '0');       
    signal ID_EX_reg_data1  : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_reg_data2  : std_logic_vector(31 downto 0) := (others => '0');
    
    signal EX_MEM_result    : std_logic_vector(31 downto 0) := (others => '0');  
    signal MEM_WB_mem       : std_logic_vector(31 downto 0) := (others => '0');    
    signal WB_ID_data       : std_logic_vector(31 downto 0) := (others => '0');

    signal ID_EX_rd         : std_logic_vector(4 downto 0) := (others => '0');
    signal EX_MEM_rd        : std_logic_vector(4 downto 0) := (others => '0');  
    signal MEM_WB_rd        : std_logic_vector(4 downto 0) := (others => '0'); 
    signal WB_ID_rd         : std_logic_vector(4 downto 0) := (others => '0');  
    
     --signal WB_pc            : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_WB_write     : std_logic;
    signal WB_ID_write      : std_logic := '0';
    signal ID_EX_store_rs2  : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_MEM_store_rs2 : std_logic_vector(31 downto 0) := (others => '0');  
begin
    DUT: CPU_RISCV
        port map (
            clk                     => clk,
            reset                   => reset,
            --ENABLE_FORWARDING       => FORWARDING,
            IF_inst_out             => IF_inst,
            IF_pc_out               => IF_pc,
            ID_EX_op_out            => ID_EX_op,
            ID_EX_f3_out            => ID_EX_f3,
            ID_EX_f7_out            => ID_EX_f7,
            ID_EX_reg_data1_out     => ID_EX_reg_data1,
            ID_EX_reg_data2_out     => ID_EX_reg_data2,
            ID_EX_store_rs2_out     => ID_EX_store_rs2,
            ID_EX_rd_out            => ID_EX_rd,
            --ID_pc_out               => ID_pc,
            EX_MEM_result_out       => EX_MEM_result,
            Flags_out               => Flags,
            EX_MEM_op_out           => EX_MEM_op,
            EX_MEM_rd_out           => EX_MEM_rd,
            EX_MEM_store_rs2_out    => EX_MEM_store_rs2,
            --EX_pc_out               => EX_pc,
            MEM_WB_mem_out_out      => MEM_WB_mem,
            MEM_WB_write_out        => MEM_WB_write,
            MEM_WB_rd_out           => MEM_WB_rd,
            --MEM_pc_out              => MEM_pc,
            WB_ID_data_out          => WB_ID_data,
            WB_ID_rd_out            => WB_ID_rd,
            WB_ID_write_out         => WB_ID_write 
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

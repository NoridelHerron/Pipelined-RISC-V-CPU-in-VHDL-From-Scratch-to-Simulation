
-- Testbench for top-level CPU_RISCV
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

-- CUSTOMIZED PACKAGE
library work;
use work.reusable_function.all;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity tb_CPU_RISCV is
end tb_CPU_RISCV;

architecture sim of tb_CPU_RISCV is
    
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '1';
    
    signal IF_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal ID_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal Forward          : FORWARD                       := EMPTY_FORW_Type;
    signal stall            : numStall                      := STALL_NONE;
    signal ID_EX            : ID_EX_Type                    := EMPTY_ID_EX_Type;  
    signal ID_reg           : reg_Type                      := EMPTY_reg_Type;
    signal EX_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal is_flush         : std_logic                     := '0';
    signal EX_MEM           : EX_MEM_Type                   := EMPTY_EX_MEM_Type; 
    signal MEM_STAGE        : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal MEM_WB           : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    signal WB_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal WB               : WB_Type                       := EMPTY_WB_Type;
   
begin
    DUT: entity work.RISCV_CPU
        Port map (  
                    clk                 => clk,
                    reset               => reset,             
                    IF_STAGE_out        => IF_STAGE,
                    ID_STAGE_out        => ID_STAGE,
                    EX_STAGE_out        => EX_STAGE,
                    MEM_STAGE_out       => MEM_STAGE,
                    WB_STAGE_out        => WB_STAGE,      
                    ID_EX_out           => ID_EX,
                    EX_MEM_out          => EX_MEM,
                    MEM_WB_out          => MEM_WB,
                    WB_out              => WB,
                    reg_out             => ID_reg,
                    flush               => is_flush,
                    num_stall           => stall,
                    Forward_out         => Forward    
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
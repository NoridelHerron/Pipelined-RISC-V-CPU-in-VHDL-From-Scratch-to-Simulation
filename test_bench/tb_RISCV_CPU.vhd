
-- Testbench for top-level CPU_RISCV
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;
use work.Pipeline_Types.all;

library work;
use work.reusable_function.all;

entity tb_CPU_RISCV is
end tb_CPU_RISCV;

architecture sim of tb_CPU_RISCV is
    
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk              : std_logic := '0';
    signal reset                : std_logic := '1';

    -- Forwading
    signal ForwardA         : ForwardingType                := FORWARD_NONE;
    signal ForwardB         : ForwardingType                := FORWARD_NONE;
    
    -- Inserting NOP's
    signal stall            : numStall                      := STALL_NONE;
    
    -- pc and instruction
    signal IF_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal ID_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal EX_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal MEM_STAGE        : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal WB_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    
    -- registers output between stages
    signal ID_EX            : ID_EX_Type                    := EMPTY_ID_EX_Type;  
    signal ID_reg           : reg_Type                      := EMPTY_reg_Type;
    signal EX_MEM           : EX_MEM_Type                   := EMPTY_EX_MEM_Type; 
    signal MEM_WB           : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
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
                    num_stall           => stall,
                    ForwardA_out        => ForwardA,
                    ForwardB_out        => ForwardB
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
    
    process(ForwardB)
    variable haz_MEM_WB_B : integer := 0;
    begin
        if ForwardB = FORWARD_MEM_WB then
            haz_MEM_WB_B := haz_MEM_WB_B + 1;
            report " Expected Hazard: ForwardB = FORWARD_MEM_WB | rs2 = " & to_hexstring(MEM_WB.rd);
        elsif ForwardA = FORWARD_EX_MEM then
            haz_MEM_WB_B := haz_MEM_WB_B + 1;
            report " Expected Hazard: ForwardB = FORWARD_EX_MEM | rs2 = " & to_hexstring(EX_MEM.rd);
        end if;
    
        -- Print summary at end of simulation
        if now >= 4999 ns then
            report "========== Forwarding Test Summary ==========";
            report "ForwardB from EX_MEM (rs2 hazards): " & integer'image(haz_MEM_WB_B);
            report "============================================";
        end if;
    end process;
    

    end_simulation : process
    begin
        wait for 5000 ns;
        report "Simulation finished" severity note;
        std.env.stop;
    end process;

end sim;
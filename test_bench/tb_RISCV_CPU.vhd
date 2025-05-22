
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
    
    signal clk                  : std_logic := '0';
    signal reset                : std_logic := '1';

    signal ForwardA         : ForwardingType                := FORWARD_NONE;
    signal ForwardB         : ForwardingType                := FORWARD_NONE;
    
    signal IF_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal IF_ID_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal ID_EX_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal EX_MEM_STAGE     : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal MEM_WB_STAGE     : PipelineStages_Inst_PC        := EMPTY_inst_pc;
 
    signal ID_EX            : ID_EX_Type                    := EMPTY_ID_EX_Type;  
    signal EX_MEM           : EX_MEM_Type                   := EMPTY_EX_MEM_Type; 
    signal MEM_WB           : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    signal WB               : WB_Type                       := EMPTY_WB_Type;

    signal stall            : numStall                      := STALL_NONE;
   
begin
    DUT: entity work.RISCV_CPU
        Port map (  clk                    => clk,
                    reset                  => reset,             
                    IF_STAGE_out           => IF_STAGE,
                    IF_ID_STAGE_out        => IF_ID_STAGE,
                    ID_EX_STAGE_out        => ID_EX_STAGE,
                    EX_MEM_STAGE_out       => EX_MEM_STAGE,
                    MEM_WB_STAGE_out       => MEM_WB_STAGE,      
                    ID_EX_out              => ID_EX,
                    EX_MEM_out             => EX_MEM,
                    MEM_WB_out             => MEM_WB,
                    WB_out                 => WB,
                    num_stall              => stall,
                    ForwardA_out           => ForwardA,
                    ForwardB_out           => ForwardB
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
    
    process(ForwardA)
    variable haz_MEM_WB_A : integer := 0;
    begin
        if ForwardA = FORWARD_MEM_WB then
            haz_MEM_WB_A := haz_MEM_WB_A + 1;
            report " Expected Hazard: ForwardA = FORWARD_MEM_WB | rs2 = " & to_hexstring(MEM_WB.rd);
        elsif ForwardA = FORWARD_EX_MEM then
            haz_MEM_WB_A := haz_MEM_WB_A + 1;
            report " Expected Hazard: ForwardA = FORWARD_EX_MEM | rs2 = " & to_hexstring(EX_MEM.rd);
        end if;
    
        -- Print summary at end of simulation
        if now >= 4999 ns then
            report "========== Forwarding Test Summary ==========";
            report "ForwardB from EX_MEM (rs2 hazards): " & integer'image(haz_MEM_WB_A);
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
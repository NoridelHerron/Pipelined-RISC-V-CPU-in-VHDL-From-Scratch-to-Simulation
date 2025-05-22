----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2025 02:06:16 PM
-- Design Name: 
-- Module Name: RISCV_CPU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Pipeline_Types.all;

-- CUSTOMIZED PACKAGE
use work.Pipeline_Types.all;

entity RISCV_CPU is
    Port (  clk                    : in std_logic;
            reset                  : in std_logic;
            -- IF
            IF_STAGE_out           : out PipelineStages_Inst_PC;
            ID_STAGE_out           : out PipelineStages_Inst_PC;
            EX_STAGE_out           : out PipelineStages_Inst_PC;
            MEM_STAGE_out          : out PipelineStages_Inst_PC;
            WB_STAGE_out           : out PipelineStages_Inst_PC;
            IF_ID_STAGE_out        : out PipelineStages_Inst_PC;
            ID_EX_STAGE_out        : out PipelineStages_Inst_PC;
            EX_MEM_STAGE_out       : out PipelineStages_Inst_PC;
            MEM_WB_STAGE_out       : out PipelineStages_Inst_PC;
            ID_out                 : out ID_EX_Type;
            ID_EX_out              : out ID_EX_Type;
            EX_out                 : out EX_MEM_Type;
            EX_MEM_out             : out EX_MEM_Type;
            MEM_out                : out MEM_WB_Type;
            MEM_WB_out             : out MEM_WB_Type;
            WB_out                 : out WB_Type;   
            num_stall              : out numStall;
            ForwardA_out           : out ForwardingType;
            ForwardB_out           : out ForwardingType 
         );
end RISCV_CPU;

architecture Behavioral of RISCV_CPU is

    signal ForwardA         : ForwardingType                := FORWARD_NONE;
    signal ForwardB         : ForwardingType                := FORWARD_NONE;
    
    signal IF_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc; 
    signal IF_ID_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal ID_EX_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal EX_MEM_STAGE     : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal MEM_WB_STAGE     : PipelineStages_Inst_PC        := EMPTY_inst_pc;
 
    signal ID               : ID_EX_Type                    := EMPTY_ID_EX_Type;
    signal ID_EX            : ID_EX_Type                    := EMPTY_ID_EX_Type;  
    signal EX               : EX_MEM_Type                   := EMPTY_EX_MEM_Type;
    signal EX_MEM           : EX_MEM_Type                   := EMPTY_EX_MEM_Type; 
    signal MEM              : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    signal MEM_WB           : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    signal WB               : WB_Type                       := EMPTY_WB_Type;

    signal stall            : numStall                      := STALL_NONE;
    
begin

    IF_STAG : entity work.IF_STA port map (
        clk             => clk,
        reset           => reset,
        IF_STAGE        => IF_STAGE        
    );
    
    IF_TO_ID_STAGE : entity work.IF_TO_ID port map (
        clk             => clk,
        reset           => reset,
        IF_STAGE        => IF_STAGE,
        IF_ID_STAGE     => IF_ID_STAGE        
    );
    
    DECODE : entity work.DECODER port map (
        clk             => clk,
        reset           => reset,
        IF_ID_STAGE     => IF_ID_STAGE,
        EX_MEM          => EX_MEM,
        MEM_WB          => MEM_WB,
        WB              => WB,
        ID              => ID, 
        Forward_A       => ForwardA,
        Forward_B       => ForwardB,
        stall           => stall
    );
    
    ID_TO_EX_STAGE : entity work.ID_TO_EX port map (
        clk             => clk,
        reset           => reset,
        ID_STAGE        => IF_ID_STAGE,
        ID              => ID,
        ID_EX_STAGE     => ID_EX_STAGE,
        ID_EX           => ID_EX
    );
    
    EXECUTION : entity work.EX_STAGE port map (
        reg_data1_in    => ID_EX.reg_data1,
        reg_data2_in    => ID_EX.reg_data2,
        op_in           => ID_EX.op,
        f3_in           => ID_EX.funct3,
        f7_in           => ID_EX.funct7,
        EX              => EX   
    );
    
    EX_TO_MEM_STAGE : entity work.EX_TO_MEM port map (
        clk             => clk,
        reset           => reset,
        EX_STAGE        => ID_EX_STAGE,
        EX              => EX, 
        EX_MEM_STAGE    => EX_MEM_STAGE,
        EX_MEM          => EX_MEM
    );
    
    MEM_STA : entity work.MEM_STA port map (
        clk             => clk,
        reset           => reset,
        EX_MEM          => EX_MEM,
        -- Outputs to MEM/WB pipeline register
        MEM             => MEM 
    );
    
    MEM_TO_WB_STAGE : entity work.MEM_TO_WB port map (
        clk             => clk,
        reset           => reset,
        EX_MEM          => EX_MEM,
        MEM             => MEM,
        EX_MEM_STAGE    => EX_MEM_STAGE,
        MEM_WB          => MEM_WB,
        MEM_WB_STAGE    => MEM_WB_STAGE
    );
    
    WB_ST : entity work.WB_STA port map (
        MEM_WB          => MEM_WB,
        WB              => WB
    );
    
    -- Assign output for the CPU
    IF_STAGE_out           <= IF_STAGE;
    IF_ID_STAGE_out        <= IF_ID_STAGE;
    ID_EX_STAGE_out        <= ID_EX_STAGE;
    EX_MEM_STAGE_out       <= EX_MEM_STAGE;
    MEM_WB_STAGE_out       <= MEM_WB_STAGE;
    ID_out                 <= ID;
    ID_EX_out              <= ID_EX;
    EX_out                 <= EX;
    EX_MEM_out             <= EX_MEM;
    MEM_out                <= MEM;
    MEM_WB_out             <= MEM_WB;
    WB_out                 <= WB;
    num_stall              <= stall;
    ForwardA_out           <= ForwardA;
    ForwardB_out           <= ForwardB;
    

end Behavioral;

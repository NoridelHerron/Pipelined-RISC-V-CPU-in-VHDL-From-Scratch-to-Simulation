----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_Types.all;

entity RISCV_CPU is
    Port (  clk             : in std_logic;
            reset           : in std_logic;
            -- pc and instruction
            IF_STAGE_out    : out PipelineStages_Inst_PC; 
            ID_STAGE_out    : out PipelineStages_Inst_PC;
            EX_STAGE_out    : out PipelineStages_Inst_PC;
            MEM_STAGE_out   : out PipelineStages_Inst_PC;
            WB_STAGE_out    : out PipelineStages_Inst_PC;
            -- stage/registers
            ID_EX_out       : out ID_EX_Type;
            EX_MEM_out      : out EX_MEM_Type;   
            MEM_WB_out      : out MEM_WB_Type;
            WB_out          : out WB_Type; 
            -- register source value
            reg_out         : out reg_Type;
            flush           : out std_logic; 
            -- data hazard solutions
            num_stall       : out numStall;
            Forward_out     : out FORWARD 
         );
end RISCV_CPU;

architecture Behavioral of RISCV_CPU is

    -- data hazard handlers
    signal Forward       : FORWARD                      := EMPTY_FORW_Type;
    signal stall         : numStall                     := STALL_NONE;
   
    -- pc and instruction
    signal IF_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc; 
    signal ID_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal EX_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal MEM_STAGE     : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal WB_STAGE      : PipelineStages_Inst_PC        := EMPTY_inst_pc;
 
    -- stage and in-between stages registers
    signal ID            : ID_EX_Type                    := EMPTY_ID_EX_Type;
    signal ID_EX         : ID_EX_Type                    := EMPTY_ID_EX_Type;   
    signal EX            : EX_MEM_Type                   := EMPTY_EX_MEM_Type;
    signal EX_MEM        : EX_MEM_Type                   := EMPTY_EX_MEM_Type; 
    signal MEM           : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    signal MEM_WB        : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    signal WB            : WB_Type                       := EMPTY_WB_Type;
    
    -- register data value from the register source 
    signal ID_reg               : reg_Type                      := EMPTY_reg_Type;
    -- data value from either register source or value forwarded
    signal EX_reg               : reg_Type                      := EMPTY_reg_Type;
    signal is_flush             : std_logic                     := '0';
    
begin
 
    IF_STAG : entity work.IF_STA port map (
        clk             => clk,
        reset           => reset,
        flush           => is_flush,
        br_target       => ID_EX.br_target,
        stall           => stall,
        IF_STAGE        => IF_STAGE      
    );
    
    IF_TO_ID_STAGE : entity work.IF_TO_ID port map (
        clk            => clk,
        reset          => reset, 
        flush          => is_flush, 
        stall          => stall,
        IF_STAGE       => IF_STAGE,
        IF_ID_STAGE    => ID_STAGE        
    );
    
    ID_HDU : entity work.ID_STA port map (    
        clk             => clk,
        reset           => reset,
        ID_STAGE        => ID_STAGE,  
        WB              => WB,
        ID_EX           => ID_EX,
        EX_MEM          => EX_MEM, 
        MEM_WB          => MEM_WB, 
        ID              => ID,
        Forward_out     => Forward,
        stall_out       => stall,
        reg_out         => ID_reg 
    );
    
    ID_TO_EX_STAGE : entity work.ID_TO_EX port map (
        clk             => clk,
        reset           => reset,  
        flush           => is_flush, 
        stall           => stall,  
        ID_STAGE        => ID_STAGE,
        ID              => ID, 
        ID_EX_STAGE     => EX_STAGE,
        ID_EX           => ID_EX
    );
    
    EX_ST : entity work.EX_STAGE port map (
        ID_EX_STAGE     => EX_STAGE,
        EX_MEM          => EX_MEM,
        WB              => WB,
        ID_EX           => ID_EX,
        Forward         => Forward,
        reg_in          => ID_reg,
        EX              => EX, 
        reg_out         => EX_reg,
        is_flush        => is_flush      
    ); 
    
    EX_TO_MEM_STAGE : entity work.EX_TO_MEM port map (
        clk             => clk,
        reset           => reset,
        EX_STAGE        => EX_STAGE,
        EX              => EX, 
        EX_MEM_STAGE    => MEM_STAGE,
        EX_MEM          => EX_MEM
    );
    
    MEM_STA : entity work.MEM_STA port map (
        clk             => clk,
        reset           => reset,
        EX_MEM          => EX_MEM,
        MEM             => MEM 
    );
    
    MEM_TO_WB_STAGE : entity work.MEM_TO_WB port map (
        clk             => clk,
        reset           => reset,
        EX_MEM          => EX_MEM,
        MEM             => MEM,
        EX_MEM_STAGE    => MEM_STAGE,
        MEM_WB          => MEM_WB,
        MEM_WB_STAGE    => WB_STAGE
    );
    
    WB_ST : entity work.WB_STA port map (
        MEM_WB          => MEM_WB,
        WB              => WB
    );
    
    -- Assign output
    IF_STAGE_out        <= IF_STAGE;
    ID_STAGE_out        <= ID_STAGE;
    EX_STAGE_out        <= EX_STAGE;
    MEM_STAGE_out       <= MEM_STAGE;
    WB_STAGE_out        <= WB_STAGE;
    ID_EX_out           <= ID_EX;
    reg_out             <= ID_reg;
    EX_MEM_out          <= EX_MEM;
    MEM_WB_out          <= MEM_WB;
    WB_out              <= WB;
    num_stall           <= stall;
    Forward_out         <= Forward; 
    flush               <= is_flush; 

end Behavioral;
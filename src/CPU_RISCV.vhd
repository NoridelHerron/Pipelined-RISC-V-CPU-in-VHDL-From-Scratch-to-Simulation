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
use work.Pipeline_Types.all;


entity CPU_RISCV is
    Port (  clk                    : in std_logic;
            reset                  : in std_logic;
            -- For forwarding
            ENABLE_FORWARDING      : in std_logic;

            -- Optional output for test bench
            -- IF
            IF_inst_out            : out std_logic_vector(31 downto 0);
            IF_ID_inst_out         : out std_logic_vector(31 downto 0);
            IF_pc_out              : out std_logic_vector(31 downto 0);

            -- ID
            ID_EX_inst_out         : out std_logic_vector(31 downto 0);
            ID_EX_op_out           : out std_logic_vector(6 downto 0);
            ID_EX_f3_out           : out std_logic_vector(2 downto 0);
            ID_EX_f7_out           : out std_logic_vector(6 downto 0);
            ID_EX_reg_data1_out    : out std_logic_vector(31 downto 0);
            ID_EX_reg_data2_out    : out std_logic_vector(31 downto 0);
            ID_EX_store_rs2_out    : out std_logic_vector(31 downto 0);
            ID_EX_rd_out           : out std_logic_vector(4 downto 0);  
            rs1                    : out std_logic_vector(4 downto 0);  
            rs2                    : out std_logic_vector(4 downto 0);  

            -- EX
            EX_MEM_inst_out        : out std_logic_vector(31 downto 0);
            EX_MEM_result_out      : out std_logic_vector(31 downto 0);
            Flags_out              : out std_logic_vector(3 downto 0);      
            EX_MEM_op_out          : out std_logic_vector(6 downto 0);
            EX_MEM_rd_out          : out std_logic_vector(4 downto 0);
            EX_MEM_store_rs2_out   : out std_logic_vector(31 downto 0);

            -- MEM
            MEM_WB_inst_out        : out std_logic_vector(31 downto 0);
            MEM_WB_mem_out_out     : out std_logic_vector(31 downto 0);
            MEM_WB_write_out       : out std_logic;
            MEM_WB_rd_out          : out std_logic_vector(4 downto 0);

            -- WB
            WB_ID_data_out         : out std_logic_vector(31 downto 0);
            WB_ID_write_out        : out std_logic;
            num_stall              : out std_logic_vector(1 downto 0);
            ForwardA_out           : out std_logic_vector(1 downto 0);
            ForwardB_out           : out std_logic_vector(1 downto 0) 
         );
end CPU_RISCV;


architecture FLOW of CPU_RISCV is

    signal ForwardA         : ForwardingType                := FORWARD_NONE;
    signal ForwardB         : ForwardingType                := FORWARD_NONE;
   
    signal IF_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal ID_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal EX_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal MEM_STAGE        : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    signal WB_STAGE         : PipelineStages_Inst_PC        := EMPTY_inst_pc;
    
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
    signal WB               : MEM_WB_Type                   := EMPTY_MEM_WB_Type;
    
    signal WB_content       : WB_Type                       := EMPTY_WB_Type;

    signal IF_insert        : INSERT_stall                  := EMPTY_INSERT_stall;
    signal IF_ID_insert     : INSERT_stall                  := EMPTY_INSERT_stall;
    signal ID_insert        : INSERT_stall                  := EMPTY_INSERT_stall;
    
    signal reg1_value       : std_logic_vector(31 downto 0) := (others => '0');
    signal reg2_value       : std_logic_vector(31 downto 0) := (others => '0'); 
    signal Forward_A        : std_logic_vector(1 downto 0)  := (others => '0'); 
    signal Forward_B        : std_logic_vector(1 downto 0)  := (others => '0'); 
    signal S_immediate      : std_logic_vector(11 downto 0) := (others => '0'); 
    signal I_immediate      : std_logic_vector(11 downto 0) := (others => '0'); 
   
begin
--------------------- IF STAGE ---------------------------  
    IF_STAGE_UUT : entity work.IF_STAGE
        port map (
            -- inputs
            clk             => clk,
            rst             => reset,    
            -- outputs   
            instr_out       => IF_STAGE.instr,
            pc_out          => IF_STAGE.pc        
        );
    
    
--------------------- IF/ID STAGE ---------------------------  
    process (clk, reset)
    begin
        if reset = '1' then
            IF_ID_STAGE.instr <= (others => '0');
            IF_ID_STAGE.pc    <= (others => '0');
        elsif rising_edge (clk)then
            if ENABLE_FORWARDING = '0' then
                if ID_insert.stall = "00" then
                    IF_ID_STAGE.pc      <= IF_STAGE.pc;
                    IF_ID_STAGE.instr   <= IF_STAGE.instr;
                    ID_insert.stall   <= ID_insert.stall;     
                elsif ID_insert.stall > "00" then
                    IF_ID_STAGE.pc      <= x"00000000";
                    case ID_insert.stall is
                        when "01" =>
                            IF_ID_STAGE.instr <= NOP;
                            ID_insert.stall        <= "00";
                        when "10" =>
                            IF_ID_STAGE.instr   <= NOP;
                            ID_insert.stall    <= "01";  
                        when "11" =>
                            IF_ID_STAGE.instr  <= NOP;
                            ID_insert.stall    <= "11"; 
                        when others => 
                            IF_ID_STAGE.instr  <= (others => '0');   
                            ID_insert.stall    <= (others => '0');      
                    end case;
                end if;
             else
                IF_ID_STAGE.pc          <= IF_STAGE.pc;
                IF_ID_STAGE.instr       <= IF_STAGE.instr;
             end if;
        end if;  
    end process;
--------------------- ID STAGE ---------------------------            
    ID_STAGE_UUT : entity work.DECODER
        port map ( 
            FORWARDING      => ENABLE_FORWARDING,
            instr_in        => IF_ID_STAGE.instr,     
            EX_MEM_rd       => EX_MEM.rd, 
            EX_MEM_op       => EX_MEM.op, 
            MEM_WB_op       => MEM_WB.op, 
            MEM_WB_rd       => MEM_WB.rd, 
            -- outputs
            Forward_A       => Forward_A, 
            Forward_B       => Forward_B, 
            num_NOP         => ID_insert.stall, 
            op              => ID.op,
            f3              => ID.funct3,
            f7              => ID.funct7,     
            rd              => ID.rd,
            rs1             => ID.rs1,
            rs2             => ID.rs2,
            S_immediate     => S_immediate,
            I_immediate     => I_immediate
        );
        
    REGISTER_UUT: entity work.RegisterFile
        port map ( clk            => clk, 
                   rst            => reset, 
                   write_enable   => WB_content.write, 
                   write_addr     => MEM_WB.rd, 
                   write_data     => WB_content.data, 
                   read_addr1     => ID.rs1, 
                   read_addr2     => ID.rs2, 
                   read_data1     => reg1_value, 
                   read_data2     => reg2_value
                   ); 
                     
    process(Forward_A, Forward_B, reg1_value, reg2_value, I_immediate, S_immediate, WB_content.data, EX_MEM.result)
    begin
        if ENABLE_FORWARDING = '1' then
            case ForwardA is
                when FORWARD_NONE   => ID.reg_data1 <= reg1_value;
                when FORWARD_EX_MEM => ID.reg_data1 <= WB_content.data;      
                when FORWARD_MEM_WB => ID.reg_data1 <= EX_MEM.result; 
                when others => ID.reg_data1 <= (others => '0');
            end case;
            case ForwardB is
                when FORWARD_NONE =>
                    case ID.op is
                        when R_TYPE => -- R-type: use second register value
                            ID.reg_data2 <= reg2_value;
                            
                        when I_IMM | LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                            ID.reg_data2  <= std_logic_vector(resize(signed(I_immediate), 32));
                            
                        when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                            ID.reg_data2  <= std_logic_vector(resize(signed(S_immediate), 32));
                            ID.store_rs2  <= reg2_value;
                        when others => 
                            ID.reg_data2  <= (others => '0');
                    end case;
                when FORWARD_EX_MEM => -- from MEM_WB stage
                    ID.reg_data2 <= WB_content.data;
                when FORWARD_MEM_WB => -- from EX_MEM stage
                    ID.reg_data2 <= EX_MEM.result;
                when others => ID.reg_data2 <= (others => '0');
            end case;
        else
            ID.reg_data1 <= reg1_value;
            case ID.op is
                when R_TYPE => -- R-type: use second register value
                    ID.reg_data2 <= reg2_value;
                    
                when I_IMM | LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                    ID.reg_data2  <= std_logic_vector(resize(signed(I_immediate), 32));
                    
                when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                    ID.reg_data2  <= std_logic_vector(resize(signed(S_immediate), 32));
                    ID.store_rs2  <= reg2_value;
                when others => 
                    ID.reg_data2  <= (others => '0');
            end case;
        end if;   
    end process;
    
--------------------- ID/EX STAGE ---------------------------  
    process (clk, reset)
    variable rd_temp : std_logic_vector(4 downto 0);
    begin
        if reset = '1' then
            ID_EX_STAGE.instr   <= (others => '0'); 
            ID_EX               <= EMPTY_ID_EX_Type;   
        elsif rising_edge (clk)then 
            if ID.op = S_TYPE then
                rd_temp := (others => '0');
            else
                rd_temp := ID.rd;
            end if; 
            ID_EX.store_rs2     <= ID.store_rs2;
            ID_EX_STAGE.instr   <= IF_ID_STAGE.instr;
            ID_EX.reg_data1     <= ID.reg_data1;  
            ID_EX.reg_data2     <= ID.reg_data2;  
            ID_EX.op            <= ID.op; 
            ID_EX.funct3        <= ID.funct3;
            ID_EX.funct7        <= ID.funct7; 
            ID_EX.rd            <= rd_temp;
        end if;  
    end process;
    
 
--------------------- EX STAGE ---------------------------  
    
    -- Flags(3) = Z flag; Flags(2) = N flag; Flags(1) = C flag; Flags(0) = V flag
    EX_STAGE_UUT : entity work.EX_STAGE
        port map (
            -- inputs
            reg_data1_in    => ID_EX.reg_data1,
            reg_data2_in    => ID_EX.reg_data2,
            op_in           => ID_EX.op,
            f3_in           => ID_EX.funct3,
            f7_in           => ID_EX.funct7,  
            -- outputs
            result_out      => EX.result,
            Z_flag_out      => EX.Flags(3),
            V_flag_out      => EX.Flags(2),
            C_flag_out      => EX.Flags(1),
            N_flag_out      => EX.Flags(0),
            op_out          => EX.op
        );
        

 --------------------- EX/MEM STAGE ---------------------------
    process (clk, reset)
    begin
        if reset = '1' then
            EX_MEM_STAGE.instr  <= (others => '0'); 
            EX_MEM              <= EMPTY_EX_MEM_Type;    
        elsif rising_edge (clk)then
            EX_MEM_STAGE.instr  <= ID_EX_STAGE.instr;
            EX_MEM.store_rs2    <= ID_EX.store_rs2; 
            EX_MEM.result       <= EX.result; 
            EX_MEM.op           <= EX.op; 
            EX_MEM.rd           <= ID_EX.rd; 
            
        end if;  
    end process;
      
    MEM_STAGE_UUT : entity work.MEM_STAGE
        port map (
            -- inputs
            clk           => clk,   
            alu_result    => EX_MEM.result,
            write_data    => EX_MEM.store_rs2,
            op_in         => EX_MEM.op,
            -- outputs
            mem_out       => MEM.mem_result,
            reg_write_out => MEM.ALU_write,
            mem_reg_out   => MEM.MEM_write
         );
  --------------------- MEM/WB STAGE ---------------------------   
  process (clk, reset)
    begin
        if reset = '1' then
            MEM_WB_STAGE.instr  <= (others => '0');
            MEM_WB              <= EMPTY_MEM_WB_Type;
            
        elsif rising_edge (clk)then
            MEM_WB_STAGE.instr  <= EX_MEM_STAGE.instr;
            MEM_WB.alu_result   <= EX_MEM.result;
            MEM_WB.mem_result   <= MEM.mem_result;
            MEM_WB.rd           <= EX_MEM.rd;
            MEM_WB.ALU_write    <= MEM.ALU_write;
            MEM_WB.MEM_write    <= MEM.MEM_write;
            
        end if;  
    end process;
    
 --------------------- WB STAGE ---------------------------   
    WB_STAGE_UUT : entity work.WB_STAGE
        port map (
            ALU_in         => MEM_WB.alu_result,
            mem_in         => MEM_WB.mem_result,
            reg_write_in   => MEM_WB.ALU_write,
            MemToReg_in    => MEM_WB.MEM_write,
    
            data_out       => WB_content.data,
            reg_write_out  => WB_content.write       
        );

    -- Assign output for the CPU
    IF_inst_out             <= IF_STAGE.instr;
    IF_ID_inst_out          <= IF_ID_STAGE.instr;
    IF_pc_out               <= IF_STAGE.pc;
    
    ID_EX_inst_out          <= ID_EX_STAGE.instr;
    ID_EX_op_out            <= ID_EX.op;
    ID_EX_f3_out            <= ID_EX.funct3;
    ID_EX_f7_out            <= ID_EX.funct7;
    ID_EX_reg_data1_out     <= ID_EX.reg_data1;
    ID_EX_reg_data2_out     <= ID_EX.reg_data2;
    ID_EX_store_rs2_out     <= ID_EX.store_rs2;
    ID_EX_rd_out            <= ID_EX.rd;
    rs1                     <= ID.rs1;
    rs2                     <= ID.rs2;
    
    EX_MEM_inst_out         <= EX_MEM_STAGE.instr;
    Flags_out               <= EX_MEM.Flags;
    EX_MEM_result_out       <= EX_MEM.result;    
    EX_MEM_op_out           <= EX_MEM.op;
    EX_MEM_rd_out           <= EX_MEM.rd;
    EX_MEM_store_rs2_out    <= EX_MEM.store_rs2;
    
    MEM_WB_inst_out         <= MEM_WB_STAGE.instr;
    MEM_WB_mem_out_out      <= MEM_WB.mem_result;    
    MEM_WB_write_out        <= MEM.MEM_write;
    MEM_WB_rd_out           <= MEM_WB.rd;
    
    WB_ID_data_out          <= WB_content.data;
    WB_ID_write_out         <= WB_content.write;
    num_stall               <= ID_insert.stall;
    ForwardA_out            <= Forward_A;
    ForwardB_out            <= Forward_B;

end FLOW;
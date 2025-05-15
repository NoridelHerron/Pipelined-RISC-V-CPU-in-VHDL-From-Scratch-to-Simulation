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
    Port (  clk                    : in std_logic;
            reset                  : in std_logic;
            -- For forwarding
            ENABLE_FORWARDING      : in std_logic;

            -- Optional output for test bench
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
            -- Flags(3) = Z flag; Flags(2) = N flag; Flags(1) = C flag; Flags(0) = V flag
            Flags_out              : out std_logic_vector(3 downto 0);      
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
            WB_ID_write_out        : out std_logic );
end CPU_RISCV;

architecture FLOW of CPU_RISCV is

    component IF_STAGE
        Port ( 
                clk, rst  : in  std_logic;   
                instr_out : out std_logic_vector(31 downto 0); 
                pc_out    : out std_logic_vector(31 downto 0) 
              ); 
    end component;
--------------------------------------------------------------------------------------------
    component IF_ID_STAGE
        Port (
                clk             : in  std_logic;
                rst             : in  std_logic;
                num_stall_in    : in  std_logic_vector(1 downto 0);
                instr_in        : in  std_logic_vector(31 downto 0);
                pc_in           : in  std_logic_vector(31 downto 0);
                
                num_stall_out   : out std_logic_vector(1 downto 0);
                instr_out       : out std_logic_vector(31 downto 0);
                pc_out          : out std_logic_vector(31 downto 0)
              );
    end component;
--------------------------------------------------------------------------------------------
    component DECODER
        Port (  -- inputs
                clk             : in  std_logic;
                rst             : in  std_logic;    
                -- input from IF 
                instr_in        : in  std_logic_vector(31 downto 0); 
                -- input from WB
                data_in         : in  std_logic_vector(31 downto 0);
                wb_rd           : in  std_logic_vector(4 downto 0);  -- Writeback destination reg
                wb_reg_write    : in  std_logic;                     -- Writeback enable signal
                -- control outputs to EX -> MEM -> WB            
                op              : out std_logic_vector(2 downto 0);  -- opcode control signal
                f3              : out std_logic_vector(2 downto 0);  -- function 3
                f7              : out std_logic_vector(6 downto 0);  -- function 7 
                -- register file outputs
                reg_data1       : out std_logic_vector(31 downto 0);  -- value in register source 1
                reg_data2       : out std_logic_vector(31 downto 0);  -- value in register source 2 or immediate
                store_rs2       : out std_logic_vector(31 downto 0);  -- RS2 value for stores 
                rs1             : out std_logic_vector(4 downto 0);
                rs2             : out std_logic_vector(4 downto 0);   
                rd_out          : out std_logic_vector(4 downto 0) );
    end component;
--------------------------------------------------------------------------------------------
    component ID_EX
        Port (  
                clk             : in  std_logic;
                rst             : in  std_logic;
                
                ForwardA        : in  std_logic_vector(1 downto 0);
                ForwardB        : in  std_logic_vector(1 downto 0);
                EX_MEM_RES      : in  std_logic_vector(31 downto 0); 
                MEM_WB_RES      : in  std_logic_vector(31 downto 0);  
                
                op_in           : in  std_logic_vector(2 downto 0);  
                f3_in           : in  std_logic_vector(2 downto 0);  
                f7_in           : in  std_logic_vector(6 downto 0);  
                -- register file outputs
                reg_data1_in    : in  std_logic_vector(31 downto 0);  
                reg_data2_in    : in  std_logic_vector(31 downto 0);  
                store_rs2_in    : in  std_logic_vector(31 downto 0);  
                rd_in           : in  std_logic_vector(4 downto 0);
                
                op_out          : out std_logic_vector(2 downto 0);  
                f3_out          : out std_logic_vector(2 downto 0);  
                f7_out          : out std_logic_vector(6 downto 0);  
                -- register file outputs
                reg_data1_out   : out std_logic_vector(31 downto 0);  
                reg_data2_out   : out std_logic_vector(31 downto 0);  
                store_rs2_out   : out std_logic_vector(31 downto 0);  
                rd_out          : out std_logic_vector(4 downto 0)
             );
    end component;
--------------------------------------------------------------------------------------------
    component EX_STAGE
        Port (  -- inputs 
                clk             : in  std_logic;
                rst             : in  std_logic;
                -- inputs from ID stage
                reg_data1_in    : in  std_logic_vector(31 downto 0);
                reg_data2_in    : in  std_logic_vector(31 downto 0);
                op_in           : in  std_logic_vector(2 downto 0);
                f3_in           : in  std_logic_vector(2 downto 0);
                f7_in           : in  std_logic_vector(6 downto 0);
                rd_in           : in  std_logic_vector(4 downto 0);
                store_rs2_in    : in  std_logic_vector(31 downto 0);
                -- output to MEM stage
                result_out      : out std_logic_vector(31 downto 0);
                Z_flag_out      : out std_logic;
                V_flag_out      : out std_logic;
                C_flag_out      : out std_logic;
                N_flag_out      : out std_logic;
                write_data_out  : out std_logic_vector(31 downto 0);
                op_out          : out std_logic_vector(2 downto 0);
                rd_out          : out std_logic_vector(4 downto 0) );
    end component;
--------------------------------------------------------------------------------------------
component EX_MEM_STAGE
        Port ( 
            clk             : in  std_logic;
            rst             : in  std_logic;
            result_in     : in  std_logic_vector(31 downto 0);
            Z_flag_in     : in  std_logic;
            V_flag_in     : in  std_logic;
            C_flag_in     : in  std_logic;
            N_flag_in     : in  std_logic;
            write_data_in : in  std_logic_vector(31 downto 0);       
            op_in         : in  std_logic_vector(2 downto 0);
            rd_in         : in  std_logic_vector(4 downto 0); 
            result_out    : out std_logic_vector(31 downto 0);
            Z_flag_out    : out std_logic;
            V_flag_out    : out std_logic;
            C_flag_out    : out std_logic;
            N_flag_out    : out std_logic;
            write_data_out: out std_logic_vector(31 downto 0);       
            op_out        : out std_logic_vector(2 downto 0);
            rd_out        : out std_logic_vector(4 downto 0)
          );
    end component;
--------------------------------------------------------------------------------------------
    component MEM_STAGE
        Port (  -- inputs
                clk           : in  std_logic;
                rst           : in  std_logic;
               -- input from EX/MEM REGISTERs
                alu_result    : in  std_logic_vector(31 downto 0);
                write_data    : in  std_logic_vector(31 downto 0);
                op_in         : in  std_logic_vector(2 downto 0);
                rd_in         : in  std_logic_vector(4 downto 0);
                -- outputs to WB stage
                mem_out       : out std_logic_vector(31 downto 0);
                reg_write_out : out std_logic;
                rd_out        : out std_logic_vector(4 downto 0) );
    end component;
--------------------------------------------------------------------------------------------
    component MEM_WB_STAGE
        Port ( 
                clk             : in  std_logic;
                rst             : in  std_logic;
                mem_in        : in  std_logic_vector(31 downto 0); -- Load data or passthrough ALU result
                reg_write_in  : in  std_logic;                     -- Register write enable
                rd_in         : in  std_logic_vector(4 downto 0);   -- Pass-through
                mem_out       : out std_logic_vector(31 downto 0); -- Load data or passthrough ALU result
                reg_write_out : out std_logic;                     -- Register write enable
                rd_out        : out std_logic_vector(4 downto 0)   -- Pass-through  
              );
    end component;
--------------------------------------------------------------------------------------------
    component WB_STAGE
        Port (  
            clk             : in  std_logic;
            rst             : in  std_logic;
            -- inputs from MEM/WB REGISTER
            data_in       : in  std_logic_vector(31 downto 0);     -- Final result from MEM_STAGE
            rd_in         : in  std_logic_vector(4 downto 0);      -- Destination register
            reg_write_in  : in  std_logic;                         -- Write enable signal from MEM_STAGE
            -- output to ID STAGE
            data_out      : out std_logic_vector(31 downto 0);     -- Data to write to register file
            rd_out        : out std_logic_vector(4 downto 0);      -- Register index
            reg_write_out : out std_logic);
    end component;

    component WB_ID_STAGE
        Port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            data_in       : in  std_logic_vector(31 downto 0);     -- Data to write to register file
            rd_in         : in  std_logic_vector(4 downto 0);      -- Register index
            reg_write_in  : in  std_logic;
            data_out      : out std_logic_vector(31 downto 0);     -- Data to write to register file
            rd_out        : out std_logic_vector(4 downto 0);      -- Register index
            reg_write_out : out std_logic
          );
    end component;
 
    --------------------- IF STAGE ---------------------------  
    signal IF_instruction       : std_logic_vector(31 downto 0);   
    signal IF_pc                : std_logic_vector(31 downto 0);
    -----------------------ID STAGE----------------------------
    signal IF_ID_instruction       : std_logic_vector(31 downto 0);   
    signal IF_ID_pc             : std_logic_vector(31 downto 0);
    -----------------------ID STAGE----------------------------
    signal ID_op                : std_logic_vector(2 downto 0);
    signal ID_f3                : std_logic_vector(2 downto 0);
    signal ID_f7                : std_logic_vector(6 downto 0);
    signal ID_reg_data1         : std_logic_vector(31 downto 0);
    signal ID_reg_data2         : std_logic_vector(31 downto 0);
    signal ID_store_rs2         : std_logic_vector(31 downto 0);
    signal ID_rd                : std_logic_vector(4 downto 0);
    signal rs1_addr             : std_logic_vector(4 downto 0);
    signal rs2_addr             : std_logic_vector(4 downto 0);
    ----------------------ID/EX STAGE----------------------------
    signal ID_EX_op             : std_logic_vector(2 downto 0);
    signal ID_EX_f3             : std_logic_vector(2 downto 0);
    signal ID_EX_f7             : std_logic_vector(6 downto 0);
    signal ID_EX_reg_data1      : std_logic_vector(31 downto 0);
    signal ID_EX_reg_data2      : std_logic_vector(31 downto 0);
    signal ID_EX_store_rs2      : std_logic_vector(31 downto 0);
    signal ID_EX_rd             : std_logic_vector(4 downto 0);
    ------------------------ EX STAGE ------------------------
    signal EX_Flags             : std_logic_vector(3 downto 0);
    signal EX_result            : std_logic_vector(31 downto 0);
    signal EX_op                : std_logic_vector(2 downto 0);
    signal EX_rd                : std_logic_vector(4 downto 0);
    signal EX_store_rs2         : std_logic_vector(31 downto 0);
    ----------------------EX/MEM STAGE----------------------------
    signal EX_MEM_Flags         : std_logic_vector(3 downto 0);
    signal EX_MEM_result        : std_logic_vector(31 downto 0);
    signal EX_MEM_op            : std_logic_vector(2 downto 0);
    signal EX_MEM_rd            : std_logic_vector(4 downto 0);
    signal EX_MEM_store_rs2     : std_logic_vector(31 downto 0);
    ----------------------MEM STAGE----------------------------
    signal MEM_mem_out          : std_logic_vector(31 downto 0);
    signal MEM_write            : std_logic;
    signal MEM_rd               : std_logic_vector(4 downto 0);
    ----------------------MEM/WB STAGE----------------------------
    signal MEM_WB_mem_out       : std_logic_vector(31 downto 0);
    signal MEM_WB_write         : std_logic;
    signal MEM_WB_rd            : std_logic_vector(4 downto 0);
    ----------------------WB STAGE----------------------------
    signal WB_data              : std_logic_vector(31 downto 0);
    signal WB_rd                : std_logic_vector(4 downto 0);
    signal WB_write             : std_logic;
    ----------------------WB/ID STAGE----------------------------
    signal WB_ID_data           : std_logic_vector(31 downto 0);
    signal WB_ID_rd             : std_logic_vector(4 downto 0);
    signal WB_ID_write          : std_logic;
    --------------------- STALLING ---------------------
    signal num_stall            : std_logic_vector(1 downto 0);
    --------------------- FORWADING ---------------------  
    -- For forwading
    signal ForwardA             : std_logic_vector(1 downto 0);
    signal ForwardB             : std_logic_vector(1 downto 0); 
    
begin
--------------------- IF STAGE ---------------------------  
    IF_STAGE_UUT : IF_STAGE
        port map (
            -- inputs
            clk             => clk,
            rst             => reset,    
            -- outputs
            instr_out       => IF_instruction,
            pc_out          => IF_pc        
        );
--------------------- IF_ID STAGE ---------------------------  
    IF_ID_STAGE_UUT : IF_ID_STAGE
        port map (
            -- inputs
            clk             => clk,
            rst             => reset,
            num_stall_in    => num_stall,  
            instr_in        => IF_instruction,
            pc_in           => IF_pc,   
            -- outputs
            instr_out       => IF_ID_instruction,
            pc_out          => IF_ID_pc        
        );
--------------------- ID STAGE ---------------------------            
    ID_STAGE_UUT : DECODER
        port map (
            -- inputs
            clk          => clk,
            rst          => reset,
            
            instr_in     => IF_ID_instruction,                 
            data_in      => WB_ID_data,
            wb_rd        => WB_ID_rd,
            wb_reg_write => WB_ID_write,
            -- outputs
            op           => ID_op,
            f3           => ID_f3,
            f7           => ID_f7,
            reg_data1    => ID_reg_data1,
            reg_data2    => ID_reg_data2,
            store_rs2    => ID_store_rs2,
            rs1          => rs1_addr,
            rs2          => rs2_addr,
            rd_out       => ID_rd  
        );
--------------------- ID/EX STAGE --------------------------- 
    ID_EX_STAGE_UUT : ID_EX
            port map (
                -- inputs
                clk           => clk,
                rst           => reset,
                
                ForwardA      => ForwardA, 
                ForwardB      => ForwardB,
                EX_MEM_RES    => EX_MEM_result,
                MEM_WB_RES    => MEM_WB_mem_out,
                op_in         => ID_op,
                f3_in         => ID_f3,
                f7_in         => ID_f7,
                -- register file outputs
                reg_data1_in  => ID_reg_data1,
                reg_data2_in  => ID_reg_data2,
                store_rs2_in  => ID_store_rs2,
                rd_in         => ID_rd, 
                
                op_out        => ID_EX_op,
                f3_out        => ID_EX_f3,
                f7_out        => ID_EX_f7,
                -- register file outputs
                reg_data1_out => ID_EX_reg_data1,
                reg_data2_out => ID_EX_reg_data2,
                store_rs2_out => ID_EX_store_rs2,
                rd_out        => ID_EX_rd

            ); 
       
--------------------- EX STAGE ---------------------------      
    -- Flags(3) = Z flag; Flags(2) = N flag; Flags(1) = C flag; Flags(0) = V flag
    EX_STAGE_UUT : EX_STAGE
        port map (
            -- inputs
            clk             => clk,
            rst             => reset,    
            reg_data1_in    => ID_EX_reg_data1,
            reg_data2_in    => ID_EX_reg_data2,
            op_in           => ID_EX_op,
            f3_in           => ID_EX_f3,
            f7_in           => ID_EX_f7,
            rd_in           => ID_EX_rd,
            store_rs2_in    => ID_EX_store_rs2,
            -- outputs
            result_out      => EX_result,
            Z_flag_out      => EX_Flags(3),
            V_flag_out      => EX_Flags(2),
            C_flag_out      => EX_Flags(1),
            N_flag_out      => EX_Flags(0),
            write_data_out  => EX_store_rs2,
            op_out          => EX_op,
            rd_out          => EX_rd     
        );
        
    --------------------- EX/MEM STAGE ---------------------------      
    -- Flags(3) = Z flag; Flags(2) = N flag; Flags(1) = C flag; Flags(0) = V flag
    EX_MEM_STAGE_UUT : EX_MEM_STAGE
        port map (
            -- inputs
            clk             => clk,
            rst             => reset,    
            result_in       => EX_result,
            Z_flag_in       => EX_Flags(3),
            V_flag_in       => EX_Flags(2),
            C_flag_in       => EX_Flags(1),
            N_flag_in       => EX_Flags(0),
            write_data_in   => EX_store_rs2,      
            op_in           => EX_op,
            rd_in           => EX_rd, 
            result_out      => EX_MEM_result,
            Z_flag_out      => EX_MEM_Flags(3),
            V_flag_out      => EX_MEM_Flags(2),
            C_flag_out      => EX_MEM_Flags(1),
            N_flag_out      => EX_MEM_Flags(0),
            write_data_out  => EX_MEM_store_rs2,
            op_out          => EX_MEM_op,
            rd_out          => EX_MEM_rd
        );
 --------------------- MEM STAGE ---------------------------     
    MEM_STAGE_UUT : MEM_STAGE
        port map (
            clk             => clk,
            rst             => reset,    
            alu_result    => EX_result,
            write_data    => EX_store_rs2,
            op_in         => EX_op,
            rd_in         => EX_rd,
            -- outputs
            mem_out       => MEM_mem_out,
            reg_write_out => MEM_write,
            rd_out        => MEM_rd
         );
  --------------------- MEM/WB STAGE --------------------------- 
  MEM_WB_STAGE_UUT : MEM_WB_STAGE
        port map (
            -- inputs
            clk           => clk,
            rst            => reset,  
            mem_in        => MEM_mem_out,
            reg_write_in  => MEM_write,
            rd_in         => MEM_rd,
            mem_out       => MEM_WB_mem_out,
            reg_write_out => MEM_WB_write,
            rd_out        => MEM_WB_rd
         );      
    
 --------------------- WB STAGE ---------------------------   
    WB_STAGE_UUT : WB_STAGE
        port map (
            clk           => clk,
            rst            => reset,  
            -- inputs
            data_in       => MEM_WB_mem_out,
            rd_in         => MEM_WB_rd,
            reg_write_in  => MEM_WB_write,
            -- outputs
            data_out      => WB_data,
            rd_out        => WB_rd,
            reg_write_out => WB_write       
        );
 --------------------- WB/ID STAGE ---------------------------  
     WB_ID_STAGE_UUT : WB_ID_STAGE
            port map (
                clk           => clk,
                rst            => reset,  
                -- inputs
                data_in       => WB_data,
                rd_in         => WB_rd,
                reg_write_in  => WB_write,
                -- outputs
                data_out      => WB_ID_data,
                rd_out        => WB_ID_rd,
                reg_write_out => WB_ID_write    
            ); 
            
---------------Forwading------------------
 process (EX_op, EX_MEM_op, EX_MEM_rd, MEM_WB_rd, rs1_addr, rs2_addr, ENABLE_FORWARDING, ForwardA, ForwardB)
    begin
     -- Default values
        ForwardA <= "00";
        ForwardB <= "00";
        num_stall <= "00";

        if ENABLE_FORWARDING = '1' then
            if (EX_op = "001") and (EX_MEM_rd /= "00000") then
                if EX_MEM_rd = rs1_addr then
                    ForwardA <= "10";
                end if;
                if EX_MEM_rd = rs2_addr then
                    ForwardB <= "10";
                end if;
            elsif ((EX_MEM_op = "001") or (EX_MEM_op = "010")) and (MEM_WB_rd /= "00000") then
                if MEM_WB_rd = rs1_addr then
                    ForwardA <= "01";
                end if;
                if MEM_WB_rd = rs2_addr then
                    ForwardB <= "01";
                end if;
            end if;
        else
            if (EX_MEM_op = "010") and (MEM_WB_rd /= "00000") and 
               ((MEM_WB_rd = rs1_addr) or (MEM_WB_rd = rs2_addr)) then
                num_stall <= "11";
            elsif (EX_op = "010") and (EX_MEM_rd /= "00000") and 
                  ((EX_MEM_rd = rs1_addr) or (EX_MEM_rd = rs2_addr)) then
                num_stall <= "10";
            end if;
        end if;
    end process;

    -- Output assignments
    IF_inst_out             <= IF_ID_instruction;
    IF_pc_out               <= IF_ID_pc;
    ID_EX_op_out            <= ID_EX_op;
    ID_EX_f3_out            <= ID_EX_f3;
    ID_EX_f7_out            <= ID_EX_f7;
    ID_EX_reg_data1_out     <= ID_EX_reg_data1;
    ID_EX_reg_data2_out     <= ID_EX_reg_data2;
    ID_EX_store_rs2_out     <= ID_EX_store_rs2;
    ID_EX_rd_out            <= ID_EX_rd;
    Flags_out               <= EX_MEM_Flags;
    EX_MEM_result_out       <= EX_MEM_result;
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
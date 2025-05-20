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

    
    signal rd_temp              : std_logic_vector(4 downto 0)  := (others => '0');
    -----------------------IF STAGE----------------------------
    signal IF_instruction       : std_logic_vector(31 downto 0) := (others => '0');  
    signal IF_pc                : std_logic_vector(31 downto 0) := (others => '0');
    -----------------------IF/ID STAGE----------------------------  
    signal IF_ID_instruction    : std_logic_vector(31 downto 0) := (others => '0');  
    signal IF_ID_pc             : std_logic_vector(31 downto 0) := (others => '0');   
    -----------------------ID STAGE----------------------------    
    signal ID_op                : std_logic_vector(6 downto 0)  := (others => '0');
    signal ID_f3                : std_logic_vector(2 downto 0)  := (others => '0');
    signal ID_f7                : std_logic_vector(6 downto 0)  := (others => '0');
    signal ID_rs1               : std_logic_vector(4 downto 0)  := (others => '0');
    signal ID_rs2               : std_logic_vector(4 downto 0)  := (others => '0');
    signal ID_rd                : std_logic_vector(4 downto 0)  := (others => '0');
    signal S_immediate          : std_logic_vector(11 downto 0) := (others => '0');
    signal I_immediate          : std_logic_vector(11 downto 0) := (others => '0');
    signal ID_reg_data1         : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_reg_data2         : std_logic_vector(31 downto 0) := (others => '0'); 
    signal ID_store_rs2         : std_logic_vector(31 downto 0) := (others => '0');  
    signal ID_instruction       : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_ID_instruction    : std_logic_vector(31 downto 0) := (others => '0');
    -----------------------REGISTER FILE---------------------------- 
    signal reg1_value           : std_logic_vector(31 downto 0) := (others => '0');
    signal reg2_value           : std_logic_vector(31 downto 0) := (others => '0'); 
    ----------------------ID/EX STAGE----------------------------  
    signal EX_instruction       : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_instruction    : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_op             : std_logic_vector(6 downto 0)  := (others => '0');
    signal ID_EX_f3             : std_logic_vector(2 downto 0)  := (others => '0');
    signal ID_EX_f7             : std_logic_vector(6 downto 0)  := (others => '0');
    signal ID_EX_reg_data1      : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_reg_data2      : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_store_rs2      : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_EX_rd             : std_logic_vector(4 downto 0) := (others => '0');
    ----------------------EX STAGE----------------------------

    signal EX_Flags             : std_logic_vector(3 downto 0) := (others => '0');
    signal EX_result            : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_op                : std_logic_vector(6 downto 0) := (others => '0');
    signal EX_rd                : std_logic_vector(4 downto 0) := (others => '0');
    signal EX_store_rs2         : std_logic_vector(31 downto 0) := (others => '0'); 
    ----------------------EX/MEM STAGE----------------------------
    signal EX_MEM_instruction   : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_MEM_Flags         : std_logic_vector(3 downto 0) := (others => '0');
    signal EX_MEM_result        : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_MEM_op            : std_logic_vector(6 downto 0) := (others => '0');
    signal EX_MEM_rd            : std_logic_vector(4 downto 0) := (others => '0');
    signal EX_MEM_store_rs2     : std_logic_vector(31 downto 0) := (others => '0');
    ----------------------MEM STAGE----------------------------
    signal MEM_instruction      : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_mem_out          : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_write, ALU_MEM   : std_logic := '0';
    signal MEM_rd               : std_logic_vector(4 downto 0) := (others => '0');
    signal MEM_op               : std_logic_vector(6 downto 0) := (others => '0');
    ----------------------MEM/WB STAGE----------------------------
    signal MEM_WB_instruction   : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_WB_mem_out       : std_logic_vector(31 downto 0) := (others => '0');
    signal input_memToReg       : std_logic := '0';
    signal input_ALU            : std_logic := '0';
    signal MEM_WB_MEM_write     : std_logic := '0';
    signal MEM_WB_ALU_write     : std_logic := '0';
    signal MEM_WB_rd            : std_logic_vector(4 downto 0) := (others => '0');
    signal MEM_WB_op            : std_logic_vector(6 downto 0) := (others => '0');
    signal MEM_WB_ALU           : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_WB_MEM           : std_logic_vector(31 downto 0) := (others => '0');
    ----------------------WB STAGE----------------------------
    signal WB_instruction       : std_logic_vector(31 downto 0) := (others => '0');  
    signal WB_data              : std_logic_vector(31 downto 0) := (others => '0');
    signal WB_rd                : std_logic_vector(4 downto 0) := (others => '0');
    signal WB_write             : std_logic := '0';
    
    --------------------- STALLING ---------------------
    signal IF_num_stall         : std_logic_vector(1 downto 0) := (others => '0');
    signal num_NOP              : std_logic_vector(1 downto 0) := (others => '0');
    signal IF_ID_num_stall      : std_logic_vector(1 downto 0) := (others => '0');
    signal ID_IF_num_stall      : std_logic_vector(1 downto 0) := (others => '0');
    signal ForwardA           : std_logic_vector(1 downto 0) := (others => '0');
    signal ForwardB           : std_logic_vector(1 downto 0) := (others => '0');
    
    constant NOP                : std_logic_vector(31 downto 0) := x"00000013";
    constant R_TYPE             : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMM              : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD               : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE             : std_logic_vector(6 downto 0) := "0100011";
   
begin
--------------------- IF STAGE ---------------------------  
    IF_STAGE_UUT : entity work.IF_STAGE
        port map (
            -- inputs
            clk             => clk,
            rst             => reset,    
            -- outputs   
            instr_out       => IF_instruction,
            pc_out          => IF_pc        
        );
    
    
--------------------- IF/ID STAGE ---------------------------  
    process (clk, reset)
    begin
        if reset = '1' then
            IF_ID_instruction <= (others => '0');
            IF_ID_pc          <= (others => '0');
        elsif rising_edge (clk)then
            if ENABLE_FORWARDING = '0' then
                if num_NOP = "00" then
                    IF_ID_pc          <= IF_pc;
                    IF_ID_instruction <= IF_instruction;
                    num_NOP        <= num_NOP;     
                elsif num_NOP > "00" then
                    IF_ID_pc          <= x"00000000";
                    case num_NOP is
                        when "01" =>
                            IF_ID_instruction <= NOP;
                            num_NOP        <= "00";
                        when "10" =>
                            IF_ID_instruction <= NOP;
                            num_NOP        <= "01";  
                        when "11" =>
                            IF_ID_instruction <= NOP;
                            num_NOP        <= "11"; 
                        when others => 
                            IF_ID_instruction <= (others => '0');   
                            num_NOP        <= (others => '0');      
                    end case;
                end if;
             else
                IF_ID_pc          <= IF_pc;
                IF_ID_instruction <= IF_instruction;
             end if;
        end if;  
    end process;
--------------------- ID STAGE ---------------------------            
    ID_STAGE_UUT : entity work.DECODER
        port map ( 
            FORWARDING      => ENABLE_FORWARDING,
            instr_in        => IF_ID_instruction,     
            EX_MEM_rd       => EX_MEM_rd, 
            EX_MEM_op       => EX_MEM_op, 
            MEM_WB_op       => MEM_WB_op, 
            MEM_WB_rd       => MEM_WB_rd, 
            -- outputs
            Forward_A       => ForwardA, 
            Forward_B       => ForwardB, 
            num_NOP         => num_NOP, 
            op           => ID_op,
            f3           => ID_f3,
            f7           => ID_f7,     
            rd           => ID_rd,
            rs1          => ID_rs1,
            rs2          => ID_rs2,
            S_immediate  => S_immediate,
            I_immediate  => I_immediate
        );
        
    REGISTER_UUT: entity work.RegisterFile
        port map ( clk            => clk, 
                   rst            => reset, 
                   write_enable   => WB_write, 
                   write_addr     => MEM_WB_rd, 
                   write_data     => WB_data, 
                   read_addr1     => ID_rs1, 
                   read_addr2     => ID_rs2, 
                   read_data1     => reg1_value, 
                   read_data2     => reg2_value
                   ); 
                     
    process(ForwardA, ForwardB, reg1_value, reg2_value, I_immediate, S_immediate, WB_data, EX_MEM_result)
    begin
        if ENABLE_FORWARDING = '1' then
            case ForwardA is
                when "00" => ID_reg_data1 <= reg1_value;
                when "01" => ID_reg_data1 <= WB_data;      
                when "10" => ID_reg_data1 <= EX_MEM_result; 
                when others => ID_reg_data1 <= (others => '0');
            end case;
            case ForwardB is
                when "00" =>
                    case ID_op is
                        when R_TYPE => -- R-type: use second register value
                            ID_reg_data2 <= reg2_value;
                            
                        when I_IMM | LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                            ID_reg_data2  <= std_logic_vector(resize(signed(I_immediate), 32));
                            
                        when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                            ID_reg_data2  <= std_logic_vector(resize(signed(S_immediate), 32));
                            ID_store_rs2  <= reg2_value;
                        when others => 
                            ID_reg_data2  <= (others => '0');
                    end case;
                when "01" => -- from MEM_WB stage
                    ID_reg_data2 <= WB_data;
                when "10" => -- from EX_MEM stage
                    ID_reg_data2 <= EX_MEM_result;
                when others => ID_reg_data2 <= (others => '0');
            end case;
        else
            ID_reg_data1 <= reg1_value;
            case ID_op is
                when R_TYPE => -- R-type: use second register value
                    ID_reg_data2 <= reg2_value;
                    
                when I_IMM | LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                    ID_reg_data2  <= std_logic_vector(resize(signed(I_immediate), 32));
                    
                when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                    ID_reg_data2  <= std_logic_vector(resize(signed(S_immediate), 32));
                    ID_store_rs2  <= reg2_value;
                when others => 
                    ID_reg_data2  <= (others => '0');
            end case;
        end if;   
    end process;
    
--------------------- ID/EX STAGE ---------------------------  
    process (clk, reset)
    variable rd_temp : std_logic_vector(4 downto 0);
    begin
        if reset = '1' then
            ID_EX_instruction   <= (others => '0'); 
            ID_EX_reg_data1     <= (others => '0');  
            ID_EX_reg_data2     <= (others => '0');  
            ID_EX_store_rs2        <= (others => '0');  
            ID_EX_op            <= (others => '0'); 
            ID_EX_f3            <= (others => '0'); 
            ID_EX_f7            <= (others => '0'); 
            ID_EX_rd            <= (others => '0'); 
        elsif rising_edge (clk)then 
            if ID_op = S_TYPE then
                rd_temp := (others => '0');
            else
                rd_temp := ID_rd;
            end if; 
            ID_EX_store_rs2     <= ID_store_rs2;
            ID_EX_instruction   <= IF_ID_instruction;
            ID_EX_reg_data1     <= ID_reg_data1;  
            ID_EX_reg_data2     <= ID_reg_data2;  
            ID_EX_op            <= ID_op; 
            ID_EX_f3            <= ID_f3; 
            ID_EX_f7            <= ID_f7; 
            ID_EX_rd            <= rd_temp;
        end if;  
    end process;
    
 
--------------------- EX STAGE ---------------------------  
    
    -- Flags(3) = Z flag; Flags(2) = N flag; Flags(1) = C flag; Flags(0) = V flag
    EX_STAGE_UUT : entity work.EX_STAGE
        port map (
            -- inputs
            reg_data1_in    => ID_EX_reg_data1,
            reg_data2_in    => ID_EX_reg_data2,
            op_in           => ID_EX_op,
            f3_in           => ID_EX_f3,
            f7_in           => ID_EX_f7,  
            -- outputs
            result_out      => EX_result,
            Z_flag_out      => EX_Flags(3),
            V_flag_out      => EX_Flags(2),
            C_flag_out      => EX_Flags(1),
            N_flag_out      => EX_Flags(0),
            op_out          => EX_op
        );
        

 --------------------- EX/MEM STAGE ---------------------------
    process (clk, reset)
    begin
        if reset = '1' then
            EX_MEM_instruction  <= (others => '0'); 
            EX_MEM_result       <= (others => '0'); 
            EX_MEM_op           <= (others => '0'); 
            EX_MEM_rd           <= (others => '0'); 
            EX_MEM_store_rs2    <= (others => '0'); 
        elsif rising_edge (clk)then
            EX_MEM_instruction  <= ID_EX_instruction;
            EX_MEM_store_rs2    <= ID_EX_store_rs2; 
            EX_MEM_result       <= EX_result; 
            EX_MEM_op           <= EX_op; 
            EX_MEM_rd           <= ID_EX_rd; 
            
        end if;  
    end process;
      
    MEM_STAGE_UUT : entity work.MEM_STAGE
        port map (
            -- inputs
            clk           => clk,   
            alu_result    => EX_MEM_result,
            write_data    => EX_MEM_store_rs2,
            op_in         => EX_MEM_op,
            -- outputs
            mem_out       => MEM_mem_out,
            reg_write_out => input_ALU,
            mem_reg_out   => input_memToReg
         );
  --------------------- MEM/WB STAGE ---------------------------   
  process (clk, reset)
    begin
        if reset = '1' then
            MEM_WB_instruction  <= (others => '0');
            MEM_WB_ALU          <= (others => '0');
            MEM_WB_MEM          <= (others => '0');
            MEM_WB_rd           <= (others => '0');
            MEM_WB_ALU_write    <= '0';
            MEM_WB_MEM_write    <= '0';
        elsif rising_edge (clk)then
            MEM_WB_instruction  <= EX_MEM_instruction;
            MEM_WB_ALU          <= EX_MEM_result;
            MEM_WB_MEM          <= MEM_mem_out;
            MEM_WB_rd           <= EX_MEM_rd;
            MEM_WB_ALU_write    <= input_ALU;
            MEM_WB_MEM_write    <= input_memToReg;
            
        end if;  
    end process;
    
 --------------------- WB STAGE ---------------------------   
    WB_STAGE_UUT : entity work.WB_STAGE
        port map (
            ALU_in         => MEM_WB_ALU,
            mem_in         => MEM_WB_MEM,
            reg_write_in   => MEM_WB_ALU_write,
            MemToReg_in    => MEM_WB_MEM_write,
    
            data_out       => WB_data,
            reg_write_out  => WB_write       
        );

    -- Assign output for the CPU
    IF_inst_out             <= IF_instruction;
    IF_ID_inst_out          <= IF_ID_instruction;
    IF_pc_out               <= IF_pc;
    
    ID_EX_inst_out             <= ID_EX_instruction;
    ID_EX_op_out            <= ID_EX_op;
    ID_EX_f3_out            <= ID_EX_f3;
    ID_EX_f7_out            <= ID_EX_f7;
    ID_EX_reg_data1_out     <= ID_EX_reg_data1;
    ID_EX_reg_data2_out     <= ID_EX_reg_data2;
    ID_EX_store_rs2_out     <= ID_EX_store_rs2;
    ID_EX_rd_out            <= ID_EX_rd;
    rs1                     <= ID_rs1;
    rs2                     <= ID_rs2;
    
    EX_MEM_inst_out         <= EX_MEM_instruction;
    Flags_out               <= EX_MEM_Flags;
    EX_MEM_result_out       <= EX_MEM_result;    
    EX_MEM_op_out           <= EX_MEM_op;
    EX_MEM_rd_out           <= EX_MEM_rd;
    EX_MEM_store_rs2_out    <= EX_MEM_store_rs2;
    
    MEM_WB_inst_out         <= MEM_WB_instruction;
    MEM_WB_mem_out_out      <= MEM_WB_mem_out;    
    MEM_WB_write_out        <= input_memToReg;
    MEM_WB_rd_out           <= MEM_WB_rd;
    
    WB_ID_data_out          <= WB_data;
    WB_ID_write_out         <= WB_write;
    num_stall               <= ID_IF_num_stall;
    ForwardA_out            <= ForwardA;
    ForwardB_out            <= ForwardB;

end FLOW;

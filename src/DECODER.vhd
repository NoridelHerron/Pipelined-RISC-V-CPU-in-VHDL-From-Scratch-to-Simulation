-- Noridel Herron
-- Date        : 05/03/2025
-- Description : Instruction Decode (ID) Stage for 5-Stage RISC-V Pipeline CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DECODER is
    Port (  -- inputs
            clk             : in  std_logic;
            rst             : in  std_logic;
            -- For forwading 
            Forward_ON      : in  std_logic;
            -- For stalling 
            num_stall_in    : in  std_logic_vector(1 downto 0);
            -- instruction from if stage
            instr_in        : in  std_logic_vector(31 downto 0);
            -- instruction from writeback stage
            data_in         : in  std_logic_vector(31 downto 0);
            wb_rd           : in  std_logic_vector(4 downto 0);
            wb_reg_write    : in  std_logic;
            -- From Ex_mem and Mem_wb stage, determinining factor for hazard detection
            EX_MEM_op       : in  std_logic_vector(2 downto 0);
            EX_MEM_rd       : in  std_logic_vector(4 downto 0);
            MEM_WB_write    : in  std_logic;
            MEM_WB_rd       : in  std_logic_vector(4 downto 0);
            -- for forwading, the data for register value if data hazard is detected
            EX_MEM_result   : in  std_logic_vector(31 downto 0);
            MEM_WB_mem      : in  std_logic_vector(31 downto 0);
            -- outputs
            -- for type and what kind of operation
            op              : out std_logic_vector(2 downto 0);
            f3              : out std_logic_vector(2 downto 0);
            f7              : out std_logic_vector(6 downto 0);
            -- value of the registers
            reg_data1       : out std_logic_vector(31 downto 0);
            reg_data2       : out std_logic_vector(31 downto 0);
            -- for s-type
            store_rs2       : out std_logic_vector(31 downto 0);    
            -- register destination
            rd_out          : out std_logic_vector(4 downto 0);     
            -- optional, but good for debugging
            rs1             : out std_logic_vector(4 downto 0);
            rs2             : out std_logic_vector(4 downto 0);
            -- for IF stage and for debugging 
            num_stall       : out std_logic_vector(1 downto 0);
            -- optional, but good for debugging
            ForwardA_out    : out std_logic_vector(1 downto 0);
            ForwardB_out    : out std_logic_vector(1 downto 0)
        );
end DECODER;

architecture behavior of DECODER is

    component RegisterFile
        Port (
                clk, rst         : in  std_logic;
                write_enable     : in  std_logic;
                write_addr       : in  std_logic_vector(4 downto 0);
                write_data       : in  std_logic_vector(31 downto 0);
                read_addr1       : in  std_logic_vector(4 downto 0);
                read_addr2       : in  std_logic_vector(4 downto 0);
                read_data1       : out std_logic_vector(31 downto 0);
                read_data2       : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Pipeline registers for ID/EX stage
    -- These signals hold decoded outputs from the current instruction,
    -- and act as stage registers to pass data to the EX stage on the next clock cycle.
    signal read_data1_int, read_data2_int : std_logic_vector(31 downto 0);
    signal rs1_addr, rs2_addr    : std_logic_vector(4 downto 0);
    signal op_reg                : std_logic_vector(2 downto 0);
    signal f3_reg                : std_logic_vector(2 downto 0);
    signal f7_reg                : std_logic_vector(6 downto 0);
    signal rs2S_reg              : std_logic_vector(31 downto 0);

    -- optional, but makes my code cleaner 
    constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMM  : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";

begin
    -- Instantiate the register
    regfile_inst : RegisterFile
        port map (
                    clk => clk,
                    rst => rst,
                    write_enable => wb_reg_write,
                    write_addr => wb_rd,
                    write_data => data_in,
                    read_addr1 => rs1_addr,
                    read_addr2 => rs2_addr,
                    read_data1 => read_data1_int,
                    read_data2 => read_data2_int
                  );

process(clk, rst)
    -- Needed immediately to handle decoding and hazard detection
    variable opcode_v        : std_logic_vector(6 downto 0);
    
    -- Temporary registers used to detect data hazards before storing to ID/EX
    variable stall_count     : std_logic_vector(1 downto 0);
    variable ForwardA, ForwardB : std_logic_vector(1 downto 0);
    
    -- Hold decoded register addresses early for comparison and control logic
    variable rs1_temp, rs2_temp : std_logic_vector(4 downto 0);
    variable rd_addr            : std_logic_vector(4 downto 0);
    
begin
    if rst = '1' then
    
        -- reset all the value to 0
        reg_data1 <= (others => '0');
        reg_data2 <= (others => '0');
        store_rs2 <= (others => '0');
        rd_out <= (others => '0');
        rs1 <= (others => '0');
        rs2 <= (others => '0');
        op <= (others => '0');
        f3 <= (others => '0');
        f7 <= (others => '0');
        num_stall <= (others => '0');
        ForwardA_out <= (others => '0');
        ForwardB_out <= (others => '0');
        
    -- update on the rising edge
    elsif rising_edge(clk) then
        -- decode the instruction
        opcode_v := instr_in(6 downto 0);
        f3_reg <= instr_in(14 downto 12);
        f7_reg <= instr_in(31 downto 25);
        rs1_temp := instr_in(19 downto 15);
        rs2_temp := instr_in(24 downto 20);
        rs1_addr <= rs1_temp;
        rs2_addr <= rs2_temp;

        -- default values
        ForwardA := "00";
        ForwardB := "00";
        stall_count := "00";
        rd_addr := (others => '0');
        rs2S_reg <= (others => '0');
        
        -- If a data hazard is detected, there are two primary ways to resolve it:
        -- (1) Insert NOPs (stalling the pipeline), or
        -- (2) Use forwarding to bypass and supply the needed data earlier.
        if Forward_ON = '1' then
        
            -- Forwarding logic for rs1:
            -- If rs1 depends on a value being written back by one of the two previous instructions,
            -- forward from EX/MEM (priority) or MEM/WB as needed
            if EX_MEM_op /= "011" and EX_MEM_rd /= "00000" and EX_MEM_rd = rs1_temp then
                ForwardA := "10";
            elsif MEM_WB_write = '1' and MEM_WB_rd /= "00000" and MEM_WB_rd = rs1_temp then
                ForwardA := "01";
            end if;
            
            -- Forwarding logic for rs2:
            -- If rs2 depends on a value being written back by one of the two previous instructions,
            -- forward from EX/MEM (priority) or MEM/WB as needed
            if EX_MEM_op /= "011" and EX_MEM_rd /= "00000" and EX_MEM_rd = rs2_temp then
                ForwardB := "10";
            elsif MEM_WB_write = '1' and MEM_WB_rd /= "00000" and MEM_WB_rd = rs2_temp then
                ForwardB := "01";             
            end if;
            
        else
            
            -- If forwarding is disabled, check for RAW (read-after-write) hazards.
            -- A stall is needed if either rs1 or rs2 matches the destination register
            -- of the previous (EX_MEM) or second previous (MEM_WB) instruction,
            -- and the register is not x0 (register 0).
            -- 
            -- Priority: EX_MEM hazards stall for 2 cycles ("11"), 
            --           MEM_WB hazards stall for 1 cycle ("10"), 
            --           otherwise propagate stall input.
            if EX_MEM_op /= "011" and EX_MEM_rd /= "00000" and (EX_MEM_rd = rs1_temp or EX_MEM_rd = rs2_temp) then
                stall_count := "11";
            elsif MEM_WB_write = '1' and MEM_WB_rd /= "00000" and (MEM_WB_rd = rs1_temp or MEM_WB_rd = rs2_temp) then
                stall_count := "10";
            else
                stall_count := num_stall_in;
            end if;
        end if;

        -- Select source operand for rs1 (reg_data1) based on forwarding control
        -- "00" = use value from register file
        -- "01" = forward from MEM_WB stage
        -- "10" = forward from EX_MEM stage
        -- others = default to 0 (shouldn't occur)
        case ForwardA is
            when "00" => reg_data1 <= read_data1_int;
            when "01" => reg_data1 <= MEM_WB_mem;
            when "10" => reg_data1 <= EX_MEM_result;
            when others => reg_data1 <= (others => '0'); 
        end case;

        -- Select source operand for rs2 (reg_data2) based on forwarding control
        -- Special handling for instruction types that use immediates (I-type, S-type)
        case ForwardB is
            when "00" =>
                case opcode_v is
                    when R_TYPE => -- R-type: use second register value
                        reg_data2 <= read_data2_int;
                        
                    when I_IMM | LOAD =>  -- I-type: immediate is in bits [31:20], sign-extended 
                        reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 20)), 32));
                        
                    when S_TYPE => -- S-type: immediate is split across [31:25] and [11:7], sign-extended
                        reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 25) & instr_in(11 downto 7)), 32));
                        
                    when others => 
                        reg_data2 <= (others => '0');
                end case;
            when "01" => -- from MEM_WB stage
                reg_data2 <= MEM_WB_mem;
            when "10" => -- from EX_MEM stage
                reg_data2 <= EX_MEM_result;
            when others => reg_data2 <= (others => '0');
        end case;

        -- S and B type doesn't have rd
        case opcode_v is
            when R_TYPE | I_IMM =>
                op_reg <= "001";
                rd_addr := instr_in(11 downto 7);
            when LOAD =>
                op_reg <= "010";
                rd_addr := instr_in(11 downto 7);
            when S_TYPE =>
                op_reg <= "011";
                rs2S_reg <= read_data2_int;
            when others =>
                op_reg <= (others => '0');
        end case;
        -- output assignments
        op <= op_reg;
        f3 <= f3_reg;
        f7 <= f7_reg;
        store_rs2 <= rs2S_reg;
        rd_out <= rd_addr;
        rs1 <= rs1_temp;
        rs2 <= rs2_temp;
        num_stall <= stall_count;
        ForwardA_out <= ForwardA;
        ForwardB_out <= ForwardB;
    end if;
end process;

end behavior;

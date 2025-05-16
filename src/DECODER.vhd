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
            -- Enable Forwading
            Forward_ON      : in  std_logic;
            num_stall_in    : in  std_logic_vector(1 downto 0); 
            -- input from IF 
            instr_in        : in  std_logic_vector(31 downto 0); 
            -- input from WB
            data_in         : in  std_logic_vector(31 downto 0);
            wb_rd           : in  std_logic_vector(4 downto 0);  -- Writeback destination reg
            wb_reg_write    : in  std_logic;                     -- Writeback enable signal
            
            EX_MEM_op       : in  std_logic_vector(2 downto 0); 
            EX_MEM_rd       : in  std_logic_vector(4 downto 0); 
            MEM_WB_write    : in  std_logic; 
            MEM_WB_rd       : in  std_logic_vector(4 downto 0); 
            EX_MEM_result   : in  std_logic_vector(31 downto 0); 
            MEM_WB_mem      : in  std_logic_vector(31 downto 0); 
            -- control outputs to EX -> MEM -> WB            
            op              : out std_logic_vector(2 downto 0);  -- opcode control signal
            f3              : out std_logic_vector(2 downto 0);  -- function 3
            f7              : out std_logic_vector(6 downto 0);  -- function 7 
            -- register file outputs
            reg_data1       : out std_logic_vector(31 downto 0);  -- value in register source 1
            reg_data2       : out std_logic_vector(31 downto 0);  -- value in register source 2 or immediate
            store_rs2       : out std_logic_vector(31 downto 0);  -- RS2 value for stores   
            rd_out          : out std_logic_vector(4 downto 0);
            rs1             : out std_logic_vector(4 downto 0);  
            rs2             : out std_logic_vector(4 downto 0);  
            
            -- For inserting bubble/s or stalling   
            num_stall       : out std_logic_vector(1 downto 0);
            ForwardA_out    : out std_logic_vector(1 downto 0);
            ForwardB_out    : out std_logic_vector(1 downto 0) );
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

    signal rs1_addr, rs2_addr, rd_addr      : std_logic_vector(4 downto 0);
    signal read_data1_int, read_data2_int   : std_logic_vector(31 downto 0);
    signal op_reg                           : std_logic_vector(2 downto 0);
    signal f3_reg                           : std_logic_vector(2 downto 0);
    signal f7_reg                           : std_logic_vector(6 downto 0);
    signal rs2S_reg                         : std_logic_vector(31 downto 0);
    
    constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMM  : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";

begin

    regfile_inst : RegisterFile
        port map (clk, rst, wb_reg_write, wb_rd, data_in, rs1_addr, rs2_addr, read_data1_int, read_data2_int);

    process(clk, rst)
        variable opcode_v      : std_logic_vector(6 downto 0);
        variable stall_count   : std_logic_vector(1 downto 0);
        variable ForwardA, ForwardB : std_logic_vector(1 downto 0);
        variable rs1_temp, rs2_temp : std_logic_vector(4 downto 0);
    begin
        if rst = '1' then
            reg_data1   <= (others => '0');
            reg_data2   <= (others => '0');
            store_rs2   <= (others => '0');
            rd_out      <= (others => '0');
            rs1         <= (others => '0');
            rs2         <= (others => '0');
            op          <= (others => '0');
            f3          <= (others => '0');
            f7          <= (others => '0');
            num_stall   <= (others => '0');
            ForwardA_out <= (others => '0');
            ForwardB_out <= (others => '0');
        elsif rising_edge(clk) then
            opcode_v := instr_in(6 downto 0);
            f3_reg   <= instr_in(14 downto 12);
            f7_reg   <= instr_in(31 downto 25);
            rs1_temp := instr_in(19 downto 15);
            rs2_temp := instr_in(24 downto 20);
            rs1_addr <= rs1_temp;
            rs2_addr <= rs2_temp;

            -- Forwarding Logic
            ForwardA := "00";
            ForwardB := "00";
            stall_count := "00";

            if Forward_ON = '1' then
                if MEM_WB_write = '1' and MEM_WB_rd /= "00000" and MEM_WB_rd = rs1_temp then
                    ForwardA := "01";
                elsif EX_MEM_op /= "011" and EX_MEM_rd /= "00000" and EX_MEM_rd = rs1_temp then
                    ForwardA := "10";
                end if;

                if MEM_WB_write = '1' and MEM_WB_rd /= "00000" and MEM_WB_rd = rs2_temp then
                    ForwardB := "01";
                elsif EX_MEM_op /= "011" and EX_MEM_rd /= "00000" and EX_MEM_rd = rs2_temp then
                    ForwardB := "10";
                end if;
            else
                if EX_MEM_op /= "011" and EX_MEM_rd /= "00000" and (EX_MEM_rd = rs1_temp or EX_MEM_rd = rs2_temp) then
                    stall_count := "11";
                elsif MEM_WB_write = '1' and MEM_WB_rd /= "00000" and (MEM_WB_rd = rs1_temp or MEM_WB_rd = rs2_temp) then
                    stall_count := "10";
                else
                    stall_count := num_stall_in;
                end if;
            end if;

            -- Data Selection
            case ForwardA is
                when "00" => reg_data1 <= read_data1_int;
                when "01" => reg_data1 <= MEM_WB_mem;
                when "10" => reg_data1 <= EX_MEM_result;
                when others => reg_data1 <= (others => '0');
            end case;

            case ForwardB is
                when "00" =>
                    case opcode_v is
                        when R_TYPE => reg_data2 <= read_data2_int;
                        when I_IMM | LOAD => reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 20)), 32));
                        when S_TYPE => reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 25) & instr_in(11 downto 7)), 32));
                        when others => reg_data2 <= (others => '0');
                    end case;
                when "01" => reg_data2 <= MEM_WB_mem;
                when "10" => reg_data2 <= EX_MEM_result;
                when others => reg_data2 <= (others => '0');
            end case;

            -- Control Signals
            case opcode_v is
                when R_TYPE | I_IMM =>
                    op_reg    <= "001";
                    rd_addr   <= instr_in(11 downto 7);
                    rs2S_reg  <= (others => '0');
                when LOAD =>
                    op_reg    <= "010";
                    rd_addr   <= instr_in(11 downto 7);
                    rs2S_reg  <= (others => '0');
                when S_TYPE =>
                    op_reg    <= "011";
                    rd_addr   <= (others => '0');
                    rs2S_reg  <= read_data2_int;
                when others =>
                    op_reg    <= (others => '0');
                    rd_addr   <= (others => '0');
                    rs2S_reg  <= (others => '0');
            end case;

            -- Outputs
            op            <= op_reg;
            f3            <= f3_reg;
            f7            <= f7_reg;
            store_rs2     <= rs2S_reg;
            rd_out        <= rd_addr;
            rs1           <= rs1_temp;
            rs2           <= rs2_temp;
            num_stall     <= stall_count;
            ForwardA_out  <= ForwardA;
            ForwardB_out  <= ForwardB;
        end if;
    end process;

end behavior;

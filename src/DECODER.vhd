-- Author      : Noridel Herron
-- Date        : 05/03/2025
-- Description : Instruction Decode (ID) Stage for 5-Stage RISC-V Pipeline CPU
--               - Extracts opcode, rd, rs1, rs2, funct3, funct7, immediate
--               - Generates control signals for EX, MEM, WB stages
--               - Interfaces with register file to fetch operand values
--               - Accepts writeback data/signals from WB stage
--               - Conlrol signal representing the opcode is a 3bits named op (for scalability)
--               - 1 is for R and I-type immediate, not the I-type load instruction
--               - 2 is I-type load
--               - 3 is for S-type  
-- File        : DECODER.vhd
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DECODER is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- From IF
        instr_in    : in  std_logic_vector(31 downto 0);
        
        -- From WB
        data_in     : in  std_logic_vector(31 downto 0);
        wb_rd       : in  std_logic_vector(4 downto 0);  -- Writeback destination reg
        wb_reg_write: in  std_logic;                     -- Writeback enable signal

        -- control outputs to EX, MEM, WB            
        op          : out std_logic_vector(2 downto 0);  -- opcode control signal
        f3          : out std_logic_vector(2 downto 0);  -- function 3
        f7          : out std_logic_vector(6 downto 0);  -- function 7

        -- register file outputs
        reg_data1   : out std_logic_vector(31 downto 0);  -- value in register source 1
        reg_data2   : out std_logic_vector(31 downto 0);  -- value in register source 2 or immediate

        -- passthrough 
        store_rs2   : out std_logic_vector(31 downto 0);  -- RS2 value for stores   
        rd_out      : out std_logic_vector(4 downto 0)
    );
end DECODER;

architecture behavior of DECODER is

    component RegisterFile
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            write_enable : in  std_logic;
            write_addr   : in  std_logic_vector(4 downto 0);
            write_data   : in  std_logic_vector(31 downto 0);
            read_addr1   : in  std_logic_vector(4 downto 0);
            read_addr2   : in  std_logic_vector(4 downto 0);
            read_data1   : out std_logic_vector(31 downto 0);
            read_data2   : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Internal signals
    signal rs1_addr         : std_logic_vector(4 downto 0);
    signal rs2_addr         : std_logic_vector(4 downto 0);
    signal rd_addr          : std_logic_vector(4 downto 0);
    signal read_data1_int   : std_logic_vector(31 downto 0);
    signal read_data2_int   : std_logic_vector(31 downto 0);
    signal imm              : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    -- Register file instantiation
    regfile_inst : RegisterFile port map (
        clk, rst, wb_reg_write, wb_rd, data_in,
        rs1_addr, rs2_addr, read_data1_int, read_data2_int
    );

    process(clk, rst)
        variable opcode_v : std_logic_vector(6 downto 0);
    begin
        if rst = '1' then
            reg_data1 <= (others => '0');
            reg_data2 <= (others => '0');
            op        <= "000";
            f3        <= (others => '0');
            f7        <= (others => '0');
            rd_out    <= (others => '0');
            imm       <= (others => '0');
            store_rs2 <= (others => '0');

        elsif rising_edge(clk) then
            if instr_in /= "00000000000000000000000000000000" then
                opcode_v  := instr_in(6 downto 0);
                f3        <= instr_in(14 downto 12);
                f7        <= instr_in(31 downto 25);
                rs1_addr  <= instr_in(19 downto 15);
                rs2_addr  <= instr_in(24 downto 20);
                rd_addr   <= instr_in(11 downto 7);
            else
                opcode_v := (others => '0');
                f3       <= (others => '0');
                f7       <= (others => '0');
                rs1_addr <= (others => '0');
                rs2_addr <= (others => '0');
                rd_addr  <= (others => '0');
            end if;

            -- Decode control signals & immediate
            case opcode_v is
                when "0110011" => -- R-type
                    op        <= "001";
                    imm       <= (others => '0');
                    reg_data1 <= read_data1_int;
                    reg_data2 <= read_data2_int;
                    store_rs2 <= (others => '0');
                    rd_out    <= rd_addr;

                when "0010011" => -- I-type (ALU)
                    op        <= "001";
                    imm       <= std_logic_vector(resize(signed(instr_in(31 downto 20)), 32));
                    reg_data1 <= read_data1_int;
                    reg_data2 <= imm;
                    rd_out    <= rd_addr;
                    store_rs2 <= (others => '0');

                when "0000011" => -- I-type (load)
                    op        <= "010";
                    imm       <= std_logic_vector(resize(signed(instr_in(31 downto 20)), 32));
                    reg_data1 <= read_data1_int;
                    reg_data2 <= imm;
                    rd_out    <= rd_addr;
                    store_rs2 <= (others => '0');

                when "0100011" => -- S-type (store)
                    op        <= "011";
                    imm       <= std_logic_vector(resize(signed(instr_in(31 downto 25) & instr_in(11 downto 7)), 32));
                    reg_data1 <= read_data1_int;
                    reg_data2 <= imm;
                    store_rs2 <= read_data2_int;
                    rd_out    <= (others => '0');

                when others =>
                    op        <= "000";
                    imm       <= (others => '0');
                    reg_data1 <= (others => '0');
                    reg_data2 <= (others => '0');
                    rd_out    <= (others => '0');
                    store_rs2 <= (others => '0');
            end case;
        end if;
    end process;

end behavior;

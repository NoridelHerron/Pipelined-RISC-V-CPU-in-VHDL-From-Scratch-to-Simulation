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
    Port (  -- inputs
            clk             : in  std_logic;
            rst             : in  std_logic;
            -- Enable Forwading
            Forward_ON      : in  std_logic;
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
            rd_out          : out std_logic_vector(4 downto 0);
            -- For forwading
            Forward_A       : out std_logic_vector(1 downto 0);
            Forward_B       : out std_logic_vector(1 downto 0); 
            -- For inserting bubble/s or stalling   
            num_stall       : out std_logic_vector(1 downto 0) );
end DECODER;

architecture behavior of DECODER is

    component RegisterFile
        Port (
            -- inputs
            clk          : in  std_logic;
            rst          : in  std_logic;
            write_enable : in  std_logic;
            write_addr   : in  std_logic_vector(4 downto 0);
            write_data   : in  std_logic_vector(31 downto 0);
            read_addr1   : in  std_logic_vector(4 downto 0);
            read_addr2   : in  std_logic_vector(4 downto 0);
            -- outputs
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
    signal op_reg           : std_logic_vector(2 downto 0);
    signal f3_reg           : std_logic_vector(2 downto 0);
    signal f7_reg           : std_logic_vector(6 downto 0);
    signal rs2S_reg         : std_logic_vector(31 downto 0);
    -- keep track of the opcode type
    signal MEM_OPC          : std_logic_vector(6 downto 0);
    signal EX_OPC           : std_logic_vector(6 downto 0);
    signal ID_OPC           : std_logic_vector(6 downto 0);
    -- For data hazard detection  
    signal EX_MEM_rd       : std_logic_vector(4 downto 0);
    signal MEM_WB_rd       : std_logic_vector(4 downto 0);
    -- opcode type
    constant R_TYPE         : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMM          : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD           : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE         : std_logic_vector(6 downto 0) := "0100011";

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
            op_reg    <= (others => '0');
            f3_reg    <= (others => '0');
            f7_reg    <= (others => '0');
            rs2S_reg  <= (others => '0');
            rd_addr   <= (others => '0'); 
            rs1_addr  <= (others => '0');
            rs2_addr  <= (others => '0');    

        elsif rising_edge(clk) then
            if instr_in /= "00000000000000000000000000000000" then
                opcode_v  := instr_in(6 downto 0);
                f3_reg    <= instr_in(14 downto 12);
                f7_reg    <= instr_in(31 downto 25);
                rs1_addr  <= instr_in(19 downto 15);
                rs2_addr  <= instr_in(24 downto 20);          
            else
                opcode_v := (others => '0');
                f3_reg    <= (others => '0');
                f7_reg    <= (others => '0');
                rs1_addr  <= (others => '0');
                rs2_addr  <= (others => '0');
                rd_addr   <= (others => '0');
                rs2S_reg  <= (others => '0');
            end if;
             
            -- Decode control signals & immediate
            case opcode_v is
                when R_TYPE => -- R-type
                    op        <= "001";
                    ID_OPC    <= R_TYPE;
                    reg_data1 <= read_data1_int;
                    reg_data2 <= read_data2_int;
                    rs2S_reg  <= (others => '0');
                    rd_out    <= instr_in(11 downto 7);   

                when I_IMM => -- I-type (ALU)
                    op        <= "001";
                    ID_OPC    <= I_IMM; 
                    reg_data1 <= read_data1_int;
                    reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 20)), 32));      
                    rs2S_reg <= (others => '0');
                    rd_out    <= instr_in(11 downto 7);   

                when LOAD => -- I-type (load)
                    op        <= "010";
                    ID_OPC    <= LOAD;   
                    reg_data1 <= read_data1_int;
                    reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 20)), 32));
                    rs2S_reg <= (others => '0');
                    rd_out   <= instr_in(11 downto 7);   

                when S_TYPE => -- S-type (store)
                    op        <= "011";
                    ID_OPC    <= S_TYPE;    
                    reg_data1 <= read_data1_int;               
                    reg_data2 <= std_logic_vector(resize(signed(instr_in(31 downto 25) & instr_in(11 downto 7)), 32));
                    rs2S_reg  <= read_data2_int;
                    rd_out   <= (others => '0');

                when others =>
                    f3_reg    <= (others => '0');
                    f7_reg    <= (others => '0');
                    rs1_addr  <= (others => '0');
                    rs2_addr  <= (others => '0');
                    rd_out   <= (others => '0');
                    rs2S_reg  <= (others => '0');
            end case;

            f3        <= f3_reg;
            f7        <= f7_reg;  
            store_rs2 <= rs2S_reg;
         end if;         
    end process;
    
    process (EX_OPC, MEM_OPC, EX_MEM_rd, MEM_WB_rd, rs1_addr, rs2_addr, Forward_ON)
    begin
        -- Default values
        Forward_A  <= "00";
        Forward_B  <= "00";
        num_stall  <= "00";
        if Forward_ON = '1' then
            if ((EX_OPC = R_TYPE) or (EX_OPC = I_IMM)) and EX_MEM_rd /= "00000" and (EX_MEM_rd = rs1_addr or EX_MEM_rd = rs2_addr) then
                Forward_A     <= "10";
            elsif ((MEM_OPC = I_IMM) or MEM_OPC = LOAD) and MEM_WB_rd /= "00000" and (MEM_WB_rd = rs1_addr or MEM_WB_rd = rs2_addr) then                 
                Forward_A <= "01";
        
            end if;                  
        else      
            if MEM_OPC = LOAD and MEM_WB_rd /= "00000" and ((MEM_WB_rd = rs1_addr) or (MEM_WB_rd = rs2_addr)) then  
                num_stall <= "11";
            elsif EX_OPC = LOAD and EX_MEM_rd /= "00000" and ((EX_MEM_rd = rs1_addr) or (EX_MEM_rd = rs2_addr)) then  
                num_stall <= "10";
            end if;                
        end if;
        -- For data hazard detection
        EX_OPC             <= ID_OPC;
        MEM_OPC            <= EX_OPC;
        EX_MEM_rd          <= rd_addr;
        MEM_WB_rd          <= EX_MEM_rd;
    end process;
    
end behavior;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2021 11:56:49 PM
-- Design Name: 
-- Module Name: CPU - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

-- use package
USE work.constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
    Port ( clk : in STD_LOGIC);
end CPU;

architecture Behavioral of CPU is

component instruction_memory is
    Port ( Instr_Address : in STD_LOGIC_VECTOR (instr_addr_width-1 downto 0);
           OpCode : out STD_LOGIC_VECTOR (2 downto 0);
           RS : out STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RT : out STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RD : out STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           IMM : out STD_LOGIC_VECTOR (imm_width-1 downto 0));
end component;

component register_file is
    Port ( clk : in STD_LOGIC;
           RA1 : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RA2 : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           WA : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RegWr : in STD_LOGIC;
           WD: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           RD1 : out STD_LOGIC_VECTOR (data_width-1 downto 0);
           RD2 : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end component;

component register_status_unit is
    Port ( clk : in STD_LOGIC;
           CDB_Q : in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0); --zero_rs_id when nothing is commited on the CDB
           Issued_Instr_IsIssued: STD_LOGIC;
           Issued_Instr_RegDst : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0); --zero_reg_id if no instruction issued
           Issued_Instr_RegI : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           Issued_Instr_RegJ : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           Issued_Instr_RS : in STD_LOGIC_VECTOR (rs_identifier_width-1 downto 0); --reservation station handling the currentlt issued instruction
           Issued_Instr_Qi : out STD_LOGIC_VECTOR (rs_identifier_width-1 downto 0);
           Issued_Instr_Qj : out STD_LOGIC_VECTOR (rs_identifier_width-1 downto 0);
           Commited_Instr_Update_Reg: out STD_LOGIC;
           Commited_Instr_RegDst: out STD_LOGIC_VECTOR(reg_identifier_width-1 downto 0));
end component;

component fu_type_decoder is
    Port ( OpCode : in STD_LOGIC_VECTOR (2 downto 0);
           Fu_Type : out STD_LOGIC_VECTOR (1 downto 0));
end component;

component reservation_station_fadder is
     Port (clk: in STD_LOGIC;
           Load: in STD_LOGIC;
           Op: in STD_LOGIC_VECTOR(2 downto 0);
           Qi: in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
           Qj: in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
           Vi: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           Vj: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           CDB_V: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           CDB_Q: in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
           Commit: in STD_LOGIC;
           Busy: out STD_LOGIC; --busy after load and until commit
           Result_Ready: out STD_LOGIC; --Result_Ready after result is computed, until commit
           Result_Value: out STD_LOGIC_VECTOR(data_width-1 downto 0)
           );
end component;

component reservation_station_fmultiplier is
     Port (clk: in STD_LOGIC;
           Load: in STD_LOGIC;
           Op: in STD_LOGIC_VECTOR(2 downto 0);
           Qi: in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
           Qj: in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
           Vi: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           Vj: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           CDB_V: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           CDB_Q: in STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
           Commit: in STD_LOGIC;
           Busy: out STD_LOGIC; --busy after load and until commit
           Result_Ready: out STD_LOGIC; --Result_Ready after result is computed, until commit
           Result_Value: out STD_LOGIC_VECTOR(data_width-1 downto 0)
           );
end component;

signal ProgramCounter: STD_LOGIC_VECTOR(instr_addr_width-1 downto 0) := zeros_instr_addr;

-- Instruction to be issued
signal ToIssueInstr_OpCode: STD_LOGIC_VECTOR(2 downto 0);
signal ToIssueInstr_RS, ToIssueInstr_RT, ToIssueInstr_RD, ToIssueInstr_RegDst: STD_LOGIC_VECTOR(reg_identifier_width-1 downto 0);
signal ToIssueInstr_Imm: STD_LOGIC_VECTOR(imm_width-1 downto 0);
signal ToIssueInstr_Qi, ToIssueInstr_Qj, ToIssueInstr_ReservStation: STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
signal ToIssueInstr_Vi, ToIssueInstr_Vj: STD_LOGIC_VECTOR(data_width-1 downto 0);
signal ToIssueInstr_Type: STD_LOGIC_VECTOR(1 downto 0);
signal ToIssueInstr_Issued: STD_LOGIC;

-- Instruction to be committed
signal ToCommitInstr_RegDst: STD_LOGIC_VECTOR(reg_identifier_width-1 downto 0);
signal CDB_Q: STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0);
signal CDB_V: STD_LOGIC_VECTOR(data_width-1 downto 0);
signal ToCommitInstr_RegWr: STD_LOGIC;

---- Reservation Stations' command signals
-- FADDER reservation stations
type fadder_rs_res_type is array(0 to no_fadder_reserv_stations-1) of std_logic_vector(data_width-1 downto 0);

signal Load_Fadder_Reserv_Station: STD_LOGIC_VECTOR(no_fadder_reserv_stations-1 downto 0);
signal CDB_fadder_Results: fadder_rs_res_type;
signal Commit_fadder: STD_LOGIC_VECTOR(no_fadder_reserv_stations-1 downto 0);
signal Busy_fadder: STD_LOGIC_VECTOR(no_fadder_reserv_stations-1 downto 0);
signal Result_Ready_fadder: STD_LOGIC_VECTOR(no_fadder_reserv_stations-1 downto 0);

-- FMULTIPLIER reservation stations
type fmultiplier_rs_res_type is array(0 to no_fmultiplier_reserv_stations-1) of std_logic_vector(data_width-1 downto 0);

signal Load_Fmultiplier_Reserv_Station: STD_LOGIC_VECTOR(no_fmultiplier_reserv_stations-1 downto 0);
signal CDB_Fmultiplier_Results: fmultiplier_rs_res_type;
signal Commit_Fmultiplier: STD_LOGIC_VECTOR(no_fmultiplier_reserv_stations-1 downto 0);
signal Busy_Fmultiplier: STD_LOGIC_VECTOR(no_fmultiplier_reserv_stations-1 downto 0);
signal Result_Ready_Fmultiplier: STD_LOGIC_VECTOR(no_fmultiplier_reserv_stations-1 downto 0);

begin

------------------------- ISSUE stage
FU_TYPE_DECODER_COMP: fu_type_decoder port map( 
           OpCode => ToIssueInstr_OpCode,
           Fu_Type => ToIssueInstr_Type);

FIND_FREE_RESERV_STATION_TO_ISSUE_TO: process(clk, ToIssueInstr_Type, Busy_fadder, Busy_fmultiplier)
variable found_reserv_station : boolean := False;
begin
    if falling_edge(clk) then --delayed with half a clock cycle --> remains synchronised, and it somputed by the time the next clock cycle for the reservation stations starts
        found_reserv_station := False;
        ToIssueInstr_Issued <= '0';
        
        for i in 0 to no_fadder_reserv_stations-1 loop
            Load_Fadder_Reserv_Station(I) <= '0';
        end loop;
        for i in 0 to no_fmultiplier_reserv_stations-1 loop
            Load_Fmultiplier_Reserv_Station(I) <= '0';
        end loop;
        
        if ToIssueInstr_Type="01" then
            for i in 0 to no_fmultiplier_reserv_stations-1 loop
                if not found_reserv_station and Busy_Fmultiplier(I)='0' then
                    found_reserv_station := True;
                    Load_Fmultiplier_Reserv_Station(I) <= '1';
                    ToIssueInstr_Issued <= '1';
                    ToIssueInstr_ReservStation <= std_logic_vector(to_unsigned(I+no_fadder_reserv_stations+1, rs_identifier_width));
                else
                    Load_Fmultiplier_Reserv_Station(I) <= '0';
                end if;
            end loop;
        elsif ToIssueInstr_Type="00" then 
            for i in 0 to no_fadder_reserv_stations-1 loop
                if not found_reserv_station and Busy_Fadder(I)='0' then
                    found_reserv_station := True;
                    Load_Fadder_Reserv_Station(I) <= '1';
                    ToIssueInstr_Issued <= '1';
                    ToIssueInstr_ReservStation <= std_logic_vector(to_unsigned(I+1, rs_identifier_width));
                else
                    Load_Fadder_Reserv_Station(I) <= '0';
                end if;
            end loop;
        end if;
    end if;
end process;

ToIssueInstr_RegDst <= ToIssueInstr_RD when ToIssueInstr_Type="00" or ToIssueInstr_Type="01" else ToIssueInstr_RT;

-- TODO: define ToIssueInstr_ReservStation

Update_Program_Counter: process(clk)
begin
    if rising_edge(clk)then
        if ToIssueInstr_Issued='1' then
            ProgramCounter <= ProgramCounter+1;
        end if;
    end if;
end process;
        
------------------------- ISSUE stage: handled entirely by the reservation stations

------------------------- WRITE_BACK stage

FIND_INSTRUCTION_TO_COMMIT: process(clk, Result_Ready_fadder, Result_Ready_fmultiplier)
variable found_instr_to_commit : boolean := False;
begin
    if falling_edge(clk) then --delayed with half a clock cycle
        found_instr_to_commit := False;
        Commit_Fmultiplier <= zeros_fmultiplier_reserv_stations;
        Commit_Fadder <= zeros_fadder_reserv_stations;
        CDB_Q <= zeros_rs_id;
        CDB_V <= zeros_data;
        
        -- priotitize fmultipliers
        for i in 0 to no_fmultiplier_reserv_stations-1 loop
            if not found_instr_to_commit and Result_Ready_Fmultiplier(I)='1' then
                found_instr_to_commit := True;
                CDB_Q <= std_logic_vector(to_unsigned(I+no_fadder_reserv_stations+1, rs_identifier_width));
                CDB_V <= CDB_Fmultiplier_Results(I);
                Commit_Fmultiplier(I) <= '1';
            else
                Commit_Fmultiplier(I) <= '0';
            end if;
        end loop;
        
        -- priotitize fmultipliers
        for i in 0 to no_fadder_reserv_stations-1 loop
            if not found_instr_to_commit and Result_Ready_Fadder(I)='1' then
                found_instr_to_commit := True;
                CDB_Q <= std_logic_vector(to_unsigned(I+1, rs_identifier_width));
                CDB_V <= CDB_Fadder_Results(I);
                Commit_Fadder(I) <= '1';
            else
                Commit_Fadder(I) <= '0';
            end if;
        end loop;
    end if;
end process;


------------------------- CU components
INSTRUCTIONS_ROM: instruction_memory port map( 
           Instr_Address => ProgramCounter,
           OpCode => ToIssueInstr_OpCode,
           RS => ToIssueInstr_RS,
           RT => ToIssueInstr_RT,
           RD => ToIssueInstr_RD,
           IMM => ToIssueInstr_Imm);
           
REGISTER_FILE_COMP: register_file port map (
            clk => clk,
            RA1 => ToIssueInstr_RS,
            RA2 => ToIssueInstr_RT,
            WA => ToCommitInstr_RegDst,
            RegWr => ToCommitInstr_RegWr,
            WD => CDB_V,
            RD1 => ToIssueInstr_Vi,
            RD2 => ToIssueInstr_Vj);

REGISTERS_STATUS_COMP: register_status_unit port map (
            clk => clk,
            CDB_Q => CDB_Q,
            Issued_Instr_IsIssued => ToIssueInstr_Issued,
            Issued_Instr_RegDst => ToIssueInstr_RegDst,
            Issued_Instr_RegI => ToIssueInstr_RS,
            Issued_Instr_RegJ => ToIssueInstr_RT,
            Issued_Instr_RS => ToIssueInstr_ReservStation,
            Issued_Instr_Qi => ToIssueInstr_Qi,
            Issued_Instr_Qj => ToIssueInstr_Qj,
            Commited_Instr_Update_Reg => ToCommitInstr_RegWr,
            Commited_Instr_RegDst => ToCommitInstr_RegDst
            );
            
FADDER_RESERV_STATIONS:
    for I in 0 to no_fadder_reserv_stations-1 generate
        FADDER_RESERV_STATION: reservation_station_fadder port map(
                clk => clk,
               Load => Load_Fadder_Reserv_Station(I),
               Op => ToIssueInstr_OpCode,
               Qi => ToIssueInstr_Qi,
               Qj => ToIssueInstr_Qj,
               Vi => ToIssueInstr_Vi,
               Vj => ToIssueInstr_Vj,
               CDB_V => CDB_V,
               CDB_Q => CDB_Q,
               Commit => Commit_fadder(I),
               Busy => Busy_fadder(I),
               Result_Ready => Result_Ready_fadder(I),
               Result_Value => CDB_fadder_Results(I));
end generate FADDER_RESERV_STATIONS;

FMULTIPLIER_RESERV_STATIONS:
    for I in 0 to no_fmultiplier_reserv_stations-1 generate
        FMULTIPLIER_RESERV_STATION: reservation_station_fmultiplier port map(
               clk => clk,
               Load => Load_Fmultiplier_Reserv_Station(I),
               Op => ToIssueInstr_OpCode,
               Qi => ToIssueInstr_Qi,
               Qj => ToIssueInstr_Qj,
               Vi => ToIssueInstr_Vi,
               Vj => ToIssueInstr_Vj,
               CDB_V => CDB_V,
               CDB_Q => CDB_Q,
               Commit => Commit_Fmultiplier(I),
               Busy => Busy_FMultiplier(I),
               Result_Ready => Result_Ready_FMultiplier(I),
               Result_Value => CDB_FMultiplier_Results(I));
end generate FMULTIPLIER_RESERV_STATIONS;

end Behavioral;

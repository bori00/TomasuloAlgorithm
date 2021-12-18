----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2021 09:45:57 PM
-- Design Name: 
-- Module Name: reservation_station_fmultiplier - Behavioral
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

-- use package
USE work.constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reservation_station_fmultiplier is
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
end reservation_station_fmultiplier;

architecture Behavioral of reservation_station_fmultiplier is

component fmultiplier is
    Port ( clk : in STD_LOGIC;
           op : in STD_LOGIC; --0: add, 1: subtract
           load : in STD_LOGIC;
           op1 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
           op2 : in STD_LOGIC_VECTOR (data_width-1  downto 0);
           ready : out STD_LOGIC;
           res : out STD_LOGIC_VECTOR (data_width-1  downto 0));
end component;

signal Qi_Internal, Qj_Internal: STD_LOGIC_VECTOR(rs_identifier_width-1 downto 0) := zeros_rs_id;
signal Vi_Internal, Vj_Internal: STD_LOGIC_VECTOR(data_width-1 downto 0);
signal Decoded_OP: STD_LOGIC;
signal FU_load, FU_loaded, FU_Ready: STD_LOGIC := '0';
signal Busy_Internal: STD_LOGIC :='0';

begin

Busy <= Busy_Internal;
Result_Ready <= '1' when Busy_Internal='1' and FU_loaded = '1' and FU_Ready = '1' else '0';

Load_Instruction_Or_Update_Values: process(clk) 
begin
    if rising_edge(clk) then
        if Load = '1' then 
            --Load new instruction
            Qi_Internal <= Qi;
            Qj_Internal <= Qj;
            Vi_Internal <= Vi;
            Vj_Internal <= Vj;
            FU_loaded <= '0';
            Busy_Internal <= '1';
            if Op = "010" then
                Decoded_Op <= '0'; --multiply
            else --"011"
                Decoded_Op <= '1'; -- divide
            end if;
        elsif Commit = '1' then
            --Current instruction gets committed
            Busy_Internal <= '0';
        else
            -- Update the current instruction's missing values, if they were broadcasted on the Common Data Bus.
            if Qi_Internal /= zeros_rs_id and Qi_Internal = CDB_Q then
                Qi_Internal <= zeros_rs_id;
                Vi_Internal <= CDB_V;
            end if;
            if Qj_Internal /= zeros_rs_id and Qj_Internal = CDB_Q then
                Qj_Internal <= zeros_rs_id;
                Vj_Internal <= CDB_V;
            end if;
            if FU_load = '1' then
                FU_loaded <= '1';
            end if;
        end if;
    end if;
end process;

FU_load <= '1' when Busy_Internal='1' and Qi_Internal = zeros_rs_id and Qj_Internal = zeros_rs_id and FU_loaded = '0' else '0';

FMULTIPLIER_COMP: fmultiplier port map (
        clk => clk,
        op => Decoded_Op,
        load => FU_Load,
        op1 => Vi_Internal,
        op2 => Vj_Internal,
        ready => FU_ready,
        res => Result_Value
    );


end Behavioral;
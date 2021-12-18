----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2021 09:53:59 PM
-- Design Name: 
-- Module Name: register_status_unit - Behavioral
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

entity register_status_unit is
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
           Commited_Instr_RegDst: out STD_LOGIC_VECTOR(reg_identifier_width-1 downto 0)); --zeros, unless Commited_Instr_Update_Reg='1'
end register_status_unit;

architecture Behavioral of register_status_unit is

type ram_type is array(0 to (2**reg_identifier_width) - 1) of std_logic_vector(rs_identifier_width-1 downto 0);
signal Registers_Status: ram_type := (
    others => zeros_rs_id
);

signal Committed_Instr_Update_Reg_Internal: STD_LOGIC;
signal Committed_Instr_RegDst_Internal: STD_LOGIC_VECTOR(reg_identifier_width-1 downto 0);

begin

-- synchronous writing to Registers_Status, asynchronous reading

Commit_Issue_Instr: process(clk)
begin
    if rising_edge(clk) then
        if Committed_Instr_Update_Reg_Internal='1' then
            Registers_Status(conv_integer(Committed_Instr_RegDst_Internal)) <= zeros_rs_id;
        end if;
        if Issued_Instr_IsIssued='1' and Issued_Instr_RegDst /= zeros_reg_id then
            Registers_Status(conv_integer(Issued_Instr_RegDst)) <= Issued_Instr_RS;
        end if;
    end if;
end process;

Find_Affected_RegDst: process(CDB_Q, Registers_Status)
begin
    Committed_Instr_Update_Reg_Internal <= '0';
    Committed_Instr_regDst_Internal <= zeros_reg_id;
    
    if CDB_Q /= zeros_rs_id then
        for I in 0 to  (2**reg_identifier_width) - 1 loop
            if Registers_Status(I) = CDB_Q then
                Committed_Instr_Update_Reg_Internal <= '1';
                Committed_Instr_regDst_Internal <= std_logic_vector(to_unsigned(I, reg_identifier_width));
            end if;
        end loop;
    end if;
end process;

Issued_Instr_Qi <= Registers_Status(conv_integer(Issued_Instr_RegI));
Issued_Instr_Qj <= Registers_Status(conv_integer(Issued_Instr_RegJ));

Commited_Instr_Update_Reg <= Committed_Instr_Update_Reg_Internal;
Commited_Instr_RegDst <= Committed_Instr_RegDst_Internal;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2021 11:10:59 PM
-- Design Name: 
-- Module Name:  - 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

PACKAGE constants IS
-- globals
CONSTANT rs_identifier_width : NATURAL := 3;
CONSTANT data_width: NATURAL := 16;
CONSTANT reg_identifier_width: NATURAL := 3;
CONSTANT instr_addr_width: NATURAL := 8;
CONSTANT imm_width: NATURAL := 3;
CONSTANT no_fadder_reserv_stations : NATURAL := 3;
CONSTANT no_fmultiplier_reserv_stations : NATURAL := 2;
CONSTANT zeros_rs_id : std_logic_vector(rs_identifier_width-1 downto 0) := (others => '0');
CONSTANT zeros_data: STD_LOGIC_VECTOR(data_width-1 downto 0) := (others => '0');
CONSTANT zeros_reg_id: STD_LOGIC_VECTOR(reg_identifier_width-1 downto 0) := (others => '0');
CONSTANT zeros_instr_addr: STD_LOGIC_VECTOR(instr_addr_width-1 downto 0) := (others => '0');
CONSTANT zeros_fadder_reserv_stations: STD_LOGIC_VECTOR(no_fadder_reserv_stations-1 downto 0) := (others => '0');
CONSTANT zeros_fmultiplier_reserv_stations: STD_LOGIC_VECTOR(no_fmultiplier_reserv_stations-1 downto 0) := (others => '0');
END constants; 
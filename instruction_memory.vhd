----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2021 12:24:23 AM
-- Design Name: 
-- Module Name: instruction_memory - Behavioral
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

-- use package
USE work.constants.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instruction_memory is
    Port ( Instr_Address : in STD_LOGIC_VECTOR (instr_addr_width-1 downto 0);
           OpCode : out STD_LOGIC_VECTOR (2 downto 0);
           RS : out STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RT : out STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RD : out STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           IMM : out STD_LOGIC_VECTOR (imm_width-1 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is

type rom_type is array(0 to (2**instr_addr_width)-1) of std_logic_vector(11 downto 0); 
signal rom_data: rom_type := (
    "000000001010", -- Add $2 <= $0 + $1 --> $2 <= 0 + 1 = 1
    "001111010011", -- Sub $3 <= $7 - $2 --> $3 <= 7 - 1 = 6
    "000111010111", -- Add $7 <= $7 + $2 --> $7 <= 7 + 1 = 8 --> this result is ready at the same time as the result of the previous subtraction --> it needs to wait one clock cycle for the CDB to be committed
    "010010000111", -- Mul $7 <= $2 * $0 --> $7 <= 1 * 0 = 0 --> is never written into the register file
    "001011010111", -- Sub $7 <= $3 - $2 --> $7 <= 6 - 1 = 5 --> initially no reservation station available, has to wait 1 clock cycle
    "000111011111", -- Add $7 <= $7 + $3 --> $7 <= 5 + 6 = 11
    "010010011100", -- Mul $4 <= $2 * $3 --> $4 <= 1 * 6 = 6
    "011111011101", -- Div $5 <= $7 * 2 + $3 --> $5 <= 11 * 2 + 6 = 28
    "011110011101", -- Div $5 <= $6 * 2 + $3 --> $5 <= 6 * 2 + 6 = 18
    "000001001001", -- Add $1 <= $1 + $1 --> $1 <= 1 + 1 = 2
    others => x"800"
);

signal Instr: STD_LOGIC_VECTOR(11 downto 0);

begin

Instr <= rom_data(conv_integer(Instr_address)); 

OpCode <= Instr(11 downto 9);
RS <= Instr(8 downto 6);
RT <= Instr(5 downto 3);
RD <= Instr(2 downto 0);
Imm <= Instr(2 downto 0);
end Behavioral;

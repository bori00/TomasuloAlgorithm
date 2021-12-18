----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2021 12:19:45 AM
-- Design Name: 
-- Module Name: fu_type_decoder - Behavioral
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

entity fu_type_decoder is
    Port ( OpCode : in STD_LOGIC_VECTOR (2 downto 0);
           Fu_Type : out STD_LOGIC_VECTOR (1 downto 0));
end fu_type_decoder;

architecture Behavioral of fu_type_decoder is

begin

FU_Type <= "00" when OpCode = "000" or OpCode = "001" else --fadder
           "01" when OpCode = "010" or OpCode = "011" else --fmultiplier
           "10"; --load/store unit. Not used yet.

end Behavioral;

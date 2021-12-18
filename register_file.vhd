----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2021 11:51:22 PM
-- Design Name: 
-- Module Name: register_file - Behavioral
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

entity register_file is
    Port ( clk : in STD_LOGIC;
           RA1 : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RA2 : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           WA : in STD_LOGIC_VECTOR (reg_identifier_width-1 downto 0);
           RegWr : in STD_LOGIC;
           WD: in STD_LOGIC_VECTOR(data_width-1 downto 0);
           RD1 : out STD_LOGIC_VECTOR (data_width-1 downto 0);
           RD2 : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end register_file;

architecture Behavioral of register_file is

type reg_array is array(0 to (2**reg_identifier_width) - 1) of std_logic_vector(data_width-1 downto 0);
signal reg_file: reg_array := (
        x"0000",
        x"0001",
        x"0002",
        x"0003",
        x"0004",
        x"0005",
        x"0006",
        x"0007"
);

begin
    process(clk) -- synchronous write
    begin
        if rising_edge(clk) then
            if RegWr='1' then
                reg_file(conv_integer(WA)) <= WD;
            end if;
        end if;
    end process;
    
    RD1 <= reg_file(conv_integer(RA1)); --asynchronous read
    RD2 <= reg_file(conv_integer(RA2)); --asynchronous read

end Behavioral;

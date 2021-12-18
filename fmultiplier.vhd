----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2021 10:19:32 PM
-- Design Name: 
-- Module Name: fmultiplier - Behavioral
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

entity fmultiplier is
    Port ( clk : in STD_LOGIC;
           op : in STD_LOGIC; --0: multiply, 2: divide
           load : in STD_LOGIC;
           op1 : in STD_LOGIC_VECTOR (data_width-1  downto 0);
           op2 : in STD_LOGIC_VECTOR (data_width-1  downto 0);
           ready : out STD_LOGIC;
           res : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end fmultiplier;

architecture Behavioral of fmultiplier is

signal inner_timer: STD_LOGIC_VECTOR(5 downto 0) := "000000";
signal inner_op: STD_LOGIC;
signal inner_op1, inner_op2: STD_LOGIC_VECTOR(15 downto 0);
signal inner_ready: STD_LOGIC := '0';

signal inner_product_helper: STD_LOGIC_VECTOR(2*data_width-1 downto 0);

type ram_type is array(0 to 1) of std_logic_vector(5 downto 0); 
signal op_execution_times: ram_type := (
        "001010", -- '*' takes 10 clock cycles
        "101000"  -- '/' takes 40 clock cycles
    );

begin

ready <= inner_ready;
    
load_operation: process(clk)
begin
    if clk'event and clk='1' then
        if load='1' then 
            inner_timer <= "000000";
            inner_op <= op;
            inner_op1 <= op1;
            inner_op2 <= op2;
        elsif op_execution_times(conv_integer(inner_op)) /= inner_timer then
            inner_timer <= inner_timer + "000001";
        end if;
    end if;
end process;

signal_ready: process(inner_timer, inner_op)
begin
    if op_execution_times(conv_integer(inner_op)) = inner_timer then
       inner_ready <= '1';
    else
       inner_ready <= '0';
    end if;   
end process;

inner_product_helper <= inner_op1 * inner_op2;

compute_result: process(inner_ready, inner_op, inner_op1, inner_op2, inner_product_helper)
begin
    if inner_ready='1' then
        if inner_op='0' then
            res <= inner_product_helper(data_width-1 downto 0);
        else
            res <= (inner_op1(14 downto 0) & '0') + inner_op2;
        end if;
    else
        res <= x"0000";
    end if;
end process;


end Behavioral;
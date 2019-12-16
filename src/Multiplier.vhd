----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2019 09:26:03
-- Design Name: 
-- Module Name: Multiplier - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multiplier is
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           data_a_in : in STD_LOGIC_VECTOR (9 downto 0);
           data_b_in : in STD_LOGIC_VECTOR (9 downto 0);
           data_out : out STD_LOGIC_VECTOR (19 downto 0);
           ready_out : out STD_LOGIC);
end Multiplier;

architecture Behavioral of Multiplier is

signal data_a : integer;
signal data_b : integer;

begin

data_a <= to_integer(UNSIGNED(data_a_in));
data_b <= to_integer(UNSIGNED(data_b_in));

multiplierProcess: process(clk_in, reset_in)
begin
    if reset_in = '1' then
        data_out <= (others => '0');
        ready_out <= '0';
    elsif rising_edge(clk_in) then
        ready_out <= '0';
        if enable_in = '1' then
            data_out <= std_logic_vector(to_unsigned(data_a*data_b,20));
            ready_out <= '1';
        end if;
    end if;
end process;

end Behavioral;

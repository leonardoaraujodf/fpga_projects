----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2019 09:35:36
-- Design Name: 
-- Module Name: MultGpio - Behavioral
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

entity MultGpio is
    Port ( clk_in : in STD_LOGIC;
           gpio_in : in STD_LOGIC_VECTOR (31 downto 0);
           gpio_out : out STD_LOGIC_VECTOR (31 downto 0));
end MultGpio;

architecture Behavioral of MultGpio is

component Multiplier is
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           data_a_in : in STD_LOGIC_VECTOR (9 downto 0);
           data_b_in : in STD_LOGIC_VECTOR (9 downto 0);
           data_out : out STD_LOGIC_VECTOR (19 downto 0);
           ready_out : out STD_LOGIC);
end component;

signal reset_system : STD_LOGIC;
signal enable_system : STD_LOGIC;

signal reset_mult : STD_LOGIC;
signal enable_mult : STD_LOGIC;
signal data_a_mult : STD_LOGIC_VECTOR (9 downto 0);
signal data_b_mult : STD_LOGIC_VECTOR (9 downto 0);
signal data_res_mult : STD_LOGIC_VECTOR (19 downto 0);
signal ready_mult : STD_LOGIC;

begin

data_a_mult <= gpio_in(9 downto 0);
data_b_mult <= gpio_in(19 downto 10);
reset_system <= gpio_in(20);
enable_system <= gpio_in(21);

--! Writting the data to the output
gpio_out(19 downto 0) <= data_res_mult;
gpio_out(20) <= ready_mult;
gpio_out(31 downto 21) <= (others => '0');

uut: Multiplier port map( 
           clk_in => clk_in,
           reset_in => reset_mult,
           enable_in => enable_mult,
           data_a_in => data_a_mult,
           data_b_in => data_b_mult,
           data_out => data_res_mult,
           ready_out => ready_mult 
           );

multiplierController : process(clk_in, reset_system)
variable v_last_state_enable : STD_LOGIC;
begin
    if reset_system = '1' then
        reset_mult <= '1';
        enable_mult <= '0';
        v_last_state_enable := '0';
    elsif rising_edge(clk_in) then
        enable_mult <= '0';
        if enable_system /= v_last_state_enable then
            v_last_state_enable := enable_system;
            enable_mult <= '1';
        end if;
    end if;
end process;


end Behavioral;

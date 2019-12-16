
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MultRtl is
    Port ( 
    	   -- Gpio input
           gpio_in : in STD_LOGIC_VECTOR (31 downto 0);
           -- Ports of Axi Master Bus Interface
	       m_axis_aclk : in STD_LOGIC;
    	   m_axis_aresetn : in STD_LOGIC;
    	   m_mult_axis_tvalid : out std_logic;
    	   m_mult_axis_tdata : out std_logic_vector (31 downto 0);
    	   m_mult_axis_tlast : out std_logic;
           m_mult_axis_tready : in std_logic);
end MultRtl;

architecture Behavioral of MultRtl is

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

uut: Multiplier port map( 
           clk_in => m_axis_aclk,
           reset_in => reset_mult,
           enable_in => enable_mult,
           data_a_in => data_a_mult,
           data_b_in => data_b_mult,
           data_out => data_res_mult,
           ready_out => ready_mult 
           );

multiplierController : process(m_axis_aclk, reset_system)
variable v_last_state_enable : STD_LOGIC;
begin
    if reset_system = '1' then
        reset_mult <= '1';
        enable_mult <= '0';
        v_last_state_enable := '0';
    elsif rising_edge(m_axis_aclk) then
        reset_mult <= '0';
        enable_mult <= '0';
        if enable_system /= v_last_state_enable then
            v_last_state_enable := enable_system;
            enable_mult <= '1';
        end if;
    end if;
end process;

axiStreamMult : process(m_axis_aclk, m_axis_aresetn)
variable counter : integer range 0 to 1024;
begin
	if m_axis_aresetn = '0' then	
    	   m_mult_axis_tvalid <= '0'; 
    	   m_mult_axis_tdata <= (others => '0'); 
    	   m_mult_axis_tlast <= '0';
	   counter := 0;
	elsif rising_edge(m_axis_aclk) then
		m_mult_axis_tlast <= '0';
		if ready_mult = '1' then
			m_mult_axis_tdata(31 downto 20) <= (others => '0');
			m_mult_axis_tdata(19 downto 0) <= data_res_mult;
			m_mult_axis_tvalid <= '1';
			counter := counter + 1;
			if counter = 1024 then
				counter := 0;
				m_mult_axis_tlast <= '1';
			end if;
		elsif m_mult_axis_tready = '1' then
			m_mult_axis_tvalid <= '0';
		end if;
	end if;
end process;


end Behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity Gen25 is
port( clk50: in std_logic;
		clk25: inout std_logic:='0');
end entity;

architecture bhv of Gen25 is
begin

	process (clk50)
	begin
		if rising_edge(clk50) then
			clk25 <= not clk25;
		end if;
	end process;

end architecture;
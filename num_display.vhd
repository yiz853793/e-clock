library ieee;
use ieee.std_logic_1164.all;

entity num_display is
	port(
		en: in std_logic;
		numh, numl: in std_logic_vector(3 downto 0);
		dish, disl: out std_logic_vector(3 downto 0)
	);
end num_display;

architecture num_display_bh of num_display is
begin
	dish <= numh when en = '0' else "1111";
	disl <= numl when en = '0' else "1111";
end num_display_bh;

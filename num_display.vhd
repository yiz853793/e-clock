--num_display 输出需要显示的数
library ieee;
use ieee.std_logic_1164.all;

entity num_display is
	port(
		en: in std_logic;
		--类似使能端，='0' 输出num，='1'输出空
		zero : in std_logic_vector(3 downto 0);
		numh, numl: in std_logic_vector(3 downto 0);
		--输入高四位和低四位
		dish, disl: out std_logic_vector(3 downto 0)
		--输出高四位和低四位
	);
end num_display;

architecture num_display_bh of num_display is
begin
	dish <= numh when en = '0' else zero;
	disl <= numl when en = '0' else zero;
end num_display_bh;

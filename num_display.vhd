--num_display 输出需要显示的数
library ieee;
use ieee.std_logic_1164.all;

entity num_display is
	port(
		en: in std_logic;
		--类似使能端，='0' 输出num，='1'输出空

		numh:in std_logic_vector(2 downto 0);
		numl: in std_logic_vector(3 downto 0);
		--输入高四位和低四位
		dish: out std_logic_vector(2 downto 0);
		disl: out std_logic_vector(3 downto 0)
		--输出高四位和低四位
	);
end num_display;

architecture num_display_bh of num_display is
begin
	dish <= numh when en = '0' else "111";
	disl <= numl when en = '0' else "1111";
end num_display_bh;


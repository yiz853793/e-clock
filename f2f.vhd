library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity f2f is
	port(
		clk:in std_logic; --1kHz
		f50:out std_logic --50Hz
	);
end f2f;

architecture f2f_bh of f2f is
signal cnt: integer range 0 to 19; --计数器，来实现消抖的关键，一般的按键的延时是在20ms左右
begin
	process(clk)
	begin
		if (clk'event and clk='1') then 
			cnt <= cnt + 1;
			if (cnt = 0) then 
				f50 <= '1';
			else
				f50 <= '0';
			end if;
			if (cnt = 19) then 
				cnt <= 0;
			end if;
		end if;
	end process;
end f2f_bh;

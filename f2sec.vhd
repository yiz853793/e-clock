--f2sec将10khz的方波转化成1hz空占比为0.2的方波
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity f2sec is
	port(
		clk: in std_logic;
		--10hz时钟信号
		nsec: out std_logic
		--秒
	);
end f2sec;

architecture f2sec_bh of f2sec is

signal tmp_sec : integer range 0 to 9;

begin
	process(clk)
	begin
		if(clk'event and clk = '1') then
			tmp_sec <= tmp_sec + 1;
			if(tmp_sec = 9) then
				tmp_sec <= 0;
			end if;
			if(tmp_sec < 8) then
				nsec <= '1';
			else
				nsec <= '0';
			end if;
		end if;

	end process;
end f2sec_bh;

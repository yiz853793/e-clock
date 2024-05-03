library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity f2sec is
	port(
		clk: in std_logic;
		nsec: out std_logic
	);
end f2sec;

architecture f2sec_bh of f2sec is

signal tmp_sec : integer;

begin
	process(clk)
	begin
		if(clk'event and clk = '1') then
			tmp_sec <= tmp_sec + 1;
			if(tmp_sec >= 5000) then
				tmp_sec <= 0;
			end if;
		end if;
		if(tmp_sec <= 1000) then
			nsec <= '1';
		else
			nsec <= '0';
		end if;
	end process;
end f2sec_bh;

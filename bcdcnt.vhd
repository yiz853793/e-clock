library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcdcnt is
	port(
		clk, QD: in std_logic;
		mode : in std_logic;
		bcdmod : in std_logic_vector(7 downto 0);
		hh, ll : out std_logic_vector(3 downto 0);
		carry : out std_logic
	);
end bcdcnt;

architecture bcdcnt_bh of bcdcnt is
signal tmphh, tmpll : std_logic_vector(3 downto 0) := "0000";
signal pulse: std_logic;

component xor_gate is
	port(
		a, b: in std_logic;
		c : out std_logic
	);
end component;
begin
--	compound: xor_gate port map(clk, QD and mode, pulse);
	pulse <= (clk and not mode) or (QD and mode);
	process(pulse)
	begin
		if(pulse'event and pulse = '1') then
			tmpll <= tmpll + 1;
			if(tmpll = "1010") then
				tmphh <= tmphh + 1;
			end if;
		end if;
		if(tmphh & tmpll >= bcdmod) then
			tmphh <= "0000";
			tmpll <= "0000";
			carry <= '1';
		else
			carry <= '0';
		end if;
	end process;
	hh <= tmphh;
	ll <= tmpll;
end bcdcnt_bh;

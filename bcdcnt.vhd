--bcdcnt实现对一个两位数进行控制，clk信号和QD信号均能控制
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcdcnt is
	port(
		clk: in std_logic;
		--时钟信号
		QD : in std_logic;
		--用户操作信号
		clr: in std_logic;
		--异步清零信号
		mode : in std_logic_vector(1 downto 0);
		--控制模式 mode(1) = '1' 用户控制
		bcdmod : in std_logic_vector(7 downto 0);
		--模，秒针和分针为60，时针为24
		hh, ll : out std_logic_vector(3 downto 0);
		--输出的高四位和第四位
		carry : out std_logic
		--进位信号
	);
end bcdcnt;

architecture bcdcnt_bh of bcdcnt is
signal tmphh, tmpll : std_logic_vector(3 downto 0) := "0000";
signal pulse: std_logic;

--component xor_gate is
--	port(
--		a, b: in std_logic;
		--异或门的两个信号
--		c : out std_logic
		--异或门输出
--	);
--end component;
begin
--	compound: xor_gate port map(clk, QD and mode, pulse);
	pulse <= (clk and mode(0)) or (QD and mode(1));
	process(pulse)
	begin
		if(clr = '1') then
			tmpll <= "0000";
			tmphh <= "0000";
		elsif(pulse'event and pulse = '1') then
			tmpll <= tmpll + 1;
			if(tmpll = "1001") then
				tmphh <= tmphh + 1;
				tmpll <= "0000";
			end if;
			if(tmphh & tmpll = bcdmod) then
				tmphh <= "0000";
				tmpll <= "0000";
				carry <= '1';
			else
				carry <= '0';
			end if;
		end if;
	end process;
	hh <= tmphh;
	ll <= tmpll;
end bcdcnt_bh;

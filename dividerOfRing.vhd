library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

-- 进行分频
entity dividerOfRing is
	port(
		highFre: in std_logic;	--原始时钟频率1khz
		enable: in std_logic; --使能信号
		clr: in std_logic; -- 异步清零
		N : in integer;  --分频大小
		newFre: out std_logic -- 分频后时钟频率
	);
end entity;

architecture behavioral of dividerOfRing is
signal ClkCnt : integer range 0 to 1;
signal CLK : std_logic := '0';
begin
    process(highFre, enable, clr)
    begin
		if(enable = '1') then
			if (clr = '1') then
				CLK <= '0';
				ClkCnt <= 0;
			elsif (highFre'event and highFre = '1') then
				if (ClkCnt = (N - 1)) then
					ClkCnt <= 0;
					CLK <= not CLK;
				else
					ClkCnt <= ClkCnt + 1;
				end if;
			end if;
		end if;
    end process;
	newFre <= CLK;
end behavioral;

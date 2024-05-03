library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity button is
	port(
		clk:in std_logic; --这里频率使用10kHz
		input:in std_logic;
		--开关抖动状态
		output:out std_logic
		-- 按键防抖后的判断结果
	);
end button;

architecture button_ah of button is
signal cnt:integer range 0 to 200:=0; --计数器，来实现消抖的关键，一般的按键的延时是在20ms左右
begin
	process(clk,input)
	begin
		if (clk'event and clk='1') then 
			cnt <= cnt + 1;
			if cnt = 200 then 
				output <= input;
				cnt <= 0;
			end if;
		end if;
	end process;
end button_ah;

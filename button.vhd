library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity button is
	port(
		clk:in std_logic; --这里频率使用50Hz
		input:in std_logic;
		--开关抖动状态
		output:out std_logic
		-- 按键防抖后的判断结果
	);
end button;

architecture button_ah of button is
begin
	process(clk,input)
	begin
		if (clk'event and clk='1') then 
			output <= input;
		end if;
	end process;
end button_ah;

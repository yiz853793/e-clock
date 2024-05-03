library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
  
entity bcd2light is
	port(
		input :  in std_logic_vector(3 downto 0);
		output: out std_logic_vector(6 downto 0)
	);
end bcd2light;

architecture bcd2light_bh of bcd2light is
begin
	with input select
	output <= "1111110" when "0000",
	      	"0110000" when "0001",
	      	"1101101" when "0010",
	     	"1111001" when "0011",
	     	"0110011" when "0100",
	     	"1011011" when "0101",
	     	"1011111" when "0110",
	      	"1110000" when "0111",
	      	"1111111" when "1000",
	      	"1111011" when "1001",
	      	"0000000" when others;
end bcd2light_bh;
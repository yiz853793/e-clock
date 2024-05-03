library ieee;
use ieee.std_logic_1164.all;

entity xor_gate is
	port(
		a, b: in std_logic;
		c : out std_logic
	);
end xor_gate;

architecture xor_gate_bh of xor_gate is
begin
	c <= (a and not b) or (b and not a);
end xor_gate_bh;
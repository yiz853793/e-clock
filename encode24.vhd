library ieee;
use ieee.std_logic_1164.all;

entity encode24 is
    port(
        a: in std_logic_vector(1 downto 0);
        y: out std_logic_vector(3 downto 0)
    );
end encode24;

architecture encode24_bh of encode24 is
begin
    with a select
        y <= "0001" when "00",
             "0010" when "01",
             "0100" when "10",
             "1000" when "11",
             "0000" when others;
end encode24_bh;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock is
	port(
		f5k, f1Mk, myop, show_alert: in std_logic;
		set_mode: in std_logic_vector(1 downto 0);
		alr: out std_logic;
		light_hourh, light_hourl: out std_logic_vector(3 downto 0);
		light_minh, light_minl: out std_logic_vector(3 downto 0);
		light_sech: out std_logic_vector(3 downto 0);
		light_seclbcd: out std_logic_vector(6 downto 0)
	);
end clock;

architecture clock_bh of clock is

constant sixty : std_logic_vector(7 downto 0) := "01100000";
constant tw_fo : std_logic_vector(7 downto 0) := "00100100";
signal mode : std_logic_vector(3 downto 0);
signal t_hourh, t_hourl, t_minh, t_minl, t_sech, t_secl, light_secl : std_logic_vector(3 downto 0);
signal s2m, m2h : std_logic;
signal sec: std_logic;
signal isspark: std_logic;
signal scarry, mcarry: std_logic;
signal null_and_void : std_logic_vector(9 downto 0);

component f2sec is
	port(
		clk: in std_logic;
		nsec: out std_logic
	);
end component;

component encode24 is
    port(
        a: in std_logic_vector(1 downto 0);
        y: out std_logic_vector(3 downto 0)
    );
end component;

component bcd2light is
	port(
		input :  in std_logic_vector(3 downto 0);
		output: out std_logic_vector(6 downto 0)
	);
end component;

component num_display is
	port(
		en: in std_logic;
		numh, numl: in std_logic_vector(3 downto 0);
		dish, disl: out std_logic_vector(3 downto 0)
	);
end component;

component bcdcnt is
	port(
		clk, QD: in std_logic;
		mode : in std_logic;
		bcdmod : in std_logic_vector(7 downto 0);
		hh, ll : out std_logic_vector(3 downto 0);
		carry : out std_logic
	);
end component;

begin
	nsec: f2sec port map (f5k, sec);
	
	decide_mode: encode24 port map(set_mode, mode);
	
	secl2light: 
		bcd2light port map(light_secl, light_seclbcd);
	
	--tmp <= time when ... else alert;
	
	sec_display: num_display port map(not sec and mode(1), t_sech, t_secl, light_sech, light_secl);
	min_display: num_display port map(not sec and mode(2), t_minh, t_minl, light_minh, light_minl);
	hour_display: num_display port map(not sec and mode(3), t_hourh, t_hourl, light_hourh, light_hourl);
	
	sec_incr: bcdcnt port map(sec, myop, mode(1), sixty, t_sech, t_secl, scarry);
	min_incr: bcdcnt port map(scarry, myop, mode(2), sixty, t_minh, t_minl, mcarry);
	hour_incr: bcdcnt port map(mcarry, myop, mode(3), tw_fo, t_hourh, t_hourl, null_and_void(9));

	isspark <= mcarry;
end clock_bh;


--顶层设计
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock is
	port(
		f10k : in std_logic;
		--时钟信号 10khz
      		 --CP1 56 IN 100KHz或10KHz

		f1Mk : in std_logic;
		--主时钟
		--MF 55 1Mhz

		myop : in std_logic;
		--调节控制信号，上升沿触发
		--QD 60

		show_alert: in std_logic;
		--显示闹钟界面
		--swa 4

		set_mode: in std_logic_vector(1 downto 0);
		--设置模式
		--"00" 正常 "01"设置秒针 "10"设置分针 "11"设置时针
		--swb 5 swb 6

		alr: out std_logic;
		--蜂鸣器信号
		--sparker 52

		light_hourh, light_hourl: out std_logic_vector(3 downto 0);
		--时针显示
		--LG6 24 22 21 20  LG5 29 28 27 25

		light_minh, light_minl: out std_logic_vector(3 downto 0);
		--分针显示
		--LG4 34 33 31 30  LG3 18 17 36 35

		light_sech: out std_logic_vector(3 downto 0);
		--秒针高四位
		--LG2 41 40 39 37

		light_seclbcd: out std_logic_vector(6 downto 0)
		--秒针低四位
		--LG1 51 50 49 48 46 45 44
	);
end clock;


architecture clock_bh of clock is

constant sixty : std_logic_vector(7 downto 0) := "01011001";   -- 59
constant tw_fo : std_logic_vector(7 downto 0) := "00100011"; -- 23

signal sec: std_logic;
--1hz时钟信号

signal mode : std_logic_vector(3 downto 0);
--译码后的模式选择信号

signal light_secl : std_logic_vector(3 downto 0);
--秒钟低四位

signal t_hourh, t_hourl, t_minh, t_minl, t_sech, t_secl : std_logic_vector(3 downto 0);
--时间的信息

signal a_hourh, a_hourl, a_minh, a_minl, a_sech, a_secl : std_logic_vector(3 downto 0);
--闹钟信息

signal scarry : std_logic;
--秒到分的进位

signal mcarry : std_logic;
--分到时的进位

signal isspark: std_logic;
--整点和闹钟报时信号

signal null_and_void : std_logic_vector(9 downto 0);
--多余信号

--分频模块
component f2sec is
	port(
		clk: in std_logic;
		--10khz时钟信号
		nsec: out std_logic
		--秒
	);
end component;

--2-4译码器
component encode24 is
    port(
        a: in std_logic_vector(1 downto 0);
        y: out std_logic_vector(3 downto 0)
    );
end component;

--七段显示译码模块
component bcd2light is
	port(
		input :  in std_logic_vector(3 downto 0);
		output: out std_logic_vector(6 downto 0)
	);
end component;

--数据显示模块
component num_display is
	port(
		en: in std_logic;
		--类似使能端，='0' 输出num，='1'输出空
		numh, numl: in std_logic_vector(3 downto 0);
		--输入高四位和低四位
		dish, disl: out std_logic_vector(3 downto 0)
		--输出高四位和低四位
	);
end component;

--计数器模块
component bcdcnt is
	port(
		clk: in std_logic;
		--时钟信号
		QD : in std_logic;
		--用户操作信号
		mode : in std_logic_vector(1 downto 0);
		--控制模式 mode(1) = '1' 用户控制
		bcdmod : in std_logic_vector(7 downto 0);
		--模，秒针和分针为60，时针为24
		hh, ll : out std_logic_vector(3 downto 0);
		--输出的高四位和第四位
		carry : out std_logic
		--进位信号
	);
end component;


begin
	nsec: f2sec port map (f10k, sec);
	--分频模块
	--将10khz的方波转化成1hz空占比为0.8的方波
	
	decide_mode: encode24 port map(set_mode, mode);
	--2-4译码器
	--用于对mode译码产生四个控制信号	

	secl2light:  bcd2light port map(light_secl, light_seclbcd);
	--七段显示译码模块，用于将秒钟个位译码为七段译码

	--显示模块
	sec_display: num_display port map(not sec and mode(1), t_sech, t_secl, light_sech, light_secl);
	--显示秒针，mode(1) = '1'时调整秒针，秒针闪烁
	
	min_display: num_display port map(not sec and mode(2), t_minh, t_minl, light_minh, light_minl);
	--显示分针，mode(2) = '1'时调整分针，分针闪烁

	hour_display: num_display port map(not sec and mode(3), t_hourh, t_hourl, light_hourh, light_hourl);
	--显示时针，mode(3) = '1'时调整时针，时针闪烁

	--计时模块
	sec_incr: bcdcnt port map(sec, myop, mode(1) & mode(0), sixty, t_sech, t_secl, scarry);
	--秒针计时
	--mode(1) = '1'QD调整，mode(0) = '1'sec调整

	min_incr: bcdcnt port map(scarry, myop, mode(2)&mode(0), sixty, t_minh, t_minl, mcarry);
	--分针计时
	--mode(2) = '1'QD调整，mode(0) = '1'sec调整

	hour_incr: bcdcnt port map(mcarry, myop, mode(3)&mode(0), tw_fo, t_hourh, t_hourl, null_and_void(9));
	--时针计时
	--mode(3) = '1'QD调整，mode(0) = '1'sec调整

	isspark <= mcarry;
	--蜂蜜器信号

end clock_bh;


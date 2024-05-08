--顶层设计
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock is
	port(
		f1k : in std_logic;
		--时钟信号 1khz
      		 --CP2 57 IN 1KHz或100Hz
		
		f10: in std_logic;
		
		amyop : in std_logic;
		--调节控制信号，上升沿触发
		--QD 60
		
		aclr : in std_logic;
		--异步清零信号
		--K15 63
		
		en_clock: in std_logic;
		--
		--K14 64
		
		ashow_alert: in std_logic;
		--显示闹钟界面
		--swa 4

		aset_mode: in std_logic_vector(1 downto 0);
		--设置模式
		--"00" 正常 "01"设置秒针 "10"设置分针 "11"设置时针
		--swb 5 swc 6

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
constant zero : std_logic_vector(3 downto 0) := "0000"; --0
constant azero: std_logic_vector(3 downto 0) := "1111";
constant low_divider: integer := 2;  -- 4分频

signal myop, clr, show_alert : std_logic;
signal set_mode: std_logic_vector(1 downto 0);
--防抖动

signal f50 : std_logic;
--50Hz

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

signal tmp_hourh, tmp_hourl, tmp_minh, tmp_minl, tmp_sech, tmp_secl : std_logic_vector(3 downto 0);
--存储器信息

signal scarry : std_logic;
--秒到分的进位

signal mcarry, true_mcarry : std_logic;
--分到时的进位

signal isspark: std_logic;
--整点和闹钟报时信号

signal null_and_void : std_logic;
--多余信号

signal enlow, enhigh : std_logic;
-- 低音和高音信号

signal alr1, alr2: std_logic;
--蜂鸣器暂存

--防抖动模块
component button is
	port(
		clk:in std_logic; --这里频率使用10kHz
		input:in std_logic;
		--开关抖动状态
		output:out std_logic
		-- 按键防抖后的判断结果
	);
end component;

--分频模块
component f2sec is
	port(
		clk: in std_logic;
		--10khz时钟信号
		nsec: out std_logic
		--秒
	);
end component;

component f2f is
	port(
		clk:in std_logic; --10kHz
		f50:out std_logic --50Hz
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
		zero : in std_logic_vector(3 downto 0);
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
		clr: in std_logic;
		--异步清零信号
		mode : in std_logic_vector(1 downto 0);
		--控制模式 mode(1) = '1' 用户控制
		bcdmod : in std_logic_vector(7 downto 0);
		--模，秒针和分针为60，时针为24
		zero : in std_logic_vector(3 downto 0);
		hh, ll : inout std_logic_vector(3 downto 0);
		--输出的高四位和第四位
		carry : out std_logic
		--进位信号
	);
end component;

component ring is 
	    port(
        enable: in std_logic; 
		  -- 响铃使能
        clk: in std_logic;
        --1Hz时钟信号
        enlow: out std_logic;
        --低音C使能信号，高电平有效
        enhigh: out std_logic
        --高音C使能信号，高电平有效
    );
end component;

component dividerOfRing is 
	port(
		highFre: in std_logic;	--原始时钟频率
		enable: in std_logic; --使能信号
		clr: in std_logic; -- 异步清零
		N : in integer;  --分频大小
		newFre: inout std_logic -- 分频后时钟频率
	);
end component;

begin
	f10k_to_50: f2f port map(f1k, f50);
	--防抖动模块
	QD_db: button port map(f50, amyop, myop);
	--QD防抖动
	
	clr_db:button port map(f50, aclr, clr);
	--clr防抖动
	
	sa_db: button port map(f50, ashow_alert, show_alert);
	--show_alert防抖动
	
	st_db1:button port map(f50, aset_mode(1), set_mode(1));
	--mode(1)防抖动
	
	st_db2:button port map(f50, aset_mode(0), set_mode(0)); 
	--mode(0)防抖动
	
	nsec: f2sec port map (f10, sec);
	--分频模块
	--将10khz的方波转化成1hz空占比为0.8的方波
	
	decide_mode: encode24 port map(set_mode, mode);
	--2-4译码器
	--用于对mode译码产生四个控制信号	

	secl2light:  bcd2light port map(light_secl, light_seclbcd);
	--七段显示译码模块，用于将秒钟个位译码为七段译码

	--存储器写入
	--show_alert = '1'时存入闹钟信息，否则存入时钟信息
	with show_alert select
	tmp_hourh <= a_hourh when '1',
				t_hourh when others;
	--存入时针高四位

	with show_alert select
	tmp_hourl <= a_hourl when '1',
				t_hourl when others;
	--存入时针低四位

	with show_alert select
	tmp_minh <= a_minh when '1',
				t_minh when others;
	--存入分针高四位

	with show_alert select
	tmp_minl <= a_minl when '1',
				t_minl when others;
	--存入分针低四位

	with show_alert select
	tmp_sech <= a_sech when '1',
				t_sech when others;
	--存入秒针高四位

	with show_alert select
	tmp_secl <= a_secl when '1',
				t_secl when others;
	--存入秒针低四位
		

	--显示模块
	sec_display: num_display port map(not sec and mode(1), azero, tmp_sech, tmp_secl, light_sech, light_secl);
	--显示秒针，mode(1) = '1'时调整秒针，秒针闪烁
	
	min_display: num_display port map(not sec and mode(2), azero, tmp_minh, tmp_minl, light_minh, light_minl);
	--显示分针，mode(2) = '1'时调整分针，分针闪烁

	hour_display: num_display port map(not sec and mode(3), azero, tmp_hourh, tmp_hourl, light_hourh, light_hourl);
	--显示时针，mode(3) = '1'时调整时针，时针闪烁

	--时钟计时模块 show_alert = '0' 有效
	sec_incr: 
		bcdcnt port map(sec, myop, clr, (mode(1) and not show_alert) & (mode(0) or show_alert), sixty, zero, t_sech, t_secl, scarry);
	--秒针计时
	--mode(1) = '1'QD调整，mode(0) = '1'sec调整

	min_incr: 
		bcdcnt port map(scarry, myop, clr, (mode(2) and not show_alert) & (mode(0) or show_alert), sixty, zero, t_minh, t_minl, mcarry);
	--分针计时
	--mode(2) = '1'QD调整，mode(0) = '1'sec调整
	
	true_mcarry <= mcarry when t_sech = zero and t_sech = zero and t_minh = zero and t_minl = zero else
		'0';
	hour_incr: 
		bcdcnt port map(true_mcarry, myop, clr, (mode(3) and not show_alert) & (mode(0) or show_alert), tw_fo, zero, t_hourh, t_hourl, null_and_void);
	--时针计时
	--mode(3) = '1'QD调整，mode(0) = '1'sec调整
	
	--闹钟设置模块
	asec_incr: 
		bcdcnt port map('0', myop, '0', (mode(1) and show_alert) & '0', sixty, zero, a_sech, a_secl, null_and_void);
	--mode(1) = '1', show_alert = '1'，QD调整秒针

	amin_incr: 
		bcdcnt port map('0', myop, '0', (mode(2) and show_alert) & '0', sixty, zero, a_minh, a_minl, null_and_void);
	--mode(2) = '1', show_alert = '1'，QD调整分针

	ahour_incr: bcdcnt port map('0', myop, '0', (mode(3) and show_alert) & '0', tw_fo, zero, a_hourh, a_hourl, null_and_void);
	--mode(3) = '1', show_alert = '1'，QD调整时针

	isspark <= '1' when (true_mcarry = '1' and scarry = '1' and en_clock = '1') else
		'0';
	--蜂鸣器信号  or 
	
	ring_alert: ring port map(isspark, sec, enlow, enhigh);
	-- 响铃模块 (en_clock = '1' and mode(0) = '1' and t_hourh = a_hourh and t_hourl = a_hourl and t_minh = a_minh
	-- and t_minl = a_minl and t_sech = a_sech and t_secl = a_secl)
	
	low_frec : dividerOfRing port map(f1k, enlow, clr, low_divider, alr1);
	--低音
	
	high_frec : dividerOfRing port map(f1k, enhigh, clr, (low_divider / 2), alr2);
	--高音
	
	alr <= alr1 or alr2;
end clock_bh;


library ieee;
use ieee.std_logic_1164.all;
entity CCUVHD is
end CCUVHD;
---
architecture behav of CCUVHD is
component RS232coincidencecounter
PORT
	(
-- The transmitter to the RS-232 port where the data is sent out to LabView
		UART_TXD	:OUT	STD_LOGIC;
-- The 50 MHz clock that is provided on the DE2 Board
		Clock_50	:IN		STD_LOGIC;
-- The switchs 0 through 17 on the DE2 Board	
		SW			:IN		STD_LOGIC_VECTOR(17 DOWNTO 0);
-- The 40 pin expansion header GPIO_0 pins, which can be used as input or output signals
-- (note that the pins on the expansion header do not match the pin assignments used by
--  Quartus II when programming the DE2 Board)		
		GPIO_0		:IN		STD_LOGIC_VECTOR(6 DOWNTO 0);
-- The 40 pin expansion header GPIO_0 pins, which can be used as input or output signals
-- (note that the pins on the expansion header do not match the pin assignments used by
--  Quartus II when programming the DE2 Board)		
		GPIO_1		:OUT	STD_LOGIC_VECTOR(35 DOWNTO 7);
-- The red LED lights 0 through 17 on the DE2 Board
		LEDR		:OUT	STD_LOGIC_VECTOR(17 DOWNTO 0)
	);
end component;



--------
signal ain :std_logic :='0';
signal bin :std_logic :='0';
signal cin :std_logic :='1';
signal din :std_logic :='1';

signal cout :std_logic;
begin
----instantiate
U1 :RS232coincidencecounter port map(GPIO_0(0) => ain,GPIO_0(2) => bin, SW(17) => cin, SW(16) => din, GPIO_1(27) => cout);
-----ain stimulus
Process
begin
ain<='0';
wait for 20 ns;
ain<='1';
wait for 20 ns;
end process;
-----bin stimulus
process
begin
bin<='0';
wait for 40 ns;
bin<='1';
wait for 20 ns;
end process;
----
end behav;
-- Coincidence Counter Circuit Using Asynchronous Delay
-- Finished April 7th 2008, Whitman College
-- Designed by Mark Beck, beckmk@whitman.edu and Jesse Lord, lordjw@whitman.edu
--	Modified for DE2-115/ Delay Chain Optimization by William Morong, wmorong@berkeley.edu
-------------------------------------------------------------------------------
-- This circuit takes input signals from four photon detectors
-- and shortens each pulse to decrease unintended overlap of signals;
-- thus decreasing the number of false coincidence detections.
-- In this design file, the input pulses are obtained using the GPIO
-- The shortened single photon detection signal and coincidence photon
-- detections are output on the RS232 port using signal UART_TXD

-- top level entity
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RS232coincidencecounter IS
	PORT
	(
-- The transmitter to the RS-232 port where the data is sent out to LabView
		UART_TXD	:OUT	STD_LOGIC;
-- The 50 MHz clock that is provided on the DE2 Board
		Clock_50	:IN		STD_LOGIC;
-- The switchs 0 through 17 on the DE2 Board	
		SW			:IN		STD_LOGIC_VECTOR(17 DOWNTO 0);
-- The input pins on 40 pin expansion header GPIO pins
-- (which can be used for input or output signals).
-- Note that the pins on the expansion header do not match the pin assignments used by
--  Quartus II when programming the DE2-115 Board		
		GPIO_29, GPIO_3, GPIO_33, GPIO_7		:IN		STD_LOGIC ;
-- The output test signal pins on the 14 pin general purpose header
-- (which can be used for input or output signals).
-- Note that the pins on the expansion header do not match the pin assignments used by
--  Quartus II when programming the DE2 Board		
		EX_IO		:OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
-- The red LED lights 0 through 17 on the DE2-115 Board
		LEDR		:OUT	STD_LOGIC_VECTOR(17 DOWNTO 0)
	);
END RS232coincidencecounter;

ARCHITECTURE Behavior OF RS232coincidencecounter IS
-- This component chooses one of the three delayed pulses, inverts the chosen pulse,
-- then ANDs the inverted, delayed pulse with the original (effectively shortening the original)
	COMPONENT mux4to1
		PORT
		(
			delayedpulse_0	:IN		STD_LOGIC;
			delayedpulse_1	:IN		STD_LOGIC;	
			delayedpulse_2	:IN		STD_LOGIC;		
			pulse			:IN		STD_LOGIC;
			SW				:IN		STD_LOGIC_VECTOR(1 DOWNTO 0);
			pulseout		:OUT	STD_LOGIC
		);
	END COMPONENT;
-- This COMPONENT outputs one pulse for each coincidence by using a four input AND gate to combine the photon detector signals
	COMPONENT coincidence_pulse
		PORT
		(
			a, b, c, d, e, f, g, h	:IN	 STD_LOGIC;
			y						:OUT STD_LOGIC
		);
	END COMPONENT;	
-- This COMPONENT is the Megafunction "lpm_counter" using a 14 bit output and an asynchronous clear
	COMPONENT data_trigger_counter
		PORT
		(
			aclr	: IN 	STD_LOGIC;
			clock	: IN 	STD_LOGIC;
			q		: OUT 	STD_LOGIC_VECTOR (14 DOWNTO 0)
		);
	END COMPONENT;	
-- This COMPONENT is the Megafunction "lpm_counter" using a 13 bit output and an asynchronous clear
	COMPONENT baud_counter
		PORT
		(
			aclr	: IN 	STD_LOGIC;
			clock	: IN 	STD_LOGIC;
			q		: OUT 	STD_LOGIC_VECTOR (12 DOWNTO 0)
		);
	END COMPONENT;	
-- This COMPONENT is the Megafunction "lpm_counter" using a 32 bit output and an asynchronous clear
	COMPONENT counter
		PORT
		(
			aclr	: IN	STD_LOGIC;
			clock	: IN	STD_LOGIC;
			q		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;
-- This COMPONENT takes in the single photon and coincidence photon counts and sends it out
-- on the RS232 port, the data stream is started by data_trigger every 1/10th of a second
-- and the rate of the data_stream is controled by the 19200 bits/sec baud clock
	COMPONENT DataOut
		PORT
		(
			A				:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			B				:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			C				:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			D				:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			Coincidence_0	:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			Coincidence_1	:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			Coincidence_2	:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			Coincidence_3	:IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk				:IN		STD_LOGIC;
			data_trigger	:IN		STD_LOGIC;
			UART_TXD		:OUT	STD_LOGIC
		);
	END COMPONENT;

	COMPONENT LCELL
		PORT (
		a_in : IN STD_LOGIC;
		a_out : OUT STD_LOGIC);
	END COMPONENT;
	
-- This SIGNAL counts the baud clock until it reaches 1920, which occurs every 1/10th of a second
	SIGNAL data_trigger_count: STD_LOGIC_VECTOR(14 DOWNTO 0);
-- This SIGNAL is turned on every 1/10th of a second for one 50 MHz clock pulse and resets
-- the photon detection counters
	SIGNAL data_trigger_reset: STD_LOGIC;
-- This SIGNAL is turned on every 1/10th of a second and begins the data stream out
	SIGNAL data_trigger: STD_LOGIC;
-- This SIGNAL acts as a clock to output data at the baud rate of 19200 bits/second
	SIGNAL baud_rate_clk: STD_LOGIC;
-- This SIGNAL counts the 50 MHz clock pulses until it reaches 2604 in order to time the baud clock
	SIGNAL baud_rate_count: STD_LOGIC_VECTOR(12 DOWNTO 0);
-- These SIGNALs represent the four input pulse from the photon detectors		
	SIGNAL A, B, C, D: STD_LOGIC;
-- These SIGNALs represent the three shortened versions of the pulse, one of which
-- (along with the original signal) will be chosen by the 4-to-1 mux
	SIGNAL A_internal, B_internal, C_internal, D_internal : STD_LOGIC_VECTOR (27 downto 0);
--The SYN_KEEP attribute preserves the signals through the compiler,
--so that they are not automatically optimized away as redundant logic	
	ATTRIBUTE SYN_KEEP : BOOLEAN;
	ATTRIBUTE SYN_KEEP of A_internal: SIGNAL is TRUE;
	ATTRIBUTE SYN_KEEP of B_internal: SIGNAL is TRUE;
	ATTRIBUTE SYN_KEEP of C_internal: SIGNAL is TRUE;
	ATTRIBUTE SYN_KEEP of D_internal: SIGNAL is TRUE;
-- These SIGNALs represent the shortened pulses output by the mux4to1 COMPONENT		
	SIGNAL A_s, B_s, C_s, D_s: STD_LOGIC;
-- These SIGNALs represent the four output pulses	
	SIGNAL A_f, B_f, C_f, D_f: STD_LOGIC;
-- This SIGNAL represents the output of the four input AND gate that detects each coincidence
	SIGNAL Coincidence_0, Coincidence_1, Coincidence_2, Coincidence_3: STD_LOGIC;
-- This SIGNAL represents the top level design entity instantiation of
-- the number of coincidences counted
	SIGNAL Count_top_0, Count_top_1, Count_top_2, Count_top_3: STD_LOGIC_VECTOR(31 DOWNTO 0);
-- This SIGNAL represents the the number of coincidences counted
	SIGNAL Count_out_0, Count_out_1, Count_out_2, Count_out_3: STD_LOGIC_VECTOR(31 DOWNTO 0);
-- This SIGNAL represents the top level design entity instantiation of the number of counts
-- in the detectors A, B, C, and D respectively
	SIGNAL A_top, B_top, C_top, D_top: STD_LOGIC_VECTOR(31 DOWNTO 0);
-- This SIGNAL represents the number of counts in the detectors A, B, C, and D respectively
	SIGNAL A_out, B_out, C_out, D_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
-- This SIGNAL is the only variable that is sent to the computer from the program	
	SIGNAL Output: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
-- This initializes the input SPCMs signals
-- Note that for this current circuit design A -> A, B -> B, A` -> C, and B` -> D
	A <= GPIO_29;
	B <= GPIO_3;
	C <= GPIO_33;
	D <= GPIO_7;
	
-- This creates, using iteration, a chain of LCELL buffers for each A, B, C, D signal,
-- which act to delay the signals.
	LCA_1: LCELL PORT MAP(a_in=> A, a_out=>A_internal(0));

	Gen_delay_A : FOR i in 0 to 24 GENERATE
	LC : LCELL PORT MAP(a_in => A_internal(i),a_out => A_internal(i+1));
	END GENERATE;

	LCB_1: LCELL PORT MAP(a_in=> B, a_out=>B_internal(0));

	Gen_delay_B : FOR i in 0 to 23 GENERATE
	LC : LCELL PORT MAP(a_in => B_internal(i),a_out => B_internal(i+1));
	END GENERATE;
	
	LCC_1: LCELL PORT MAP(a_in=> C, a_out => C_internal(0));

	Gen_delay_C : FOR i in 0 to 23 GENERATE
	LC : LCELL PORT MAP(a_in => C_internal(i),a_out => C_internal(i+1));
	END GENERATE;
	
	LCD_1: LCELL PORT MAP(a_in=> D, a_out => D_internal(0));

	Gen_delay_D : FOR i in 0 to 23 GENERATE
	LC : LCELL PORT MAP(a_in => D_internal(i),a_out => D_internal(i+1));
	END GENERATE;
	
	--Mapping several points from the delay chain into the MUXes to determine signal shortening.
	MA: mux4to1 PORT MAP( A_internal(8), A_internal(16), A_internal(24), A, SW(17 DOWNTO 16), A_s );
	MB: mux4to1 PORT MAP( B_internal(8), B_internal(16), B_internal(24), B, SW(17 DOWNTO 16), B_s );
	MC: mux4to1 PORT MAP( C_internal(8), C_internal(16), C_internal(24), C, SW(17 DOWNTO 16), C_s );
	MD: mux4to1 PORT MAP( D_internal(8), D_internal(16), D_internal(24), D, SW(17 DOWNTO 16), D_s );
	
-- This COMPONENT tests for overlap of the four input signals using a four input AND gate
-- Each switch (represented by SW) can by turned off to ignore one particular signal
-- This allows four different coincidence counters to be output to the computer
-- The switches are mapped A_s:SW(0,4,8,12), B_s:SW(1,5,9,13), C_s:SW(2,6,10,14), D_s:SW(3,7,11,15)
	CP0: coincidence_pulse PORT MAP( A_s, B_s, C_s, D_s, SW(0), SW(1), SW(2), SW(3), Coincidence_0 );
	CP1: coincidence_pulse PORT MAP( A_s, B_s, C_s, D_s, SW(4), SW(5), SW(6), SW(7), Coincidence_1 );
	CP2: coincidence_pulse PORT MAP( A_s, B_s, C_s, D_s, SW(8), SW(9), SW(10), SW(11), Coincidence_2 );
	CP3: coincidence_pulse PORT MAP( A_s, B_s, C_s, D_s, SW(12), SW(13), SW(14), SW(15), Coincidence_3 );

-- Once the output of the 14 bit counter reaches 1920, this process turns on the SIGNAL 'data_trigger'
-- The SIGNAL 'data_trigger' then acts as a clock pulse, reseting the counts and changing the display
	PROCESS ( data_trigger_count )
		BEGIN
		IF data_trigger_count = "000011110000000" THEN
			data_trigger_reset <= '1';
			data_trigger <= '1';
		ELSIF data_trigger_count = "000000000000000" THEN
			data_trigger_reset <= '0';
			data_trigger <= '1';
		ELSIF data_trigger_count = "000000000000001" THEN
			data_trigger_reset <= '0';
			data_trigger <= '1';
		ELSE
			data_trigger_reset <= '0';
			data_trigger <= '0';
		END IF;
	END PROCESS;
	
-- Once the output of the 13 bit counter reaches 2,604, this process turns on the SIGNAL 'baud_rate_clk'
-- The SIGNAL 'baud_rate_clk' then acts as a clock pulse, send the data out at the specified baud rate
	PROCESS ( baud_rate_count )
		BEGIN
		IF baud_rate_count = "0101000101100" THEN
			baud_rate_clk <= '1';
		ELSE
			baud_rate_clk <= '0';
		END IF;
	END PROCESS;
	
-- Uses the 14 bit counter and ~9,600 baud rate clock to count to 1/10th of a second to trigger DataOut
	C0: data_trigger_counter PORT MAP ( data_trigger_reset, baud_rate_clk, data_trigger_count );

-- Uses the 13 bit counter and 50 MHz clock to count the baud rate
	C1: baud_counter PORT MAP ( baud_rate_clk, Clock_50, baud_rate_count );

-- Uses the 32 bit counter to count the detection of single photons and coincidence photons
-- It outputs the data in 32-bit arrays and resets every 1/10th of a second
	C4: counter PORT MAP ( data_trigger_reset, Coincidence_0, Count_top_0 );
	C5: counter PORT MAP ( data_trigger_reset, Coincidence_1, Count_top_1 );
	C6: counter PORT MAP ( data_trigger_reset, Coincidence_2, Count_top_2 );
	C7: counter PORT MAP ( data_trigger_reset, Coincidence_3, Count_top_3 );
	CA: counter PORT MAP ( data_trigger_reset, A_s, A_top );
	CB: counter PORT MAP ( data_trigger_reset, B_s, B_top );
	CC: counter PORT MAP ( data_trigger_reset, C_s, C_top );
	CD: counter PORT MAP ( data_trigger_reset, D_s, D_top );
	
-- This process sets the single photon and coincidence photon count output arrays every 1/10th of a second
	PROCESS( data_trigger_reset )
	BEGIN
		IF data_trigger_reset'EVENT AND data_trigger_reset = '1' THEN
			A_out <= A_top;
			B_out <= B_top;
			C_out <= C_top;
			D_out <= D_top;
			Count_out_0 <= Count_top_0;
			Count_out_1 <= Count_top_1;
			Count_out_2 <= Count_top_2;
			Count_out_3 <= Count_top_3;
		END IF;
	END PROCESS;
	
-- Sends the A, B, C, D and the Coincidence counts out on the RS-232 port
	D0: DataOut PORT MAP( A_out, B_out, C_out, D_out, Count_out_0, Count_out_1, Count_out_2, Count_out_3, baud_rate_clk, data_trigger, UART_TXD);

-- Turns on the corresponding red LED whenever one of the DE2 board switches is turned on
--	LEDR <= SW

END Behavior;
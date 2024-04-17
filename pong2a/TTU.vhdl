-- --------------------------------------  
--
--  BASIC VHDL LOGIC GATES PACKAGE
--
--  (C) 2018, 2019 JW BRUCE, Gabriel Buckner
--  TENNESSEE TECH UNIVERSITY 
--
-- ----------------------------------------
-- ----------------------------------------
-- REVISION HISTORY
-- ----------------------------------------
-- Rev 0.1 -- Created        (JWB Nov.2018)
-- Rev 0.2 -- Refactored into package
--                           (JWB Nov.2018)
-- Rev 0.3 -- Added more combinational
--            gates and the first sequential
--            logic primitives (SR latch & FF)
--                           (JWB Dec.2018)
-- Rev 0.4 -- Clean up some and prepared
--            for use in the Spring 2019
--            semester
--                           (JWB Feb.2019)
-- Rev 0.5 -- Created better design example
--            for use in the Spring 2019
--            semester
--                           (JWB Feb.2019)
-- Rev 0.6 -- Added some behavioral combi
--            logic building blocks
--                           (JWB Sept.2019)
--
-- Rev 0.7 -- Added bin2seg7 decoder for common 
--				  annode seven segment display
--									  (Gabriel Buckner 3.20.2024)

-- Rev 0.8 -- Added psuedo random number generator 
--									  (Gabriel Buckner 3.22.2024)

-- Rev 0.9 --Added Ripple counter entity
--									  (Gabriel Buckner 3.23.2024)
-- ================================================
-- Package currently contains the following gates:
-- ================================================
--  COMBINATIONAL               SEQUENTIAL
--    inv                         SR 
--    orX
--    norX
--    andX
--    nandX
--    xorX
--    xnorX
--
--  where X is 2, 3, 4 and
--    denotes the number of inputs
-- ==================================

-- --------------------------------------  
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--- -------------------------------------  

-- EXAMPLE 1 : package and package body definition

package TTU is
  constant Size: Natural; -- Deferred constant
  subtype Byte is STD_LOGIC_VECTOR(7 downto 0);
  -- Subprogram declaration...
  function PARITY (V: Byte) return STD_LOGIC;
  function MAJ4 (x1: STD_LOGIC; x2:STD_LOGIC; x3:STD_LOGIC;x4:STD_LOGIC) return STD_LOGIC;
end package TTU;

package body TTU is
  constant Size: Natural := 16;
  -- Subprogram body...
  function PARITY (V: Byte) return STD_LOGIC is
    variable B: STD_LOGIC := '0';
  begin
    for I in V'RANGE loop
      B := B xor V(I);
    end loop;
    return B;
  end function PARITY;
  
  function MAJ4 (x1: STD_LOGIC;x2:STD_LOGIC;x3:STD_LOGIC;x4:STD_LOGIC) return STD_LOGIC is
    variable tmp: STD_LOGIC_VECTOR(3 downto 0);
    variable retval: STD_LOGIC;
  begin
    tmp := x1 & x2 & x3 & x4;
    
    if (tmp = "1110") then
      retval := '1';
    elsif (tmp = "1101") then
      retval := '1';
    elsif (tmp = "1011") then      
      retval := '1';
    elsif (tmp = "0111") then      
      retval := '1';
    elsif (tmp = "1111") then      
      retval := '1';
    else      
      retval := '0';
    end if;
    return retval;
  end function MAJ4;
  
end package body TTU;

----------------------------------------  
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity EX_PACKAGE is port(
  A  :  in Byte;
  Y  : out STD_LOGIC);
end entity EX_PACKAGE;

architecture A1 of EX_PACKAGE is
  begin
    Y <= PARITY(A);
end architecture A1;

----------------------------------------  
-- The INVERTER
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity INV_TTU is
port(
  x: in STD_LOGIC;
  y: out STD_LOGIC);
end INV_TTU;

architecture RTL of INV_TTU is
begin
  process(x) is
  begin
    y <= not x;
  end process;
end RTL;

-- ------------------------------------
-- OR GATES

----------------------------------------  
-- The TWO-INPUT OR GATE
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity OR2_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  y: out std_logic);
end OR2_TTU;

architecture RTL of OR2_TTU is
begin
  process(x0, x1) is
  begin
    y <= x0 or x1;
  end process;
end RTL;

-- The THREE-input OR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity OR3_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  y: out std_logic);
end OR3_TTU;

architecture RTL of or3_TTU is
begin
  process(x0, x1, x2) is
  begin
    y <= x1 or x2 or x0;
  end process;
end RTL;

-- The FOUR-input OR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity OR4_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  x3: in std_logic;
  y: out std_logic);
end OR4_TTU;

architecture RTL of OR4_TTU is
begin
  process(x1, x2, x3, x0) is
  begin
    y <= x1 or x2 or x3 or x0;
  end process;
end RTL;

-- ------------------------------------
-- AND GATES

-- The TWO-input AND gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity AND2_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  y: out std_logic);
end AND2_TTU;

architecture RTL of AND2_TTU is
begin
  process(x1, x0) is
  begin
    y <= x1 and x0;
  end process;
end RTL;

-- The THREE-input AND gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity AND3_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  y: out std_logic);
end AND3_TTU;

architecture RTL of AND3_TTU is
begin
  process(x1, x2, x0) is
  begin
    y <= x1 and x2 and x0;
  end process;
end RTL;

-- The FOUR-input AND gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity AND4_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  x3: in std_logic;
  y: out std_logic);
end AND4_TTU;

architecture RTL of AND4_TTU is
begin
  process(x1, x2, x3, x0) is
  begin
    y <= x1 and x2 and x3 and x0;
  end process;
end RTL;

-- ------------------------------------
-- XOR GATES

-- The TWO-input XOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity XOR2_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  y: out std_logic);
end XOR2_TTU;

architecture RTL of XOR2_TTU is
begin
  process(x1, x0) is
  begin
    y <= x1 xor x0;
  end process;
end RTL;

-- The THREE-input XOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity XOR3_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  y: out std_logic);
end XOR3_TTU;

architecture RTL of XOR3_TTU is
begin
  process(x1, x2, x0) is
  begin
    y <= x1 xor x2 xor x0;
  end process;
end RTL;

-- The FOUR-input XOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity XOR4_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  x3: in std_logic;
  y: out std_logic);
end XOR4_TTU;

architecture RTL of XOR4_TTU is
begin
  process(x1, x2, x3, x0) is
  begin
    y <= x1 xor x2 xor x3 xor x0;
  end process;
end RTL;

-- ------------------------------------
-- NOR GATES

-- The TWO-input NOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity NOR2_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  y: out std_logic);
end NOR2_TTU;

architecture RTL of NOR2_TTU is
begin
  process(x1, x0) is
  begin
    y <= x1 nor x0;
  end process;
end RTL;

-- The THREE-input NOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity NOR3_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  y: out std_logic);
end NOR3_TTU;

architecture RTL of NOR3_TTU is
begin
  process(x1, x2, x0) is
  begin
    y <= not(x1 or x2 or x0);
  end process;
end RTL;

-- The FOUR-input NOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity NOR4_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  x3: in std_logic;
  y: out std_logic);
end NOR4_TTU;

architecture RTL of NOR4_TTU is
begin
  process(x1, x2, x3, x0) is
  begin
    y <= not(x1 or x2 or x3 or x0);
  end process;
end RTL;

-- ------------------------------------
-- NAND GATES

-- The TWO-input NAND gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity NAND2_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  y: out std_logic);
end NAND2_TTU;

architecture RTL of NAND2_TTU is
begin
  process(x1, x0) is
  begin
    y <= x1 nand x0;
  end process;
end RTL;

-- The THREE-input NAND gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity NAND3_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  y: out std_logic);
end NAND3_TTU;

architecture RTL of NAND3_TTU is
begin
  process(x1, x2, x0) is
  begin
    y <= not(x1 and x2 and x0);
  end process;
end RTL;

-- The FOUR-input NAND gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity NAND4_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  x3: in std_logic;
  y: out std_logic);
end NAND4_TTU;

architecture RTL of NAND4_TTU is
begin
  process(x1, x2, x3, x0) is
  begin
    y <= not(x1 and x2 and x3 and x0);
  end process;
end RTL;

-- ------------------------------------
-- XNOR GATES

-- The TWO-input XNOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity XNOR2_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  y: out std_logic);
end XNOR2_TTU;

architecture RTL of XNOR2_TTU is
begin
  process(x1, x0) is
  begin
    y <= x1 xnor x0;
  end process;
end RTL;

-- The THREE-input XNOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity XNOR3_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  y: out std_logic);
end XNOR3_TTU;

architecture RTL of XNOR3_TTU is
begin
  process(x1, x2, x0) is
  begin
    y <= not(x1 xor x2 xor x0);
  end process;
end rtl;

-- The FOUR-input XOR gate
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity XNOR4_TTU is
port(
  x0: in std_logic;
  x1: in std_logic;
  x2: in std_logic;
  x3: in std_logic;
  y: out std_logic);
end XNOR4_TTU;

architecture RTL of XNOR4_TTU is begin
  process(x1, x2, x3, x0) is
  begin
    y <= not(x0 xor x1 xor x2 xor x3);
  end process;
end RTL;

-- =======================================================
-- === COMBINATIONAL LOGIC BUILDING BLOCKS
-- =======================================================

-- the 3-to-8 decoder
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TTU.all;

entity decoder_3to8_TTU is
	port ( 	sel : in STD_LOGIC_VECTOR (2 downto 0);
			y : out STD_LOGIC_VECTOR (7 downto 0));
end decoder_3to8_TTU;

architecture behavioral of decoder_3to8_TTU is
	begin
		with sel select
			y <=	"00000001" when "000",
					"00000010" when "001",
					"00000100" when "010",
					"00001000" when "011",
					"00010000" when "100",
					"00100000" when "101",
					"01000000" when "110",
					"10000000" when "111",
					"00000000" when others;
end behavioral;

-- the two-to-one MUX
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TTU.all;
 
entity mux_2to1_TTU is
	port(	A,B : in STD_LOGIC;
			S: in STD_LOGIC;
			Z: out STD_LOGIC);
end mux_2to1_TTU;
 
architecture behavioral of mux_2to1_TTU is
	begin
 
	process (A,B,S) is
		begin
			if (S ='0') then
				Z <= A;
			else
				Z <= B;
			end if;
	end process;
end behavioral;

-- the four-to-one MUX
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.TTU.all;

entity mux_4to1_TTU is
 port(A,B,C,D : in STD_LOGIC;
      S0,S1: in STD_LOGIC;
      Z: out STD_LOGIC);
end mux_4to1_TTU;
 
architecture behavioral of mux_4to1_TTU is
	begin
		process (A,B,C,D,S0,S1) is
			begin
  				if (S0 ='0' and S1 = '0') then
      				Z <= A;
  				elsif (S0 ='1' and S1 = '0') then
      				Z <= B;
  				elsif (S0 ='0' and S1 = '1') then
      				Z <= C;
  				else
      				Z <= D;
  				end if;
		end process;
end behavioral;

-- =======================================================
-- === SEQUENTIAL GATES
-- =======================================================
-- The SR latch
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TTU.all;

entity SR_LATCH_TTU is
    Port ( S : in    STD_LOGIC;
           R : in    STD_LOGIC;
           Q : inout STD_LOGIC;
           Qnot: inout STD_LOGIC); 
end SR_LATCH_TTU;

architecture RTL of SR_LATCH_TTU is begin
  Q    <= R nor Qnot;
  Qnot <= S nor Q;
end RTL;

-- the SR flip-flop

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TTU.all;

entity SRFF_TTU is port(
  S: in std_logic;
  R: in std_logic;
  CLK: in std_logic;
  RESET: in std_logic;
  Q: out std_logic;
  Qnot: out std_logic);
end SRFF_TTU;

architecture RTL of SRFF_TTU is begin
  process(S,R,CLK,RESET)
  begin
    if(RESET='1') then		-- async reset
       Q <= '0';
       Qnot <= '0';
    elsif(rising_edge(clk)) then	-- synchronous behavoir
       if( S /= R) then
         Q <= S;
         Qnot <= R;
       elsif (S='1' and R='1') then
         Q <= 'Z';
         Qnot <= 'Z';
       end if;
     end if;
   end process;
end RTL;

-- the D flip-flop

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.TTU.all;

entity DFF_TTU is port(
  D: in std_logic;
  CLK: in std_logic;
  RESET: in std_logic;
  Q: out std_logic;
  Qnot: out std_logic);
end DFF_TTU;

architecture RTL of DFF_TTU is begin
  process(D,CLK,RESET)
  begin
    if(RESET='1') then		-- async reset
       Q <= '0';
       Qnot <= '0';
    elsif(rising_edge(clk)) then	-- synchronous behavoir
       Q <= D;
       Qnot <= not D;
     end if;
   end process;
end RTL;



-- ------------------------------------------------------
--   BINARY TO 7 SEGMENT DECODER (COMMON ANNODE)
-- -------------------------------------------------------

-- DO NOT CHANGE THE FOLLOWING LIBRARY/USE PACKAGE LINES of CODE
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.TTU.all;

entity bin2seg7 is
	  port(inData: in std_logic_vector(3 downto 0);
			blankInput, dispHex, dispPoint: in std_logic;
			segA,segB,segC,segD,segE,segF,segG, segPoint: out std_logic);
			
			
end entity bin2seg7;

architecture behavorial of bin2seg7 is

  signal segOut: std_logic_vector(6 downto 0);
  begin
  --ACTIVE LOW ENCODER
  --this will make coding easier
  segA <= segOut(6);
  segB <= segOut(5);
  segC <= segOut(4);
  segD <= segOut(3);
  segE <= segOut(2);
  segF <= segOut(1);
  segG <= segOut(0);
  
  commonAnodeEncoder: process (inData, blankInput, dispHex, dispPoint)
  begin
  ---dispHex is active high
  if dispHex = '0' then
		case (inData) is
			--DE10 LITE HAS COMMON ANNODE 7SEGS--
			when "0000" => segOut <= "0000001";
			when "0001" => segOut <= "1001111";
			when "0010" => segOut <= "0010010";
			when "0011" => segOut <= "0000110";
			when "0100" => segOut <= "1001100";
			when "0101" => segOut <= "0100100";
			when "0110" => segOut <= "0100000";
			when "0111" => segOut <= "0001111";
			when "1000" => segOut <= "0000000";
			when "1001" => segOut <= "0000100";
			when others => segOut <= "1111111";
		end case;
	end if;
	
	if dispHex = '1' then
		case (inData) is
			--DE10 LITE HAS COMMON ANNODE 7SEGS--
			when "0000" => segOut <= "0000001";
			when "0001" => segOut <= "1001111";
			when "0010" => segOut <= "0010010";
			when "0011" => segOut <= "0000110";
			when "0100" => segOut <= "1001100";
			when "0101" => segOut <= "0100100";
			when "0110" => segOut <= "0100000";
			when "0111" => segOut <= "0001111";
			when "1000" => segOut <= "0000000";
			when "1001" => segOut <= "0000100";
			when "1010" => segOut <= "0001000";--A
			when "1011" => segOut <= "1100000";--B
			when "1100" => segOut <= "0110001";--C
			when "1101" => segOut <= "1000010";--D
			when "1110" => segOut <= "0110000";--E
			when "1111" => segOut <= "0111000";--F
			when others => segOut <= "1111111";
		end case;
	end if;
	--dispPoint is active high
	if dispPoint = '1' then
		segPoint <= '0';
	else 
		segPoint <= '1';
	end if;
	
  --active high blank input
  --this will make sure everthing is blank if blank input is high
	if blankInput = '1' then
		segOut <= "1111111";
		segPoint <= '1';
	end if;
	
  end process; 

  end architecture;



  
  
  -- ------------------------------------------------------
--   PRNG_GTBUCKNER42 PSUEDO RANDOM NUMBER GENERATOR
-- -------------------------------------------------------

-- DO NOT CHANGE THE FOLLOWING LIBRARY/USE PACKAGE LINES of CODE
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.TTU.all;

entity PRNG_gtbuckner42 is
		--sw9 is clock, sw0 is fsm input
	  port(
			seed: in std_logic_vector(20 downto 0); --seed cannot be all zero for good practice, input seed is 21 bits
			setSeed_asyn: in std_logic; --key1
			clk: in std_logic; --key0, clk
			Psuedo_Random_Num: out std_logic_vector(4 downto 0));
			
end entity PRNG_gtbuckner42;

architecture mySol of PRNG_gtbuckner42 is	
  
signal LFSR0: std_logic_vector(10 downto 0); --11 bit LFSR x11 + x9 + 1
signal LFSR1: std_logic_vector(14 downto 0); --15 bit LFSR x15 + x14 + 1
signal LFSR2: std_logic_vector(16 downto 0); --17 bit LFSR x17 + x14 + 1
signal LFSR3: std_logic_vector(17 downto 0); --18 bit LFSR x18 + x11 +1
signal LFSR4: std_logic_vector(20 downto 0); --21 bit LFSR x21 +x19 + 1  


begin

	 set_LSFRs_and_Output: process(clk, setSeed_asyn, seed) 
	   variable process_seed : std_logic_vector(20 downto 0) := "000000000000000000000";  --This is the defualt seed 011000110000010000010
		variable process_LFSR0: std_logic_vector(10 downto 0); --11 bit LFSR x11 + x9 + 1
		variable process_LFSR1: std_logic_vector(14 downto 0); --15 bit LFSR x15 + x14 + 1
		variable process_LFSR2: std_logic_vector(16 downto 0); --17 bit LFSR x17 + x14 + 1
		variable process_LFSR3: std_logic_vector(17 downto 0); --18 bit LFSR x18 + x11 +1
		variable process_LFSR4: std_logic_vector(20 downto 0); --21 bit LFSR x21 +x19 + 1 
		variable temp: std_logic;
		--verified_seed <= "011000110000010000010"; --This is the defualt seed
		
		begin		
			case setSeed_asyn is 
			 when '1'=> 
				--THIS WILL HOLD OUTPUT STABLE AS LONG AS RESET IS 1 (WILL OVERRIDE CLOCK)
				if seed(10 downto 0)  = "00000000000" then	  --THIS MEANS LFSR0 WOULD HAVE ALL ZEROS! BIG NO NO
					process_seed := seed;							  
					process_seed(0) := '1';							  --just adding on a 1 to make sure its not all zero
					
					LFSR0 <= process_seed(10 downto 0); --11 bits
					Psuedo_Random_Num(0) <= '0';
					LFSR1 <= process_seed(14 downto 0); --15 bits
					Psuedo_Random_Num(1) <= '0';
					LFSR2 <= process_seed(16 downto 0); --17 bits
					Psuedo_Random_Num(2) <= '0';
					LFSR3 <= process_seed(17 downto 0); --18 bits
					Psuedo_Random_Num(3) <= '0';
					LFSR4 <= process_seed(20 downto 0); --21 bits
					Psuedo_Random_Num(4) <= '0';
				else 
					process_seed := seed;
					LFSR0 <= process_seed(10 downto 0); --11 bits
					Psuedo_Random_Num(0) <= '0';
					LFSR1 <= process_seed(14 downto 0); --15 bits
					Psuedo_Random_Num(1) <= '0';
					LFSR2 <= process_seed(16 downto 0); --17 bits
					Psuedo_Random_Num(2) <= '0';
					LFSR3 <= process_seed(17 downto 0); --18 bits
					Psuedo_Random_Num(3) <= '0';
					LFSR4 <= process_seed(20 downto 0); --21 bits
					Psuedo_Random_Num(4) <= '0';					
				end if;
				--------------assuming first number will be 0 as 'default'
			when others =>
			 if rising_edge(clk) then
				----------------SHIFTING REGISTERS AND SETTING OUTPUT--------------------- 
				--11 bit LFSR x11 + x9 + 1
				--15 bit LFSR x15 + x14 + 1
				--17 bit LFSR x17 + x14 + 1
				--18 bit LFSR x18 + x11 +1
				--21 bit LFSR x21 +x19 + 1 
				-------LFSR0
				temp := LFSR0(10) XOR LFSR0(8);
				process_LFSR0 := std_logic_vector(shift_Left(unsigned(LFSR0),1)); --works
				process_LFSR0(0) := temp;
				Psuedo_Random_Num(0) <= temp;
				LFSR0 <= process_LFSR0;
				-------LFSR1
				temp := LFSR1(14) XOR LFSR1(13);
				process_LFSR1 := std_logic_vector(shift_Left(unsigned(LFSR1),1));
				process_LFSR1(0) := temp;
				Psuedo_Random_Num(1) <= temp;
				LFSR1 <= process_LFSR1;
				-------LFSR2
				temp := LFSR2(16) XOR LFSR2(13);
				process_LFSR2 := std_logic_vector(shift_Left(unsigned(LFSR2),1));
				process_LFSR2(0) := temp;
				Psuedo_Random_Num(2) <= temp;
				LFSR2 <= process_LFSR2;
				-------LFSR3
				temp := LFSR3(17) XOR LFSR3(10);
				process_LFSR3 := std_logic_vector(shift_Left(unsigned(LFSR3),1));
				process_LFSR3(0) := temp;
				Psuedo_Random_Num(3) <= temp;
				LFSR3 <= process_LFSR3;	
				-------LFSR4
				temp := LFSR4(20) XOR LFSR4(18);
				process_LFSR4 := std_logic_vector(shift_Left(unsigned(LFSR4),1));
				process_LFSR4(0) := temp;
				Psuedo_Random_Num(4) <= temp;
				LFSR4 <= process_LFSR4;	
				end if;
			end case;
		end process;
--test <= std_logic_vector(unsigned(test) srl 1);--shift right ex
--test <= std_logic_vector(shift_Left(unsigned(test),1)); --works

end architecture;

  
 ---RIPPLE COUNTER
 library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.TTU.all; 
  
  
 entity ripple_counter is
 generic (n : natural := 4);
 port ( clk : in std_logic;
        clear : in std_logic;
        dout : out std_logic_vector(n-1 downto 0)
 );
end ripple_counter;

--The ripple counter architecture

architecture arch_rtl of ripple_counter is
signal clk_i : std_logic_vector(n-1 downto 0);
signal q_i : std_logic_vector(n-1 downto 0);

begin
        clk_i(0) <= clk;
        clk_i(n-1 downto 1) <= q_i(n-2 downto 0);

        gen_cnt: for i in 0 to n-1 generate
                dff: process(clear, clk_i)
                begin
                        if (clear = '1') then
                                q_i(i) <= '1';
                        elsif (clk_i(i)'event and clk_i(i) = '1') then
                                q_i(i) <= not q_i(i);
                        end if;
                end process dff;
        end generate;
        dout <= not q_i;
end arch_rtl;

 

library   ieee;
use       ieee.std_logic_1164.all;
use       IEEE.numeric_std.all;
use 		  ieee.std_logic_unsigned.all;


entity hw6p3Modified is 

	port(
	
	 max10_clk      :    IN STD_LOGIC;
		
		GSENSOR_CS_N : OUT	STD_LOGIC;
		GSENSOR_SCLK : OUT	STD_LOGIC;
		GSENSOR_SDI  : INOUT	STD_LOGIC;
		GSENSOR_SDO  : INOUT	STD_LOGIC;
		
		dFix         : OUT STD_LOGIC_VECTOR(5 downto 0) := "111111";
		ledFix       : OUT STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
		
		hex5         : OUT STD_LOGIC_VECTOR(6 downto 0);
		hex4         : OUT STD_LOGIC_VECTOR(6 downto 0);
		
		hex3         : OUT STD_LOGIC_VECTOR(6 downto 0);
		hex2         : OUT STD_LOGIC_VECTOR(6 downto 0);
		
		hex1         : OUT STD_LOGIC_VECTOR(6 downto 0);
		hex0         : OUT STD_LOGIC_VECTOR(6 downto 0);
		
		data_x      : BUFFER STD_LOGIC_VECTOR(15 downto 0);
		data_y      : BUFFER STD_LOGIC_VECTOR(15 downto 0);
		data_z      : BUFFER STD_LOGIC_VECTOR(15 downto 0);
		datax_toPixelx: out integer;
		datay_toPixely: out integer
		
	);
	
end hw6p3Modified;

architecture mysol of hw6p3Modified is
	

	component ADXL345_controller is port(
	
		reset_n     : IN STD_LOGIC;
		clk         : IN STD_LOGIC;
		data_valid  : OUT STD_LOGIC;
		data_x      : OUT STD_LOGIC_VECTOR(15 downto 0);
		data_y      : OUT STD_LOGIC_VECTOR(15 downto 0);
		data_z      : OUT STD_LOGIC_VECTOR(15 downto 0);
		SPI_SDI     : OUT STD_LOGIC;
		SPI_SDO     : IN STD_LOGIC;
		SPI_CSN     : OUT STD_LOGIC;
		SPI_CLK     : OUT STD_LOGIC
		
    );
	
    end component;
	
	component bcd_7segment is port(
	
		BCDin : in STD_LOGIC_VECTOR (3 downto 0);
		Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0)
	
	);
	
	end component;
	
		component pll 
		PORT (
		inclk0: in std_logic;
		c0	: out std_logic
		);
		end component;
		
		component ripple_counter
		generic (n : natural := 4);
		port ( clk : in std_logic;
        clear : in std_logic;
        dout : out std_logic_vector(n-1 downto 0)
			);
		end component;
		
		signal co_to_iSPI_CLK, c1_to_iSPI_CLK_OUT, oRST_to_RESET : STD_LOGIC;
		signal clk_internal_sig: std_logic;
		signal inc_dec: std_logic;
		signal clear_overflow,clear_overflow2: std_logic;
		signal dout,dout2: std_logic_vector(23 downto 0);
		signal up_down: std_logic; --up is active high, down is active low
		signal counter_out: std_logic_vector(11 downto 0);
		signal reg_cnt, nxt_cnt : std_logic_vector(11 downto 0);
		signal reset_value, reset_value2: std_logic_vector(23 downto 0);
		signal dir, arst: std_logic;
		signal en: std_logic:= '1';
		signal cnt_dout: std_logic_vector(11 downto 0);
		
		--signal tempAddX : STD_LOGIC_VECTOR(15 downto 0);
		
		
		--signal tff : STD_LOGIC_VECTOR(15 downto 0) := "0000000011111111";
		
		--signal zFix : STD_LOGIC := '0';
		
begin
	pll_inst : pll PORT MAP (inclk0	=> max10_clk, c0  => clk_internal_sig);

	U0 : ADXL345_controller port map('1', max10_clk, open, data_x, data_y, data_z, GSENSOR_SDI, GSENSOR_SDO, GSENSOR_CS_N, GSENSOR_SCLK);
	
	U1 : bcd_7segment port map (data_x(7 downto 4), hex4);
	U2 : bcd_7segment port map (data_x(11 downto 8), hex5);	
	
	U3 : bcd_7segment port map (data_y(7 downto 4), hex2);
	U4 : bcd_7segment port map (data_y(11 downto 8), hex3);
	
	U5 : bcd_7segment port map (cnt_dout(7 downto 4), hex1);
	U6 : bcd_7segment port map (cnt_dout(3 downto 0), hex0);
		 
	
		--datax_toPixelx: out integer;
		--datay_toPixely: out integer;
	
		set_datax_toPixelx:process(data_x(11 downto 4))
		 variable integer_value: integer:=0;
		 variable temp:integer:= 0;
		 
		 begin
		 --This process uses variables to map the accelorometer value onto 
		 --an integer for (pixels/1000Frames)/data_x that will be used to move the box
		 temp:= to_integer(unsigned(data_x(11 downto 4)));--convert data_x into  integer
		 if (data_x(11 downto 4) >= x"01" and data_x(11 downto 4) <= x"0F") then --if tilting left
			integer_value:= (-140 * temp) + 36; --found this equation using epic math skills
		 elsif (data_x(11 downto 4) >= x"F0" and data_x(11 downto 4) <= x"FF"  ) then --tilting right
			integer_value:= (-127 * temp) + 32485;  --these values found by picking how fast I want the box to move
		 elsif(data_x(11 downto 4) = x"00") then
			integer_value:= 0;
		 end if;
		 datax_toPixelx <= integer_value;
		 end process;	

		 set_datay_toPixely:process(data_y(11 downto 4))
		 variable integer_value: integer:=0;
		 variable temp:integer:= 0;
		 
		 begin
		 --This process uses variables to map the accelorometer value onto 
		 --an integer for (pixels/1000Frames)/data_x that will be used to move the box
		 temp:= to_integer(unsigned(data_y(11 downto 4)));--convert data_x into  integer
		 if (data_y(11 downto 4) >= x"01" and data_y(11 downto 4) <= x"0F") then --if tilting down
			integer_value:= (136 * temp) - 36; --found this equation using epic math skills
		 elsif (data_y(11 downto 4) >= x"F0" and data_y(11 downto 4) <= x"FF"  ) then --tilting up
			integer_value:= (127 * temp) - 32485;  
		 elsif(data_y(11 downto 4) = x"00") then
			integer_value:= 0;
		 end if;
		 datay_toPixely <= integer_value;
		 end process;	

		 
		
		
end mysol;
	
	
	
	--U1 : bcd_7segment port map (sw1, hex4);
	--U2 : bcd_7segment port map (sw2, hex5);

	--tempAddX <= std_logic_vector(unsigned(data_x) + "1111111111111111");
   --my_slv <= std_logic_vector(to_unsigned(my_int, my_slv'length)); converting from int to vector
--temp:= to_integer(unsigned(data_y(11 downto 4)));--convert data_x into  integer



-----------------------------------------------------------------------------------
--PE2_gtbuckner42
--AUTHOR(S)			Gabriel Buckner, Brennan Angus
--DATE:				4/7/2024	
------------------------------------------------------------------------------------

library   ieee;
use       ieee.std_logic_1164.all;
use       IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity PE2_gtbuckner42 is
	
	port(
	
		-- Inputs for image generation
		
		pixel_clk_m		:	IN	STD_LOGIC;     -- pixel clock for VGA mode being used 
		reset_n_m_sw0		:	IN	STD_LOGIC; --active low asycnchronous reset --TURNED ACTIVE HIGH GB 4/9/2024
		
		-- Outputs for image generation 
		
		h_sync_m		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync_m		:	OUT	STD_LOGIC;	--vertical sync pulse 
		
		red_m      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
	
		--below is for accelerometer
		-- max10_clk      :    IN STD_LOGIC; REPLACED BY PIXEL_CLK_M
		
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
		
		Key0			: in Std_logic;
		key1			: in std_logic;
		buzz_sig		: buffer std_logic:='1';
		
		Rotary_clk:in std_logic;
		Rotary_DT:in std_logic;
		
		Rotary_clk2:in std_logic;
		Rotary_DT2:in std_logic
	);
	
end PE2_gtbuckner42;

architecture vga_structural of PE2_gtbuckner42  is

	component vga_pll_25_175 is 
	
		port(
		
			inclk0		:	IN  STD_LOGIC := '0';  -- Input clock that gets divided (50 MHz for max10)
			c0			:	OUT STD_LOGIC          -- Output clock for vga timing (25.175 MHz)
		
		);
		
	end component;
	
	component vga_controller is 
	
		port(
		
			pixel_clk	:	IN	STD_LOGIC;	--pixel clock at frequency of VGA mode being used
			reset_n		:	IN	STD_LOGIC;	--active low asycnchronous reset
			h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
			v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
			disp_ena	:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
			column		:	OUT	INTEGER;	--horizontal pixel coordinate
			row			:	OUT	INTEGER;	--vertical pixel coordinate
			n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
			n_sync		:	OUT	STD_LOGIC   --sync-on-green output to DAC
		
		);
		
	end component;
	
	component hw_image_generator is
	
		port(
		
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
    red      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
	 
	 ball1_col :  in integer;
	 ball1_row :  in integer;
	 ball_size : in integer;
	 upper_box:  in integer;--spawn location for the boundary box
	 lower_box:  in integer;
	 upper_box_h: in integer;--height of box
	 lower_box_h: in integer;
	 Middle_box_w: in integer; --width of middle box
	 Middle_box: in integer;
	 left_paddle_x:in integer;
	 left_paddle_y:in integer;
	 right_paddle_y:in integer;
	 right_paddle_x:in integer;
	 paddle_width:in integer;
	 paddle_height:in integer;
	 
	--THESE ARENT NEEDED IN THIS VERSION, kept in for documentation
--	--signals for score boxes
--	score_w:	  			in integer; --NEEDS TO BE IN FORM OF SCALE FACTOR width will be 8 * score_w
--	score_h:	  			in integer;	--NEEDS TO BE IN FORM OF SCALE FACTOR height will be 8 * score_h
--	score_spacing:		in integer;
--	--boxes will spawn from top left pixel
--	left_score1: 		in integer; --msb of left score
--	left_score0: 		in integer;--lsb left score
--	right_score0:		in integer;
--	right_score1:		in integer;
	volly_num:			in integer;
	player_L_score:	in integer;
	player_R_score:	in integer
	 
	 );
		
	end component;
	
	--THIS IS The ACCELEROMETER
	component hw6p3Modified is
	port(
		 max10_clk      :    IN STD_LOGIC;
		
		GSENSOR_CS_N : OUT	STD_LOGIC;
		GSENSOR_SCLK : OUT	STD_LOGIC;
		GSENSOR_SDI  : INOUT	STD_LOGIC;
		GSENSOR_SDO : INOUT	STD_LOGIC;
		
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
	end component;	
	
	--leaving this PRGN for later use in final project
	component PRNG_gtbuckner42 is
	  port(
			seed: in std_logic_vector(20 downto 0); --seed cannot be all zero for good practice, input seed is 21 bits
			setSeed_asyn: in std_logic; --key1
			clk: in std_logic; --key0, clk
			Psuedo_Random_Num: out std_logic_vector(4 downto 0));
	end component;
	
	component dual_boot is
		port (
			clk_clk       : in std_logic := 'X'; -- clk
			reset_reset_n : in std_logic := 'X'  -- reset_n
		);
	end component dual_boot;
	
	component bcd_7segment is port(
	
		BCDin : in STD_LOGIC_VECTOR (3 downto 0);
		Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0)
	
	);
	end component;
	
	
	signal pll_OUT_to_vga_controller_IN, dispEn : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER;



	signal max10_clk 			:STD_LOGIC;
	signal ball1_direction	:integer:=0 ;
	
	signal datax_toPixelx	:integer; --in form of (x)(pixels/1000frames)/data_x
	signal datay_toPixely	:integer;
		
		
	signal upper_box			:integer:= 20; --upper box y spawn location
	signal upper_box_h		:integer:= 10;
	signal lower_box_h		:integer:= 10;
	signal lower_box			:integer:= 480 - lower_box_h - 20 ;--lower box y spawn location
	signal Middle_box_w		:integer:= 3; --width of middle box
	signal Middle_box			:integer:= (640/2)-Middle_box_w; --spawn location of middle box
	
	--The following sets signals for the paddle starting locations
	signal left_paddle_y		:integer:= 240;
	signal left_paddle_x		:integer:= 40;
	signal right_paddle_y	:integer:=240;
	signal right_paddle_x	:integer:= 640 - 40;
	signal paddle_width		:integer:=3;
	signal paddle_height		:integer:=45;
	signal left_paddle_middle  :integer:=left_paddle_y+paddle_height/2;
   signal right_paddle_middle :integer:=right_paddle_y+paddle_height/2;
  
	
	---NOT NEEDED UNTIL LATER VERSIONS (FOR ON SCREEN SCOREBOARD)
--	--signals for score boxes
--	signal score_w				:integer:= 4; --NEEDS TO BE IN FORM OF SCALE FACTOR width will be 8 * score_w
--	signal score_h				:integer:= 4; --NEEDS TO BE IN FORM OF SCALE FACTOR height will be 8 * score_h
--	signal score_spacing		:integer:= 10;
	--boxes will spawn from top left pixe
--	signal left_score1		:integer:= 320 - 20 - (32 * 2) - score_spacing; --msb of left score
--	signal left_score0		:integer:= 320 - 20 - (32 * 1);--lsb left score
--	signal right_score0		:integer:= 320 + 20 + (32 * 1) + score_spacing - Middle_box_w - 5; --minus 5 lines it up better
--	signal right_score1		:integer:= 320 + 20 - Middle_box_W - 5;
	signal player_L_score	:integer:=0;
	signal player_R_score	:integer:=0;
	signal player_L_scoreLSBs:STD_LOGIC_VECTOR(3 downto 0):="0000";--these are for hex scoreboard
	signal player_L_scoreMSBs:STD_LOGIC_VECTOR(3 downto 0):="0000";
	signal Player_R_scoreLSBs:STD_LOGIC_VECTOR(3 downto 0):="0000";
	signal Player_R_scoreMSBs:STD_LOGIC_VECTOR(3 downto 0):="0000";
	
	signal player_L_scored	:std_logic:='0';
	signal player_R_scored	:std_logic:='0';
	
	--signals for ball
	signal ball_speed			:integer;
	signal ball1_col 			:integer:= 310;
	signal ball1_row 			:integer:= 240;
	signal ball_size			:integer:=5;
	signal ball1_row_middle :integer:= ball1_row+ball_size/2;
	signal ball1_col_middle :integer:= ball1_col+ball_size/2;
	 signal y_factor_inv     :integer:=70; -- <BA> normalizes the y speed with which the ball bounces off of the left and right paddles
	--need seperate signals for resetting because You cannot have constant drivers
	signal Rst_game			:std_logic;
	--signals for randomness
	signal seed: std_Logic_vector(20 downto 0):= "100101001110010101111"; --i randomly typed numbers
	signal seed2:std_logic_vector(20 downto 0):= "010110100110111110001"; --i randomlly typed numbers again
	signal Psuedo_Random_Num: std_logic_vector(4 downto 0);
	signal Psuedo_Random_Num2: std_logic_vector(4 downto 0);
	signal seed_set: std_logic;
	signal seed_set2:std_logic;
	
	signal volly_num:integer:=0;
	

	
	--SIGNAL FOR ACTIVE LOW RESET
	signal reset_n_m			:std_logic;
	
	type State_Type is (reset_game, volly, update_score_rst_ball);
		signal Current_State : State_Type;
		signal Next_State : State_Type;
	
begin
	max10_clk <= pixel_clk_m;
	reset_n_m <= not reset_n_m_sw0;
	--accelerometer is below
	PRGN_1 : PRNG_gtbuckner42 port map(seed => seed, setSeed_asyn => seed_set, clk => pll_OUT_to_vga_controller_IN,
			Psuedo_Random_Num=>Psuedo_Random_Num); 
	PRGN_2 : PRNG_gtbuckner42 port map(seed => seed2, setSeed_asyn => seed_set2, clk => pll_OUT_to_vga_controller_IN,
			Psuedo_Random_Num=>Psuedo_Random_Num2);		
			
			
	accelerometer: hw6p3Modified port map(max10_clk => max10_clk, GSENSOR_CS_N => GSENSOR_CS_N, GSENSOR_SCLK => GSENSOR_SCLK, GSENSOR_SDI => GSENSOR_SDI, 
						GSENSOR_SDO => GSENSOR_SDO, dFix => dFix, ledFix => ledFix,
						data_x=>data_x,data_y=>data_y,data_z=>data_z, datax_toPixelx => datax_toPixelx,
						datay_toPixely => datay_toPixely);			
			
	
	-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, reset_n_m, h_sync_m,
				v_sync_m, dispEn, colSignal, rowSignal, open, open);
				
	U3	:	hw_image_generator port map(dispEn, rowSignal, colSignal, red_m, green_m, blue_m,
			ball1_col => ball1_col, ball1_row =>ball1_row, ball_size => ball_size,upper_box => upper_box,
			lower_box => lower_box, upper_box_h => upper_box_h,lower_box_h => lower_box_h,
			middle_box_w => middle_box_w, middle_box => middle_box, left_paddle_x => left_paddle_x,
			left_paddle_y => left_paddle_y, right_paddle_x => right_paddle_x,right_paddle_y => right_paddle_y,
			paddle_width => paddle_width, paddle_height =>paddle_height,
			player_L_score => player_L_score, player_R_score => player_R_Score, volly_num => volly_num);
			
	U4 : bcd_7segment port map (player_L_scoreLSBs, hex4);
	U5 : bcd_7segment port map (player_L_scoreMSBs, hex5);	
	
	midSeg1 : bcd_7segment port map ("0000", hex2);
	midSeg2 : bcd_7segment port map ("0000", hex3);
	
	U6 : bcd_7segment port map (player_R_scoreMSBs, hex1);
	U7 : bcd_7segment port map (player_R_scoreLSBs, hex0);			
			

	--THIS IS TO LOAD ONTO FPGA FLASH MEMORY FOR JTAG LOADING ON STARTUP
   dualboot : component dual_boot
		port map (
			clk_clk       => pixel_clk_m,       --   clk.clk
			reset_reset_n => '1' -- reset.reset_n
		);
	
	---NEXT THREE PROCESSES ARE FOR THE FSM THAT DRIVES THE GAME
	STATE_MEMORY : process (pixel_clk_m, Key0) begin
		if (Key0 = '0') then --keys on DE10LITE are active low
			Current_State <= reset_game;
		elsif rising_edge(pixel_clk_m) then
			Current_State <= Next_State;
		end if;
	end process;
	
	--FFOR REF:type State_Type is (reset_game, volly, update_score_rst_ball)
	NEXT_STATE_LOGIC: process (key1, player_R_scored , player_L_scored, Current_State,key0) begin
		case Current_State is
			when reset_game => if Key1='0' then Next_State <= volly;
				else Next_State <= reset_game;
				end if;
		when volly => if (player_R_scored = '1' or player_L_scored = '1') then Next_State <= update_score_rst_ball;
				else Next_State <= volly;
				end if;
		when update_score_rst_ball => 
				if player_L_score > 10 or Player_R_score > 10 then  
					if key1 = '0' then Next_state <= reset_game;
					else					 Next_state <= update_score_rst_ball;
					end if;
				elsif key1 = '1' then Next_State <= update_score_rst_ball;
				elsif key1 = '0' then Next_State <= volly; --waits until key1 is pressed to play next section
				
				end if;
		when others => Next_State <= reset_game;
		end case;
	end process;
	
	--
	
	--GB CHANGED 4/15/24
	OUTPUT_LOGIC:process (Current_State) begin
		case Current_State is
			when reset_game => 
				Rst_game <= '1';
			when volly =>
				Rst_game <= '0';
			when update_score_rst_ball => 	
				rst_game <= '0';
			when others => 
		end case;
	end process;	
	
	
	moveball_and_set_Scoreboard_once_scored:process(dispEn)
	  variable enable:std_logic:='1';
	  variable ball_x:integer:=ball1_col;
	  variable ball_y:integer:=ball1_row;
	  variable scalarx:integer:= 4;
	  variable scalary:integer:= 4;
	  variable x_inc	:integer:= 0;--in form of (pixels * 10000)
	  variable y_inc  :integer:= 0;--in form of (pixels * 10000)
	  variable RandNum:integer:= 0;
	  variable RandNum2:integer:=0;
	  variable x_speed_default:integer:=400; --min value 400 (feels right) max is round 900
	  variable x_speed_max:integer:=900;
	  variable ball_x_10000:integer:= 3200000*scalarx; --in form of (pixels * 10000)
	  variable ball_y_10000:integer:= 2400000*scalary;	  
	  variable var_L_score:std_logic_vector(7 downto 0):="00000000";
	  variable var_R_score:std_logic_vector(7 downto 0):="00000000";
	  --I like my variables :)
	  
	 begin		
		if(rising_edge(dispEN) and current_state = volly) then --calculate stuff while frame is being printed 
			enable:= '1';
			
			RandNum:= to_integer(unsigned(Psuedo_Random_Num(3 downto 0))); --sets random number each frame
			RandNum2:= to_integer(unsigned(Psuedo_Random_Num2(3 downto 0))); --sets random number each frame
			if(Psuedo_Random_Num(4) = '1') then --I want to set the variable negative if msb is 1 
				RandNum:= -RandNum;
			end if;
			if(Psuedo_Random_Num2(4) = '1') then --I want to set the variable negative if msb is 1 
				RandNum2:= -RandNum2;
			end if;
				ball_x_10000:= x_inc + ball_x_10000;
				ball_y_10000:= y_inc + ball_y_10000;

				ball_x:= ball_x_10000/10000/scalarx; --truncated value in form of pixels
				ball_y:= ball_y_10000/10000/scalary; --these are the col and row signals in variable form
				
				--collision handling Need to modify to collide with paddles and bounds and bounce off.
				if(ball_y < (upper_box + upper_box_h) or (ball_y + ball_size) > lower_box) then
					y_inc := -y_inc;
		       end if;	
				
				--if collides with left or right border wall
				--values arent exactly the border
				--this is intentional so that ball remains on screen
				if(ball_x < 5 or (ball_x + ball_size) > 639) then
					if ball_x <= 5 then
						player_R_scored <= '1'; 
					elsif ball_x + ball_size >= 634 then
						player_L_scored <= '1';
					end if;
				end if;	
				
				--------COLLISIONS FOR BALLS
				--for right paddle
				--if ball collides with right paddle
				if((ball_X + ball_size = right_paddle_x and ball_x < right_paddle_x + paddle_width) and (ball_y + ball_size >= right_paddle_y and ball_y < right_paddle_y + paddle_height)) then
					--increase speed and check speed limit
					if x_inc < 0 then
							x_inc := x_inc - 5;
							if x_inc < -x_speed_max then
								x_inc:= -x_speed_max;
							end if;
						else
							x_inc := x_inc + 5;
							if x_inc > x_speed_max then
								x_inc:= x_speed_max;
							end if;
						end if;
					x_inc:= -x_inc;	
					y_inc := -x_inc*(ball1_row_middle-right_paddle_middle)/y_factor_inv;
				
				end if;
				--now for left paddle
				if((ball_x = left_paddle_x + paddle_width and ball_x > left_paddle_x) and (ball_y + ball_size >= left_paddle_y and ball_y < left_paddle_y + paddle_height)) then
					--increase speed and check speed limit
					if x_inc < 0 then
						x_inc := x_inc - 5;
						if x_inc < -x_speed_max then
							x_inc:= -x_speed_max;
						end if;
					else
						x_inc := x_inc + 5;
						if x_inc > x_speed_max then
							x_inc:= x_speed_max;
						end if;
					end if;
					x_inc:= -x_inc;
					y_inc := x_inc*(ball1_row_middle-left_paddle_middle)/y_factor_inv;
				
				end if;
				
				--making seperate ifs for the volly_num
				if (ball1_col + ball_size = right_paddle_x and ball1_col < right_paddle_x + paddle_width) and (ball1_row + ball_size  >= right_paddle_y and ball1_row < right_paddle_y + paddle_height) 
					then--right paddle (the +- 2 addes a small buffer to make sure the collision gets detected)
						volly_num<= volly_num +1;
					elsif (ball1_col = left_paddle_x + paddle_width  and ball1_col > left_paddle_x) and (ball1_row + ball_size >= left_paddle_y and ball1_row < left_paddle_y + paddle_height)
					then--left paddle
						volly_num<= volly_num +1;
					end if;					
				
				
		 end if;
		 
		 			if(current_state = reset_game )then
						--rough outline of following code
						--reset scores and seed random nums
						--set the direction then check for angle
						--want the direction to be 60deg or less
						--so tan(60)*100 = 173
						--SO -> (100|y|)/|x| = 173					
						player_L_score <= 0;
						player_R_score <= 0;
						--signals for seven seg below
						player_L_scoreLSBs <= "0000";
						player_L_scoreMSBs <= "0000";
						player_R_scoreLSBs <= "0000";
						player_R_scoreMSBs <= "0000";
						player_R_scored <='0';
						player_L_scored <='0';
						--seed the random numbers for initial values
						RandNum:= to_integer(unsigned(Psuedo_Random_Num(3 downto 0))); --sets random number each frame
						RandNum2:= to_integer(unsigned(Psuedo_Random_Num2(3 downto 0))); --sets random number each frame
						if(Psuedo_Random_Num(0) = '1') then --I want to set the variable negative if msb is 1 
							RandNum:= -1 * RandNum;
						end if;
						if(Psuedo_Random_Num2(0) = '1') then --I want to set the variable negative if msb is 1 
							RandNum2:= -1 * RandNum2;
						end if;
						ball_x:= 320;
						ball_y:= 240;
						ball_x_10000:= 320*10000*scalarX;
						ball_y_10000:= 240*10000*scalary;
						volly_num<= 0;
						x_inc := x_speed_default;
						y_inc := ((RandNum2 * 10) rem (173*x_speed_default/100)); 
						--considering y = randNum2*10000. this makes y a random num (use rem instead of mod)
						--this then makes the angle less than 60 deg

					end if;
					
			---------------------------UPDATE SCOREBOARD------------------------------
		 			if(current_state = update_score_rst_ball and enable = '1') then
							--check who scored and increment score accordingly...
							if Player_L_scored = '1' then
							player_L_score <= player_L_score + 1;
							var_L_score := var_L_score + 1;
							--signals for seven segs below
							Player_L_scoreLSBs <= std_logic_vector(to_unsigned((player_L_score + 1) mod 16,Player_L_scoreLSBs'length));
							Player_L_scoreMSBs <= std_logic_vector(to_unsigned((player_L_score + 1) / 16,Player_L_scoreLSBs'length));
							else
							player_R_score <= Player_R_score + 1;
							var_R_score := var_R_score + 1;
							--this somehow breaks the scoreboard
							Player_R_scoreLSBs <= std_logic_vector(to_unsigned((player_R_score + 1) mod 16,Player_R_scoreLSBs'length));
							Player_R_scoreMSBs <= std_logic_vector(to_unsigned((player_R_score + 1) / 16,Player_R_scoreLSBs'length));
							end if;
						enable:='0';
						--seed the random numbers
						RandNum:= to_integer(unsigned(Psuedo_Random_Num(3 downto 0))); --sets random number each frame
						RandNum2:= to_integer(unsigned(Psuedo_Random_Num2(3 downto 0))); --sets random number each frame
						if(Psuedo_Random_Num(0) = '1') then --I want to set the variable negative if msb is 1 
							RandNum:= -1 * RandNum;
						end if;
						if(Psuedo_Random_Num2(0) = '1') then --I want to set the variable negative if msb is 1 
							RandNum2:= -1 * RandNum2;
						end if;
						ball_x:= 320;
						ball_y:= 240;
						ball_x_10000:= 320*10000*scalarX;
						ball_y_10000:= 240*10000*scalary;
						volly_num<= 0;
						x_inc := x_speed_default;
						y_inc := ((RandNum2 * 10) rem (173*x_speed_default/100)); --considering y = randNum2*10000. this makes y a random num (use rem instead of mod)
						--that makes the angle less than 60 deg
							player_R_scored <='0';
							player_L_scored <='0';
					end if;					
					
		if(falling_edge(dispEN)) then ---move ball at end of frame(TEST)
			ball1_col <= ball_x;
			ball1_row <= ball_y;
		end if;
	end process;
-------------------------END BALL LOGIC----------------------------------------------------------------------------------	
	
		move_paddle_L:process(dispEN,Rotary_clk)
	variable enable: std_logic:= '1'; --this ensures each click of RE gets registerd once
	variable paddle_y:integer:=240;
	variable move_amt:integer:=10;--in form of pixels
	variable prev_clk_val:integer:=-1;--negative 1 means not set
	
	begin
	 if(rising_edge(dispEN)) then
		if(prev_clk_val = -1) then --sets initial state
			if(rotary_clk = '1') then
				prev_clk_val := 1;
			else
				prev_clk_val := 0;
			end if;
		end if;

		--RE Logic to check for clockwise or counterclockwise rotation
		if((prev_clk_val = 0 and rotary_clk = '1') or (prev_clk_val = 1 and rotary_clk = '0')) --checks for transition of clk
		then
			--now to reset previous value
		 if(rotary_clk = '1') then
				prev_clk_val := 1;
		 else
				prev_clk_val := 0;
		 end if;
		
		 --logic for rotary clock
		 if(rotary_clk = '1' and enable = '1') then
			if(rotary_clk /= rotary_dt) then
				paddle_y:= paddle_y + move_amt;
				enable := '0';
				end if;
			if(rotary_clk = rotary_dt) then
				paddle_y:= paddle_y - move_amt;
				enable := '0';
				end if;
		 
		 elsif(rotary_clk = '0' and enable = '1') then
			if(rotary_clk /= rotary_dt) then
				paddle_y:= paddle_y + move_amt;
				enable := '0';
				end if;
			if(rotary_clk = rotary_dt) then
				paddle_y:= paddle_y - move_amt;
				enable := '0';
				end if;	
		   end if; --end rotary logic ifs
	    end if; --end transition check if statement
		  
			--collision handling
		   if(paddle_y < (upper_box + upper_box_h)) then
			paddle_y:= upper_box + upper_box_h;
		   elsif (paddle_y + paddle_height > lower_box ) then
			paddle_y:= lower_box - paddle_height;
		   end if;
		  
		 end if; --end rising_edge(rotary_clk) if statement
	 
		 --this resets enable, 'primes' the board to take in another RE rotation
		 if((rotary_clk xor rotary_dt) = '0' and dispEN = '0') then 
				enable := '1';
		 end if;
		
		
		--prevents paddle from moving during reset phase
		if(Rst_game = '1') then
			Paddle_y := 220;
		end if;
		
		if(falling_edge(dispEN)) then ---move box at end of frame
			left_paddle_y <= paddle_y;
		end if;
		  
	end process;

	--MODIFIED CODE TAKEN FROM PREVIOUS HOMEWORK
   --Implements accelerometer to move the right paddle
	move_paddle_R:process(dispEn)
	  variable box_y_10000:integer:= 2000000;
	  variable box_y:integer:=right_paddle_y;
	  variable scalarx:integer:= 4;
	  variable scalary:integer:= 4;
	 begin
		
		if(rising_edge(dispEN)) then --calculate stuff while frame is being printed
			box_y_10000:= datay_toPixelY + box_y_10000;
			box_y:= box_y_10000/10000/scalary; --these are the col and row signals in variable form
			
			 --collision handling
			if(box_y < (upper_box + upper_box_h)) then
				box_y:= upper_box + upper_box_h;
				box_y_10000:= (box_y) *10000*scalary;
			
			elsif (box_y + paddle_height > lower_box ) then
				box_y:= lower_box - paddle_height;
				box_y_10000:= (box_y) *10000*scalary;
			end if;				 

		 end if; --end rising_edge if statement
		 
		 --prevents paddle from moving during reset phase
		 if(Rst_game = '1') then
			box_y := 220;
			box_y_10000:= 220*10000*scalary;
		end if;
		
		if(falling_edge(dispEN)) then ---move box at end of frame(TEST)
			--box1_col <= box_x;
			right_paddle_y <= box_y;
		end if;
	end process;
	
	-------THIS SETS SEED ON STARTUP OR SEED CHANGE
	setSeedHandler:process(pll_out_to_vga_controller_in, seed)
	variable startUpVar: integer:= 0; --will allow seed to be set
	variable seed_current: std_logic_vector(20 downto 0);
	begin
		if rising_edge(pll_out_to_vga_controller_in) then
			if(seed /= seed_current) then --detects change in seed
			startUpVar:= 0;
			end if;
			if(startUpVar < 5) then --gives PRNG_gtbuckner42 5 clk cyles to set seed
				seed_current := seed;
				seed_set <= '1';
				startUpVar:= startUpVar + 1;
			else
				seed_set <= '0';
			end if;
		end if;	
	end process;
	
	-------THIS SETS SEED ON STARTUP OR SEED CHANGE
	setSeedHandler2:process(pll_out_to_vga_controller_in, seed2)
	variable startUpVar: integer:= 0; --will allow seed to be set
	variable seed_current: std_logic_vector(20 downto 0);
	begin
		if rising_edge(pll_out_to_vga_controller_in) then
			if(seed2 /= seed_current) then --detects change in seed
			startUpVar:= 0;
			end if;
			if(startUpVar < 5) then --gives PRNG_gtbuckner42 5 clk cyles to set seed
				seed_current := seed2;
				seed_set2 <= '1';
				startUpVar:= startUpVar + 1;
			else
				seed_set2 <= '0';
			end if;
		end if;	
	end process;
end vga_structural;

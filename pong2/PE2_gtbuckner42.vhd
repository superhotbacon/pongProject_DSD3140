-----------------------------------------------------------------------------------
--PE2_gtbuckner42
--AUTHOR:			Gabriel Buckner
--DATE:				4/7/2024
--CONSULTATIONS:	Brennan Angus
--EXPLANATION:		Brennan and I talked about implementing the rotary encoder
--						conceptually as well as discussing pin assignmennt errors.
--						Brennan also shared a link to a website discussing rotary 
--						encoders. The link to this resource is below.
--						All IP and code contained here is my own except for the VGA base.
--						https://lastminuteengineers.com/rotary-encoder-arduino-tutorial/
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
		Rotary_clk:in std_logic;
		Rotary_DT:in std_logic
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
	 
	--signals for score boxes
	score_w:	  			in integer; --NEEDS TO BE IN FORM OF SCALE FACTOR width will be 8 * score_w
	score_h:	  			in integer;	--NEEDS TO BE IN FORM OF SCALE FACTOR height will be 8 * score_h
	score_spacing:		in integer;
	--boxes will spawn from top left pixel
	left_score1: 		in integer; --msb of left score
	left_score0: 		in integer;--lsb left score
	right_score0:		in integer;
	right_score1:		in integer;
	player_L_score:	in integer;
	player_R_score:	in integer
	 
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
	
	component dual_boot is
		port (
			clk_clk       : in std_logic := 'X'; -- clk
			reset_reset_n : in std_logic := 'X'  -- reset_n
		);
	end component dual_boot;
	
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
	signal paddle_width		:integer:=5;
	signal paddle_height		:integer:=45;
	
	--signals for score boxes
	signal score_w				:integer:= 4; --NEEDS TO BE IN FORM OF SCALE FACTOR width will be 8 * score_w
	signal score_h				:integer:= 4; --NEEDS TO BE IN FORM OF SCALE FACTOR height will be 8 * score_h
	signal score_spacing		:integer:= 10;
	--boxes will spawn from top left pixe
	signal left_score1		:integer:= 320 - 20 - (32 * 2) - score_spacing; --msb of left score
	signal left_score0		:integer:= 320 - 20 - (32 * 1);--lsb left score
	signal right_score0		:integer:= 320 + 20 + (32 * 1) + score_spacing - Middle_box_w - 5; --minus 5 lines it up better
	signal right_score1		:integer:= 320 + 20 - Middle_box_W - 5;
	signal player_L_score	:integer:=14;
	signal player_R_score	:integer:=93;
	signal ball_scored		:std_logic;
	
	--signals for ball
	signal ball_speed			:integer;
	signal ball1_col 			:integer:= 310;
	signal ball1_row 			:integer:= 240;
	signal ball_size			:integer:= 4;
	
	--need seperate signals for resetting because You cannot have constant drivers
	signal Rst_game			:std_logic;
	
	--signals for randomness
	signal seed: std_Logic_vector(20 downto 0):= "100101001110010101111"; --i randomly typed numbers
	signal seed2:std_logic_vector(20 downto 0):= "010110100110111110001"; --i randomlly typed numbers again
	signal Psuedo_Random_Num: std_logic_vector(4 downto 0);
	signal Psuedo_Random_Num2: std_logic_vector(4 downto 0);
	signal seed_set: std_logic;
	signal seed_set2:std_logic;
	
	--SIGNAL FOR ACTIVE LOW RESET
	signal reset_n_m			:std_logic;
	
	type State_Type is (reset_game, volly, update_score_rst_ball);
		signal Current_State : State_Type;
		signal Next_State : State_Type;
	
	
	--THIS IS A TEST TO PUSh
begin
	max10_clk <= pixel_clk_m;
	reset_n_m <= not reset_n_m_sw0;
	--accelerometer is below
	accelerometer: hw6p3Modified port map(max10_clk => max10_clk, GSENSOR_CS_N => GSENSOR_CS_N, GSENSOR_SCLK => GSENSOR_SCLK, GSENSOR_SDI => GSENSOR_SDI, 
						GSENSOR_SDO => GSENSOR_SDO, dFix => dFix, ledFix => ledFix, hex5 =>hex5,hex4=>hex4,hex3=>hex3,hex2=>hex2,hex1=>hex1,hex0=>hex0,
						data_x=>data_x,data_y=>data_y,data_z=>data_z, datax_toPixelx => datax_toPixelx,
						datay_toPixely => datay_toPixely);
						
	PRGN_1 : PRNG_gtbuckner42 port map(seed => seed, setSeed_asyn => seed_set, clk => pll_OUT_to_vga_controller_IN,
			Psuedo_Random_Num=>Psuedo_Random_Num); 
	PRGN_2 : PRNG_gtbuckner42 port map(seed => seed2, setSeed_asyn => seed_set2, clk => pll_OUT_to_vga_controller_IN,
			Psuedo_Random_Num=>Psuedo_Random_Num2);		
	
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
			score_w => score_w, score_h => score_h, score_spacing => score_spacing, left_score1 => left_score1,
			left_score0 => left_score0, right_score1 => right_score1, right_score0 => right_score0,
			player_L_score => player_L_score, player_R_score => player_R_Score);

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
	NEXT_STATE_LOGIC: process (key1, ball_scored, Current_State) begin
		case Current_State is
			when reset_game => if Key1='0' then Next_State <= volly;
				else Next_State <= reset_game;
				end if;
		when volly => if ball_scored = '1' then Next_State <= update_score_rst_ball;
				else Next_State <= volly;
				end if;
		when update_score_rst_ball => if ball_scored = '1' then Next_State <= update_score_rst_ball;
				else Next_State <= volly; --when score is updated, a process will make ball_score = '0'
				end if;
		when others => Next_State <= reset_game;
		end case;
	end process;
	
	--
	--determine what is needed to happen to make the stuff happen
	OUTPUT_LOGIC:process (Current_State) begin
		case Current_State is
			when reset_game => 
				--reset all the things
				Rst_game <= '1';
			when volly =>
				Rst_game <= '0';
			when others => 
		end case;
	end process;
	
	
	
	---datax_toPixelx: out integer;
	---datay_toPixely: out integer;
	--Need to change this to move only the paddle-4/9/2024
	moveball:process(dispEn)
	  variable ball_x_10000:integer:= 3000000; --in form of (pixels * 10000)
	  variable ball_y_10000:integer:= 2000000;
	  variable ball_x:integer:=ball1_col;
	  variable ball_y:integer:=ball1_row;
	  variable scalarx:integer:= 4;
	  variable scalary:integer:= 4;
	  variable x_inc	:integer:= 0;--in form of (pixels * 10000)
	  variable y_inc  :integer:= 0;--in form of (pixels * 10000)
	  variable RandNum:integer:= 0;
	  variable RandNum2:integer:=0;
	  variable i		:integer:=0;
	  variable j		:integer:=0;
	  variable x_speed_default:integer:=300000;
	 begin
		
		if(rising_edge(dispEN) and current_state = volly) then --calculate stuff while frame is being printed
		
			--if collision then set the direction
			--if set the directin then check for angle
			--want the direction to be 60deg or less
			--so tan(60)*100 = 173
			--SO -> (100|y|)/|x| = 173
			--min val datax_toPixX/Y = 228170134
			--max val = 34225520600 --huge lol
			--needs to be implementd GB 4/10/2024
				RandNum:= to_integer(unsigned(Psuedo_Random_Num(3 downto 0))); --sets random number each frame
				RandNum2:= to_integer(unsigned(Psuedo_Random_Num2(3 downto 0))); --sets random number each frame
				--if(Psuedo_Random_Num(4) = '1') then --I want to set the variable negative if msb is 1 
				--	RandNum:= -1 * RandNum;
				--end if;
				--if(Psuedo_Random_Num2(4) = '1') then --I want to set the variable negative if msb is 1 
				--	RandNum2:= -1 * RandNum;
				--end if;
				
				
				
				--need to se intital direction
				if(rst_game = '1') then
					x_inc := x_speed_default;
					y_inc := (RandNum2 * 1000) mod (173 * x_speed_default); --considering y = randNum2*10000. this makes y a random num
					--that makes the angle less than 60 deg
			
				end if;
				
				--increments the x_y variable by increment amount
				ball_x_10000:= x_inc + ball_x_10000;
				ball_y_10000:= y_inc + ball_y_10000;
			
				--collision handling Need to modify to collide with paddles and bounds and bounce off.
				if(ball_y < 0 or (ball_y + ball_size) > 480) then
					ball_y := ball1_row;
					ball_y_10000:= ball1_row * 10000*scalary; --need to make sure the 'expanded' number is handled too

		       end if;	
				
				if(ball_x < 0 or (ball_x + ball_size) > 640) then
					ball_x:= ball1_col;
					ball_x_10000:=ball1_col * 10000*scalarx;
				end if;			
			
			--ball_x_10000:= datax_toPixelX + ball_x_10000;--in form of (pix/1000frames) + pixles*1000
			--ball_y_10000:= datay_toPixelY + ball_y_10000;--legacy
			
			ball_x:= ball_x_10000/10000/scalarx; --truncated value in form of pixels
			ball_y:= ball_y_10000/10000/scalary; --these are the col and row signals in variable form
			


				
				if(key0 = '0') then --key0 is active low (resets position)
					ball_x:= 320;
					ball_y:= 240;
					ball_x_10000:= 320*10000*scalarX;
					ball_y_10000:= 240*10000*scalary;
				end if;
				
		 end if;
		if(falling_edge(dispEN) and current_state = volly) then ---move ball at end of frame(TEST)
			ball1_col <= ball_x;
			ball1_row <= ball_y;
		end if;
	end process;
	
	move_paddle_LandR:process(dispEN,Rotary_clk)
	variable enable: std_logic:= '1'; --this ensures each click gets registerd once
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
	 
		 
		 if((rotary_clk xor rotary_dt) = '0' and dispEN = '0') then --this resets enable
				enable := '1';
		 end if;
		
		if(Rst_game = '1') then
			Paddle_y := 240;
			--TEST
			Player_L_Score <= 0;
			Player_R_score <= 0;
		end if;
		--TEST
		if(Rst_game = '0') then
			player_L_SCore <= 39;
			Player_R_score <= 56;
		end if;
		
		
		if(falling_edge(dispEN)) then ---move box at end of frame(TEST)
			left_paddle_y <= paddle_y;
			right_paddle_y<= paddle_y;
		--right paddle will eventually be moved by the accelerometer GB4/9/2024
		end if;
		  
		   
	end process;
		
	setSeedHandler:process(pll_out_to_vga_controller_in, seed)-------THIS SETS SEED ON STARTUP OR SEED CHANGE
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
	
	setSeedHandler2:process(pll_out_to_vga_controller_in, seed2)-------THIS SETS SEED ON STARTUP OR SEED CHANGE
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
		
--			movebox:process(dispEn)
--	  variable box_x_10000:integer:= 3000000; --in form of (pixels * 10000)
--	  variable box_y_10000:integer:= 2000000;
--	  variable box_x:integer:=box1_col;
--	  variable box_y:integer:=box1_row;
--	  variable scalarx:integer:= 4;
--	  variable scalary:integer:= 4;
--	 begin
--		
--		if(rising_edge(dispEN)) then --calculate stuff while frame is being printed
--			
--			box_x_10000:= datax_toPixelX + box_x_10000;--in form of (pix/1000frames) + pixles*1000--
--		box_y_10000:= datay_toPixelY + box_y_10000;
--			
--			box_x:= box_x_10000/10000/scalarx; --truncated value in form of pixels
--			box_y:= box_y_10000/10000/scalary; --these are the col and row signals in variable form
--			
--				--collision handling
--				if(box_y < 0 or (box_y + 33) > 480) then
--					box_y := box1_row;
--					box_y_10000:= box1_row * 10000*scalary; --need to make sure the 'expanded' number is handled too--
--
--		       end if;
--				if(box_x < 0 or (box_x + 33) > 640) then
--					box_x:= box1_col;
--					box_x_10000:=box1_col * 10000*scalarx;
--				end if;
--				
--				if(key0 = '0') then --key0 is active low-
--					box_x:= 320;
--					box_y:= 240;
--					box_x_10000:= 320*10000*scalarX;
--					box_y_10000:= 240*10000*scalary;
--				end if;
--				
--		 end if;
--		if(falling_edge(dispEN)) then ---move box at end of frame(TEST)
--			box1_col <= box_x;
--			box1_row <= box_y;
--		end if;
--	end process;
	
end vga_structural;
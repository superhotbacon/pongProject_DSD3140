--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------
--
-- Altered 10/13/19 - Tyler McCormick 
-- Test pattern is now 8 equally spaced 
-- different color vertical bars, from black (left) to white (right)


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use       IEEE.numeric_std.all;

ENTITY hw_image_generator IS
  GENERIC(
    
	col_a : INTEGER := 80;
	col_b : INTEGER := 160;
	col_c : INTEGER := 240;
	col_d : INTEGER := 320;
	col_e : INTEGER := 400;
	col_f : INTEGER := 480;
	col_g : INTEGER := 560;
	col_h : INTEGER := 640

	);  
  PORT(
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
    red      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
	 ball1_col :  in integer;
	 ball1_row :  in integer;
	 ball_size:	  in integer;
	 upper_box:  in integer;
	 lower_box:  in integer;
	 upper_box_h: in integer;--height of box
	 lower_box_h: in integer;
	 Middle_box_w: in integer; --width of middle box
	 Middle_box: in integer; --middle box spawn location x coordinate
	 --the following is for the left and right paddle locations
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
	--spawn locations
	left_score1: 		in integer; --msb of left score spa
	left_score0: 		in integer;--lsb left score
	right_score0:		in integer;
	right_score1:		in integer;
	--actual score values
	player_L_score:	in integer;
	player_R_score:	in integer
	 );
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
	--need to find a way to upscale this image
	--bit maps for the images--will be used for printing.
	TYPE bit_map IS ARRAY (0 to 7, 0 to 7) of std_logic;
	signal img_0: bit_map:= (7 downto 7 => x"3E", 6 downto 6 => x"63", --0
									 5 downto 5 => x"73", 4 downto 4 => x"7B",
									 3 downto 3 =>	x"6F", 2 downto 2 => x"67",
									 1 downto 1 =>	x"3E", 0 downto 0 => x"00");
									 
	signal img_1: bit_map:= (7 downto 7 => x"0C", 6 downto 6 => x"0E", --1
									 5 downto 5 => x"0C", 4 downto 4 => x"0C",
									 3 downto 3 =>	x"0C", 2 downto 2 => x"0C",
									 1 downto 1 =>	x"3F", 0 downto 0 => x"00");
									 
	signal img_2: bit_map:= (7 downto 7 => x"1E", 6 downto 6 => x"33", --2
									 5 downto 5 => x"30", 4 downto 4 => x"1C",
									 3 downto 3 =>	x"06", 2 downto 2 => x"33",
									 1 downto 1 =>	x"3F", 0 downto 0 => x"00");
									 
	signal img_3: bit_map:= (7 downto 7 => x"1E", 6 downto 6 => x"33", --3
									 5 downto 5 => x"30", 4 downto 4 => x"1C",
									 3 downto 3 =>	x"30", 2 downto 2 => x"33",
									 1 downto 1 =>	x"1E", 0 downto 0 => x"00");	
						
	signal img_4: bit_map:= (7 downto 7 => x"38", 6 downto 6 => x"3c", --4
									 5 downto 5 => x"36", 4 downto 4 => x"33",
									 3 downto 3 =>	x"7F", 2 downto 2 => x"30",
									 1 downto 1 =>	x"78", 0 downto 0 => x"00");
						
	signal img_5: bit_map:= (7 downto 7 => x"3f", 6 downto 6 => x"03", --5
									 5 downto 5 => x"1f", 4 downto 4 => x"30",
									 3 downto 3 =>	x"30", 2 downto 2 => x"33",
									 1 downto 1 =>	x"1E", 0 downto 0 => x"00");
						
	signal img_6: bit_map:= (7 downto 7 => x"1c", 6 downto 6 => x"06", --6
									 5 downto 5 => x"03", 4 downto 4 => x"1f",
									 3 downto 3 =>	x"33", 2 downto 2 => x"33",
									 1 downto 1 =>	x"1e", 0 downto 0 => x"00");		

	signal img_7: bit_map:= (7 downto 7 => x"3F", 6 downto 6 => x"33", --7
									 5 downto 5 => x"30", 4 downto 4 => x"18",
									 3 downto 3 =>	x"0c", 2 downto 2 => x"0c",
									 1 downto 1 =>	x"0c", 0 downto 0 => x"00");
									
	signal img_8: bit_map:= (7 downto 7 => x"1e", 6 downto 6 => x"33", --8
									 5 downto 5 => x"33", 4 downto 4 => x"1e",
									 3 downto 3 =>	x"33", 2 downto 2 => x"33",
									 1 downto 1 =>	x"1E", 0 downto 0 => x"00");
									
	signal img_9: bit_map:= (7 downto 7 => x"1E", 6 downto 6 => x"33", --9
									 5 downto 5 => x"33", 4 downto 4 => x"3E",
									 3 downto 3 =>	x"30", 2 downto 2 => x"18",
									 1 downto 1 =>	x"0E", 0 downto 0 => x"00");
									
	TYPE bit_map_array IS ARRAY(9 downto 0) of bit_map;
	signal Score_numbers: bit_map_array:= (9 downto 9 => img_9, 8 downto 8 => img_8,
														7 downto 7 => img_7, 6 downto 6 => img_6, 
														5 downto 5 => img_5, 4 downto 4 => img_4,
														3 downto 3 => img_3, 2 downto 2 => img_2,
														1 downto 1 => img_1, 0 downto 0 => img_0);
														
	--Now I gotta do the giant function for the bitmaps
	function getBitFromMap(column	: integer; --assumption of 8 bit to 32 bit masking (can be changed)
								  row	  	: integer;
								  score_h: integer;
								  score_w: integer;
								  x_bound: integer;
								  y_bound: integer;
								  score  : integer) return std_logic is 
					variable return_bit: std_logic:='0';
	begin
			if(score = 0) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_0(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 1) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_1(i,j) = '1') then --assuming upscale is 4 bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
	
		
			if(score = 2) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_2(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 3) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_3(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 4) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_4(i,j) = '1') then --assuming upscale is 4 bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 5) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_5(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
	
		
			if(score = 6) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_6(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 7) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_7(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 8) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_8(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
		
			if(score = 9) then
				for i in 0 to 7 loop 
					for j in 0 to 7 loop
						if(img_9(i,j) = '1') then --assuming upscale is score_w bits per 1 bit of image
							if((column) >= x_bound + (score_w*(8-j)) and column < x_bound + (8-j+1)*score_w and row >= y_bound + (score_h*(8-i)) and row < y_bound + (score_h*(8-i+1))) then-- THIS DETERMINES HOW MANY TIMES PIXLE FROM BIT MAP GETS REPEATED
								return_bit := '1';
							end if;
						end if;
					end loop;--inner loop
				end loop;--outer loop
			end if;
		
	 return return_bit;
	end function;		  
								  
									 
	signal color: std_logic_vector(11 downto 0):= (others => '1');
	signal score_y: integer:= 80;
	

BEGIN

  PROCESS(disp_ena, row, column)
  variable RGB: std_logic_vector(11 downto 0):= color;
  variable i: integer:= 0;
  BEGIN
    IF(disp_ena = '1') THEN        --display timeRGB := std_logic_vector(to_unsigned(column + (640*2), RGB'length));
		RGB:= (others=> '0');--sets screen to black

		------>THE ORDER IN WHICH THE IF STATEMENTS APPER DETERMINE THE LAYERING OF THE DISPLAY. 
		------>THE MORE "LATTER" THE IF STATEMENT, THE MORE PRIORITY IT HAS OF "PREVIOUS" STATEMETNS
		
		
		
		
		
		--making static elements
		if(row >= upper_box and row < upper_box + upper_box_h) and (column > 20 and column < (640 - 20)) then
			RGB:= (others => '1');
		end if;
		
		if(row >= lower_box and row < lower_box + lower_box_h) and (column > 20 and column < (640 - 20)) then
			RGB:= (others => '1');
		end if;
		
		--printing perforated line
		if(column >= Middle_box and column < Middle_box + Middle_box_w) and (row > upper_box + upper_box_h
			and row < lower_box-3 ) then --the minus 15 chops off the last incomplete perforated square
			 
				--logic to make the preforated line start after top box
				--the - upper_box - upper_box_h is the offset so that the modulus starts at 0 where
				--I want the line to start
				--I suspect the following if statement could be modified if Logic elements needs to reduced
				if((row - upper_box - upper_box_h) mod 15 > 5) then		
					RGB:= (others => '1');
					end if;
		end if;
		

		
		--now for the color blocks
		--for the leftmost score box
		if(column >= left_score1 and column < (left_score1 + 32)) and (row >= score_y and row < score_y + 32) then
			RGB:= (others => '0'); --draws background behind the numbers
			if(getBitFromMap(x_bound =>left_score1, y_bound => score_y, column => column, row => row, 
				score =>Player_L_score/10,score_w =>score_w, score_h => score_h) = '1') then
				RGB:= (others => '1');
			end if;
		end if;
		
		if(column >= left_score0 and column < (left_score0 + 32)) and (row >= score_y and row < score_y + 32) then
			RGB:= (others => '0');	
			if(getBitFromMap(x_bound =>left_score0, y_bound => score_y, column => column, row => row, 
				score =>Player_L_score mod 10, score_w =>score_w, score_h => score_h) = '1') then
				RGB:=(others => '1');
			end if;
		end if;
		
		if(column >= right_score1 and column < (right_score1 + 32)) and (row >= score_y and row < score_y + 32) then
			RGB:= (others => '0');
			if(getBitFromMap(x_bound => right_score1, y_bound => score_y, column => column, row => row, 
				score =>Player_R_score/10, score_w =>score_w, score_h => score_h) = '1') then
				RGB:=(others => '1');	
			end if;
		end if;
		
		if(column >= right_score0 and column < (right_score0 + 32)) and (row >= score_y and row < score_y + 32) then
			RGB:= (others => '0');	
			if(getBitFromMap(x_bound => right_score0, y_bound => score_y, column => column, row => row, 
				score =>Player_R_score mod 10, score_w =>score_w, score_h => score_h) = '1') then
				RGB:=(others => '1');
			end if;
		end if;
		
		

		
		
		--MAKING THE PADDLES
		if(column >= right_paddle_x and column < right_paddle_x + paddle_width) and (row >= right_paddle_y and row < right_paddle_y + paddle_height) then
			RGB:= (others=>'1');
		end if;
		
		if(column >= left_paddle_x and column < left_paddle_x + paddle_width) and (row >= left_paddle_y and row < left_paddle_y + paddle_height) then
			RGB:= (others=>'1');
		end if;	
	
			--this if statement sets ball
		if (row >= ball1_row and row < ball1_row + ball_size) and (column >= ball1_col and column < ball1_col + ball_size) then
			RGB:= "101100001111";
		end if;
		
		red(3 downto 0) <= RGB(11 downto 8);
		green(3 downto 0) <= RGB(7 downto 4);
		blue(3 downto 0) <= RGB(3 downto 0);

    ELSE                           --blanking time
      red <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue <= (OTHERS => '0');
    END IF;
  
  END PROCESS;
END behavior;

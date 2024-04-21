TEAM: Gabriel Buckner and Brennan Angus


Our team did the option to make pong2 and pong2a and pong2b.

The project files for each iteration can be found in the respective "pong2X" folders. There are also files in the main directory to program the flash memory of the DE10-lite. 

Within each project folder, the top level entities are titled PE2_gtbuckner42. The actual project file ("X.qsf") is titled "pong2X.qsf" for each version respectively. The output files in each of these directories have been removed for storage purposes. Most of the componenets for each version are in the top level project folder. However, some of the components can be found in a file called "Components". All of the Plls and others .qsys files can be found in the top level project folder as well.

The programing file is titled "FinalProjeect_pong2andPong2b.pof" This file can be uploaded to the DE10-lite. The base game will loaded into the first position and the improved pong (pong2b_ will be loaded into the second flash position. The board will default to the base game on powerup. Pong2b can be accesed by shorting JP5 to power with a jumper wire and then powering on the board.

I added some extra functionality to all of the projects. For every version of the project, Key1 has to be pressed in order to start a 'round'. Upon startup and game reset, the paddles cannot be moved until the first volly has been started. This is intentional. In every version of the game, the ball will speed up slightly every hit to make the game more enjoable. Each round will start the ball moving towards the right paddle at a random angle. There is also english added to every version of the game to make a pleasent user experience. In every version of the game, key1 can be pressed to start the next game after a play reaches 11 ponts. In pong2b, we added functionality that changes the color of the screen randomly every round. I found this to be very colorful and interesting. Upon hitting the ball 14 times back and fourth, the game will gradually fade from red to purple to show the intensity! The maximum speed of the ball is also increased in this version! There is also an on screen scoreboard in Pong2b. It works really well and is very nice looking. The accelerometer controls the right paddle in this version. A buzzer also needs to be added between ArduinoIO[12] and GND. This will play sound effects.


TO PLAY PONG!
PONG2 -- wire up two rotary encoders to ground and vcc. Hook up RE1 CLK and DT signals to ArduinoIO[7] and ArduinoIO[6] respectively. Hook up RE2 to CLK and DT to ArduinoIO[1] and ArduinoIO[0]. RE1 controls the left paddle and RE2 controls the right. Press key1 to start the game, press Key0 to restart the game. The game will continue until a player gets 11 points, the game will start from 0:0 if key1 is pressed again.

PONG1 -- wire up 1 rotary encoder to ground and vcc. Hook up RE1 CLK and DT signals to ArduinoIO[7] and ArduinoIO[6] respectively. The RE will control the left paddle, the on board accelerometer will control the right paddle. Connect a Piezoelectric buzzer between ArduinoIO[12] and GND. Press key1 to start the game, press Key0 to restart the game. The game will continue until a player gets 11 points, the game will start from 0:0 if key1 is pressed again. The colors will change after 14 hits! The color will also change every round.
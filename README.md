# ECE540_FinalProject_Car_Racing
Car racing game with 3 lanes and 4 levels

1) Introduction: Welcome to our exciting project in the world of gaming! We've created a 2D arcade car racing game using SystemVerilog and C, with the help of Nexys A7 DDR FPGA and Catapult Studio.
In this game, you control a single car using FPGA push buttons. Your mission is simple: navigate through levels, avoid other cars, and try to conquer all four levels.
Our project showcases the synergy between hardware and software for a fun gaming experience.

2) ![image](https://github.com/GayatriVemuri/ECE540_FinalProject_Car_Racing/assets/104589505/ecf162b9-4c14-4761-bb01-ac2eddeb67ba)

3) Design Workflow
   
3.1) Road: It receives the current pixel coordinates (pix_row, pix_col) from dtg. The
code then utilizes modules responsible for rendering the white lines and the track to
compose a dynamic image that simulates road movement from the top to the bottom of
the screen. The speed of this moving road image can be varied by altering the 'level'
input, which adjusts the image scroll rate to simulate different speeds. The resulting road
image is a composite of the side ground alongside the track, the central roadway, and
the white lane markings. For each specific pixel location, the code outputs a 12-bit value
that corresponds to the visual content of the road at that point, ensuring that the
appropriate road imagery is displayed on the screen at the right time.

3.1.1) White Lines: It takes the current pixel location (pix_row, pix_col) from
dtg as inputs. It takes start and end points for the white lines according to row and
column. Takes 12-bit track color as input because if there is no white line to output. It will
output the track color as required. It outputs 12 bit value from the white lines at a
specified pixel location and if we don't need white lines it will output the track value we
got as input.

3.1.2) Track: This module creates a template for the road image. It takes the
current pixel location (pix_row, pix_col) from dtg as inputs. Takes 2-bit level value as
input which is given by the Moving Cars module. We have a total 4 levels 00 - level 1, 01
- 2, 10 - 3, 11 - 4. It outputs 12-bit value of track color at a specified pixel location.
  
3.2) Player Car: It utilizes the starting X (column) and Y (row) coordinates of the car's
image cell to calculate the relative index by subtracting these starting points from the
current pixel coordinates. This relative index is used to determine if the current pixel falls
within the boundaries of the car's image cell, which is defined to be 32 pixels in width (X
index range 0-31) and 64 pixels in height (Y index range 0-63). If the pixel is within this
cell, the routine fetches the corresponding 12-bit color value for the red car image from
the read-only memory (ROM) instance and outputs this value. If the pixel lies outside the
car's image cell, the routine outputs a value corresponding to black, effectively rendering
the car image onto the background at the specified location.

3.3) Moving Cars: This module processes pixel location inputs (pix_row, pix_col)
from dtg to control the movement of four cars. These cars are programmed to move
vertically from top to bottom on the screen, with a delay incorporated to create realistic
motion. For visual rendering, the module outputs a 12-bit color value for the car image at
each pixel location; where there is no car, it outputs BLACK.

3.4) You Win: Takes score from the moving cars module. It outputs a 12-bit value for
the “you win” image and the “you win” flag.

3.5) Game Over: Takes output of moving cars and player car as input to check for
collisions. It outputs a 12-bit value for game over image and game over flag.

3.6) Combine: Takes 12 bits value of road_out, player_car_out, moving_car,
you_win, game_over and checks at a given pixel location which should be outputted. It
outputs the 12-bit value of the desired value at a specified pixel location.

3.7) DTG: This module generates the pixel row, pixel column, and the sync pulses for
the VGA display. This module was referenced from the Project 1 and 2 modules. This
module is for a 640x480 resolution display.

3.8) VGA: It outlines the VGA signal generation, interfacing with various game
components through a WISHBONE bus interface. The module is parameterized for
flexibility and integrates several sub-modules, including dtg_top for display timing
generation, Road_Top for road rendering, Player_Car_Top for player car positioning
and movement, Moving_Cars_Top for managing non-player character vehicles, and
You_Win_Top and Game_Over_Top for determining win and lose conditions.
Furthermore, the Combine_Top module is used to merge the graphical output from
different game modules into a single VGA output signal. This module represents the
hardware's role in synthesizing complex video signals to render the game graphics on a
display, indicating the system's ability to handle real-time video processing as part of the
gaming experience.

3.9) GPIO Push Buttons: The GPIO peripheral is used to control the player car
through the 5 programmable buttons available on the board. We used BTNL, BTNR, and
BTNU for moving the car left, right, and reset respectively. It is interfaced with firmware
which signals if the buttons are pressed through their specific memory-mapped register
addresses.

3.10) Firmware: The code sets up GPIO2 for reading button inputs and writes to
VGA addresses to update the car's position on the display.The main logic in an infinite
loop checks the state of the left (BTNL) and right (BTNR) buttons. If either button is
pressed, it adjusts the car's horizontal position accordingly, ensuring the car does not
exceed predefined lane boundaries. It uses a delay_counter function to introduce a
delay between each loop iteration, which can be a simple way to control the speed of the
car's movement. The car's position is updated by writing to the VGA_ROW_COL
address, and the loop continuously checks for button presses to either move the car left
or right or keep it stationary if no buttons are pressed.

4) Game Logic Descriptions

4.1) Collisions: The process involves comparing the RGB values of the player's car
with those of the moving car. If the RGB values match and fall within the range that is neither
black nor white, a collision is detected. Upon this detection, a collision flag is set, which triggers
the termination of the game.

4.2) Movement:

4.2.1) Track: In the game's display logic, white lines are rendered at specified
pixel row and column locations to simulate road markings. To create an illusion of forward
motion, the positions of these white lines are incrementally shifted by adding 8 units to their
current location. This subtle yet continuous adjustment makes the lines appear as though they
are advancing. When these white lines reach the end of their designated path, they seamlessly
loop back to their original starting point, ensuring a continuous flow. This dynamic is applied to a
total of five white lines, contributing to the realistic depiction of a moving road in the game.

4.2.2) Car: Starting from its initial horizontal position, the car in the game
smoothly transitions across the screen by moving 8 pixels at a time. This movement is paced
with a deliberate delay set at 10,000 cycles, ensuring that the car's motion appears smooth and
continuous. Additionally, the game incorporates track boundaries that prevent the car from
veering off the track, maintaining realistic gameplay and enhancing the player's experience.

4.3) Displaying Car Icon: The car icon is rendered based on its X (horizontal) and
Y (vertical) starting coordinates. For each screen pixel, the module calculates its relative
position to these coordinates and renders the car's image pixel-by-pixel within its defined
dimensions, dynamically displaying the car icon on the screen.

4.4) Levels: The game's speed escalates through four distinct levels, determined by
the number of cars that surpass the screen. If 10 cars pass, we change from level 1 to level 2,
more 10 cars for level 2 to level 3, 15 cars from level 3 to level 4, and then 20 cars to win the
game.

![image](https://github.com/GayatriVemuri/ECE540_FinalProject_Car_Racing/assets/104589505/38d988d9-b97b-4a91-9914-6e35e5032393)


Conclusion
We have successfully completed most of all our originally planned design features as
mentioned in our project proposal document, and we succeeded in making a very
entertaining game with the potential for a lot of additional gameplay features, such as
audio effects, additional levels, a variety incoming cars and player icon cars.

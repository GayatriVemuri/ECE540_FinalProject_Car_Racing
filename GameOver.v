////////////////////////////////////////////////////////////////////////////
//
// GameOver.v - Game_Over_Top module for ECE 540 Final Project
// 
// Author:  Gayatri Vemuri (gayatri@pdx.edu), Sahil Khan (sahilk@pdx.edu), Viraj Pashte (vpashte@pdx.edu)
// Date: 12/06/2023
//
// Description:
// ------------
// It takes current pixel location (pix_row, pix_col) from dtg as inputs.
// Takes output of moving cars and player car as input to check for collision.
// It outputs 12 bit value for game over image and game over flag.
// 
////////////////////////////////////////////////////////////////////////////

module Game_Over_Top (
    input wire clk,
    input wire [9:0]    pix_row, pix_col,        // current pixel being display on screen
    input wire [11:0] 	moving_cars_in,          // moving cars output
    input wire [11:0]	player_car_in,           // player car output
    output reg          collosion_flag,          // collision flag set if collision occurs
    output reg [11:0]   game_over_out            // game over image out

);

reg [12:0] game_over_addr;		    // need 13 bits because our image is 128x64 = 8192 (13 bits)
                                    // 4 bits for each color
wire [3:0] pixel_dout_red;
wire [3:0] pixel_dout_blue;
wire [3:0] pixel_dout_green;
wire [11:0] game_out;

// Game over image position start points
reg [9:0] start_x = 255;	// location x start point
reg [9:0] start_y = 207;	// location y start point
reg [9:0] index_x, index_y;
reg [9:0] index_x, index_y;
reg [1:0] myFlag = 1'b0;

parameter WHITE = 12'b111111111111;
parameter BLACK = 12'b000000000000;

// ROM instance
game_over_red_mem game_over_red (
  .clka(clk),               // input wire clka
  .addra(game_over_addr),   // input wire [12 : 0] addra
  .douta(pixel_dout_red)    // output wire [3 : 0] douta
);

game_over_blue_mem game_over_blue (
  .clka(clk),               // input wire clka
  .addra(game_over_addr),   // input wire [12 : 0] addra
  .douta(pixel_dout_blue)   // output wire [3 : 0] douta
);

game_over_green_mem game_over_green (
  .clka(clk),               // input wire clka
  .addra(game_over_addr),   // input wire [12 : 0] addra
  .douta(pixel_dout_green)  // output wire [3 : 0] douta
);

// getting the x & y coordinates to position in ROM
/* 	In begining we might get negative values until we reach the 
	start points of X and Y. After our current pixel value reachs 
	the start point of image we will start getting positive values.
	That's when we need to start outputting our car image on screen.
*/
always @(posedge clk) begin
	index_x <= pix_col - start_x;
	index_y <= pix_row - start_y;
end

// Collision logic
always @(posedge clk) begin
	// if player_car and moving_car both are outputting color that means the cars have crashed.
	if ((player_car_in > BLACK && player_car_in  < WHITE ) && (moving_cars_in > BLACK && moving_cars_in < WHITE)) begin
        collosion_flag <= 1'b1;
         myFlag <= 1'b1;		// set collision flag to 1 if crashed
    end
    else begin
		collosion_flag <= 1'b0;		// else set to 0
    end
end

always @(posedge clk) begin
    if(myFlag) begin		// if collision flag is set and image in cell
        if ((index_x >= 0 && index_x < 128) && (index_y >= 0 && index_y < 64)) begin
            game_over_addr <= {index_y[5:0], index_x[6:0]};     // 128x64 - 8192 (13 bits)
            game_over_out <= game_out;							// output concatenated image
        end
    else begin
        game_over_out <= BLACK;									// else output BLACK
        end
    end
end

// Concatenate all colors
assign game_out = {pixel_dout_blue[3:0], pixel_dout_green[3:0], pixel_dout_red[3:0]};

endmodule

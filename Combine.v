//////////////////////////////////////////////////////////////////////////
//
// Combine.v - Combine_Top module for ECE 540 Final Project
// 
// Author: 	Gayatri Vemuri (gayatri@pdx.edu)
// Date: 	12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pix_row, pix_col) from dtg as inputs
// Takes 12 bits value of road_out, player_car_out and checks at a given 
// pixel location which should be outputted.
// It outputs 12 bit value of the desired value at a specified pixel location.
// 
///////////////////////////////////////////////////////////////////////////


`timescale  1 ns / 1 ps

module Combine_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,		// current pixel being display on screen
	input wire 			video_on,		// getting from dtg module
	input wire [11:0]	road_in,			// Road value
	input wire [11:0]	player_car_in,		 	// Player car
	input wire [11:0]   moving_cars_in,      		// moving cars
	input wire [11:0]   you_win_in,          		// you_win output
	input wire          win_reset_flag,			// it tells if the game is ened by winning
	input wire [11:0]   game_over_in,        		// game over output
	input wire          game_over_flag,			// indicates game ended by a collision
	output reg [11:0] 	vga_out				// muxed output sent to the vga output port
);


// Color intensity parameter
parameter BLACK = 12'b000000000000;
parameter WHITE	= 12'b111111111111;

// Flags which indicates what needs to be outputted.
reg player_car_set;
reg moving_cars_set;
reg reset_win = 1'b0;
reg game_over_set = 1'b0;

// Game over flag set
always @(posedge clk) begin
    if(game_over_flag) begin
        game_over_set <= 1'b1;
    end
end

// You win flag set
always @(posedge clk) begin
    if (win_reset_flag) begin
        reset_win <= 1'b1;
    end
end

// Player car
always @(posedge clk) begin
	if(player_car_in > BLACK && player_car_in < WHITE) begin	// car module generating a colour other than white or black
		player_car_set <= 1'b1;
	end
	else begin
		player_car_set <= 1'b0;
	end
end

// Moving cars
always @(posedge clk) begin
	if(moving_cars_in > BLACK && moving_cars_in < WHITE) begin	// car module generating a colour other than white or black
		moving_cars_set <= 1'b1;
	end
	else begin
		moving_cars_set <= 1'b0;
	end
end


// if video ON send the color to vga else BLACK to vga
always @(posedge clk) begin
	if (video_on) begin
	   if (game_over_set) begin			// If collision occured
	       vga_out <= game_over_in;
	   end
	   else if (reset_win) begin			// If game ended with you winning
	       vga_out <= you_win_in;
        end
		else if (player_car_set) begin         	// player car on screen
			vga_out <= player_car_in;
		end
		else if (moving_cars_set) begin   	// moving car on screen
			vga_out <= moving_cars_in;
		end
		else begin
			vga_out <= road_in;		// show road/whole screen image
		end
    end
    else begin
		vga_out <= BLACK;			// BLACK if video OFF.
	end
end	

endmodule

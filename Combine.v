//////////////////////////////////////////////////////////////////////////
//
// Combine.v - Combine_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs
// Takes 12 bits value of road_out, player_car_out and checks at a given 
// pixel location which should be outputted.
// It outputs 12 bit value of the desired value at a specified pixel location.
// 
///////////////////////////////////////////////////////////////////////////


`timescale  1 ns / 1 ps

module Combine_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,
	input wire 			video_on,
	input wire [11:0]	road_in,			  // Road value
	input wire [11:0]	player_car_in,		 // Player car
	input wire [11:0]   moving_cars_in,      // moving cars
	input wire [11:0]   you_win_in,          // you win
	input wire          win_reset_flag,
	output reg [11:0] 	vga_out
);

parameter BLACK = 12'b000000000000;
parameter WHITE	= 12'b111111111111;

reg player_car_set;
reg moving_cars_set;
reg reset_win = 1'b0;

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

/*
always @(posedge clk) begin
    if (video_on && win_reset_flag) begin
        reset_win <= 1'b1;
    end
end
*/
// if video ON send the color to vga
always @(posedge clk) begin
	if (video_on) begin
	   /*if (reset_win) begin
	       vga_out <= you_win_in;
        end
		else */if (player_car_set) begin         // player car
			vga_out <= player_car_in;
		end
		else if (moving_cars_set) begin   // moving car
			vga_out <= moving_cars_in;
		end
		else begin
			vga_out <= road_in;
		end
    end
    else begin
		vga_out <= BLACK;
	end
end	

endmodule

/////////////////////////////////////////////////////////////////////////////////////
//
// DodgeCar.v - Dodge_Car_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs.
// It also takes X, Y coordinates (starting point) of the car.
// It outputs 12 bit value of car image at a specified pixel location else BLACK.
// 
////////////////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps

module Dodge_Car_Top (
	input wire 			clk, enable,
	input wire [9:0]	pix_row, pix_col,
	input wire [9:0]	car_x, car_y,
	output reg [11:0]	dodge_car_out
);

reg  [10:0] car_addr;
wire [11:0] car_out;
wire [3:0] 	pixel_dout_red;
wire [3:0] 	pixel_dout_blue;
wire [3:0] 	pixel_dout_green;

// Index calculation
reg [9:0] index_x, index_y;

parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;

// ROM for car image
red_car_red_mem red_car_red (
  .clka(clk),               // input wire clka
  .addra(car_addr),         // input wire [10 : 0] addra
  .douta(pixel_dout_red)    // output wire [3 : 0] douta
);

red_car_blue_mem red_car_blue (
  .clka(clk),               // input wire clka
  .addra(car_addr),         // input wire [10 : 0] addra
  .douta(pixel_dout_blue)    // output wire [3 : 0] douta
);

red_car_green_mem red_car_green (
  .clka(clk),               // input wire clka
  .addra(car_addr),         // input wire [10 : 0] addra
  .douta(pixel_dout_green)    // output wire [3 : 0] douta
);

// getting the x & y coordinates to position in ROM
always @(posedge clk) begin
	index_x <= pix_col - car_x;
	index_y <= pix_row - car_y;
end

// Printing car mage when in boundary or else Black out.
always @(posedge clk) begin
	// 32 x 64 image (64 rows & 32 columns)
	if(enable && (index_x >= 0 && index_x < 32) && (index_y >= 0 && index_y < 64)) begin
		car_addr <= {index_y[5:0], index_x[4:0]};
		dodge_car_out <= car_out;
    end
    else begin
        dodge_car_out <= BLACK;
    end   
end        

// Concatenate all colors
assign car_out = {pixel_dout_blue[3:0], pixel_dout_green[3:0], pixel_dout_red[3:0]};

endmodule

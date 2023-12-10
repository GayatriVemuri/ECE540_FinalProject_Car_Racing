/////////////////////////////////////////////////////////////////////////////////////
//
// PlayerCar.v - Player_Car_Top module for ECE 540 Final Project
// 
// Author: 	Gayatri Vemuri (gayatri@pdx.edu),Sahil Khan (sahilk@pdx.edu)
// Date: 	12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pix_row, pix_col) from dtg as inputs
// Takes the X (column start) and Y (row start) points for the car cell.
// As we have the starting points for our image we subtract that point with current
// pixel row and column to get the index value. If the X and Y index value lies inside
// our cell we output the car image which we get from the ROM instance.
// Our cell size is 32 x 64 where X index should be between 0-32 and Y between 0 - 64.
// It outputs 12 bit value of red car image at a specified pixel location else black.
// 
////////////////////////////////////////////////////////////////////////////////////////


`timescale  1 ns / 1 ps


module Player_Car_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,		// current pixel being display on screen
	input wire [9:0]    car_yellowX, car_yellowY,		// starting X and Y points
	output reg [11:0]	player_car_out			// player car output
);	


// internal reg and wires
reg [10:0] car_yellow_addr;		// need 11 bits because our image is 32x64 = 2048 (11 bits)
wire [11:0] car_yellow_out;
// 4 bits for each color
wire [3:0] pixel_dout_red;
wire [3:0] pixel_dout_blue;
wire [3:0] pixel_dout_green;

// Car position start point
reg [9:0] car_x;     			// location x start point
reg [9:0] car_y;     			// location y start point 
reg [9:0] index_yellowX, index_yellowY;

// Color intensity parameter
parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;


always @(posedge clk) begin
    car_x <= car_yellowX;
    car_y <= car_yellowY;
end

// Getting the output from block memory  RED car
red_car_red_mem car_red_red (
    .clka(clk),    		// input wire clka
    .addra(car_yellow_addr),  	// input wire [10 : 0] addra
    .douta(pixel_dout_red)  	// output wire [3 : 0] douta
);

red_car_green_mem car_red_green (
    .clka(clk),    		// input wire clka
    .addra(car_yellow_addr),  	// input wire [10 : 0] addra
    .douta(pixel_dout_green)  	// output wire [3 : 0] douta
);

red_car_blue_mem car_red_blue (
    .clka(clk),    		// input wire clka
    .addra(car_yellow_addr),  	// input wire [10 : 0] addra
    .douta(pixel_dout_blue)  	// output wire [3 : 0] douta
);


// getting the x & y coordinates to position in ROM
/* 	In begining we might get negative values until we reach the 
	start points of X and Y. After our current pixel value reachs 
	the start point of image we will start getting positive values.
	That's when we need to start outputting our car image on screen.
*/
always @(posedge clk) begin
    index_yellowX <= pix_col - car_x;
    index_yellowY <= pix_row - car_y;
end

// Printing car image when in boundary or else Black out.
always @(posedge clk) begin
	// checking is the index value lies inside the cell.
    if((index_yellowX >= 0 && index_yellowX < 32) && (index_yellowY >= 0 && index_yellowY < 64)) begin
        car_yellow_addr <= {index_yellowY[5:0], index_yellowX[4:0]};		// 32 x 64 image (64 rows & 32 columns)
        player_car_out <= car_yellow_out;					// Concatenated color value to output
    end
    else begin
        player_car_out <= BLACK;						// BLACK if current pixel location not in cell.
    end   
end

// Concatenate RGB values from the ROM into 12 bits.
assign car_yellow_out = {pixel_dout_blue[3:0], pixel_dout_green[3:0], pixel_dout_red[3:0]};

endmodule

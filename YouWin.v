////////////////////////////////////////////////////////////////////////////
//
// YouWin.v - You_Win_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/05/2023
//
// Description:
// ------------
// It takes current pixel location (pix_row, pix_col) from dtg as inputs.
// Takes score from the moving cars module.
// It outputs 12 bit value for you win image and you win flag.
// 
////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps

module You_Win_Top (
	input wire 		clk,
	input wire [9:0]	pix_row, pix_col,
	input wire [5:0]	score_in,
	output reg 		win_reset_flag,
	output reg [11:0]	you_win_out
);

parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;

reg [12:0] 	win_addr;   		// need 13 bits because our image is 128x64 = 8192 (13 bits)
wire [11:0]	 win_out;
// 4 bits for each color
wire [3:0] 	pixel_dout_red;
wire [3:0] 	pixel_dout_green;
wire [3:0] 	pixel_dout_blue;

// You win image position start points
reg [9:0] win_x = 255;     // location x start point
reg [9:0] win_y = 207;     // location y start point 
reg [9:0] index_x, index_y;


// ROM for you win image
you_win_red_mem you_win_red (
  .clka(clk),    		// input wire clka
  .addra(win_addr),  		// input wire [12 : 0] addra
  .douta(pixel_dout_red)  	// output wire [3 : 0] douta
);

you_win_blue_mem you_win_blue (
  .clka(clk),    		// input wire clka
  .addra(win_addr),  		// input wire [12 : 0] addra
  .douta(pixel_dout_blue)  	// output wire [3 : 0] douta
);

you_win_green_mem you_win_green (
  .clka(clk),    		// input wire clka
  .addra(win_addr),  		// input wire [12 : 0] addra
  .douta(pixel_dout_green)  	// output wire [3 : 0] douta
);


// getting the x & y coordinates to position in ROM
/* 	In begining we might get negative values until we reach the 
	start points of X and Y. After our current pixel value reachs 
	the start point of image we will start getting positive values.
	That's when we need to start outputting our car image on screen.
*/
always @(posedge clk) begin
	index_x <= pix_col - win_x;
	index_y <= pix_row - win_y;
end

always @(posedge clk) begin
	if (score_in == 50) begin		// if score reaches 50 
		win_reset_flag <= 1'b1;		// set you win flag 1 else
	end
	else begin
		win_reset_flag <= 1'b0;		// set you win flag 0
	end
end

// Printing you win image when in boundary or else Black out.
always @(posedge clk) begin
	// checking is the index value lies inside the cell.
	if ((index_x >= 0 && index_x < 128) && (index_y >= 0 && index_y < 64)) begin
		win_addr <= {index_y[5:0], index_x[6:0]};     	// 128x64 - 8192 (13 bits)
		you_win_out <= win_out;							// concatenated value to output
    end
    else begin
        you_win_out <= BLACK;								// else BLACK output
    end
end

// Concatenate all colors
assign win_out = {pixel_dout_blue[3:0], pixel_dout_green[3:0], pixel_dout_red[3:0]};

endmodule

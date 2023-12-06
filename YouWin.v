/////////////////////////////////////////////////////////////////////////////////////
//
// YouWin.v - You_Win_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/05/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs.
// It outputs 12 bit value for you win.
// 
////////////////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps

module You_Win_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,
	input wire [5:0]	score_in,
	output reg 			win_reset_flag,
	output reg [11:0]	you_win_out
);

parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;

reg [10:0] 	win_addr;
wire [11:0] win_out;
wire [3:0] 	pixel_dout_red;
wire [3:0] 	pixel_dout_blue;
wire [3:0] 	pixel_dout_green;

// You win image position start points
reg [9:0] win_x;     // location x start point
reg [9:0] win_y;     // location y start point 
reg [9:0] index_x, index_y;


// ROM for you win image



// getting the x & y coordinates to position in ROM
always @(posedge clk) begin
	index_x <= pix_col - win_x;
	index_y <= pix_row - win_y;
end

always @(posedge clk) begin
	if (score_in == 40) begin
		win_reset_flag <= 1'b1;
	end
	else begin
		win_reset_flag <= 1'b0;
	end
end

// Printing you win image when in boundary or else Black out.
always @(posedge clk) begin
	// 32 x 64 image (64 rows & 32 columns)
	/*if ((index_x >= 0 && index_x < 32) && (index_y >= 0 && index_y < 64)) begin
		win_addr <= {index_y[5:0], index_x[4:0]};
		you_win_out <= win_out;
    end
    else begin
        you_win_out <= BLACK;
    end
    */
    you_win_out <= BLACK;
end

// Concatenate all colors
//assign win_out = {pixel_dout_blue[3:0], pixel_dout_green[3:0], pixel_dout_red[3:0]};

endmodule

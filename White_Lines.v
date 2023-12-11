//////////////////////////////////////////////////////////////////////////////////////////
//
// White_lines.v - White_lines_Top module for ECE 540 Final Project
// 
// Author: 	Gayatri Vemuri (gayatri@pdx.edu)
// Date: 	12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pix_row, pix_col) from dtg as inputs
// Takes start and end points for the white lines according to row and column.
// Takes 12 bit track color as input because if there is no white line to output
// it will output the track color as required.
// It outputs 12 bit value fro the white lines at a specified pixel location and
// if we don't need white lines it will output the track value which we got as input.
// 
///////////////////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps


module White_Lines_Top(
	input wire			clk,
	input wire [9:0]	pix_row, pix_col,		// current pixel being display on screen
	input wire [11:0]	track_color,			// track output from Track module
	input wire [9:0]	line1_r_start,			// white line 1 row start location
	input wire [9:0]	line1_r_end,			// white line 1 row end location
	input wire [9:0]	line2_r_start,			// white line 2 row start location
	input wire [9:0]	line2_r_end,			// white line 2 row end location
	input wire [9:0]	line3_r_start,			// white line 3 row start location
	input wire [9:0]	line3_r_end,			// white line 3 row end location
	input wire [9:0]	line4_r_start,			// white line 4 row start location
	input wire [9:0]	line4_r_end,			// white line 4 row end location
	input wire [9:0]	line5_r_start,			// white line 5 row start location
	input wire [9:0]	line5_r_end,			// white line 5 row end location
	input wire [9:0]	line6_r_start,			// white line 6 row start location
	input wire [9:0]	line6_r_end,			// white line 6 row end location
	input wire [9:0]	line_c1_start,			// white line 1 column start location
	input wire [9:0]	line_c1_end,			// white line 1 column end location
	input wire [9:0]	line_c2_start,			// white line 2 column start location
	input wire [9:0]	line_c2_end,			// white line 2 column end location
	output reg [11:0]	white_lines_out			// 12-bit output for white lines
);


// Color intensity parameter
parameter BLACK = 12'b000000000000;
parameter WHITE	= 12'b111111111111;


// Checking for white lines positions
always @(posedge clk) begin
	// when displaying locations matches display white lines location
	// In the if() condition we are checking for the boundary where the white lines need to be outputted.
	// If our current pixel location falls in that boundary we are outputting WHITE as output 
	// or else track color according to the condition.
	
	// Line 1
	if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line1_r_start && pix_row <= line1_r_end)) begin
		white_lines_out <= WHITE;		// display white line (i.e. send white color as output to Road module)
	end
	// Line 2
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line2_r_start && pix_row <= line2_r_end)) begin
		white_lines_out <= WHITE;		// display white line (i.e. send white color as output to Road module)
	end
	// Line 3
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line3_r_start && pix_row <= line3_r_end)) begin
		white_lines_out <= WHITE;		// display white line (i.e. send white color as output to Road module)
	end
	// Line 4
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line4_r_start && pix_row <= line4_r_end)) begin
		white_lines_out <= WHITE;		// display white line (i.e. send white color as output to Road module)
	end
	// Line 5
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line5_r_start && pix_row <= line5_r_end)) begin
		white_lines_out <= WHITE;		// display white line (i.e. send white color as output to Road module)
	end
	// Line 6
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line6_r_start && pix_row <= line6_r_end)) begin
		white_lines_out <= WHITE;		// display white line (i.e. send white color as output to Road module)
	end
	// display track color if not white lines
	else if ((pix_col >= 0 && pix_col <= 639) && (pix_row >= 0 && pix_row <= 479)) begin
		white_lines_out <= track_color;		// display track (i.e. send track as output to Road module)
	end
	// display BLACK if no match found
	else begin
		white_lines_out <= BLACK;
    end
end

endmodule

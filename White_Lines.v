//////////////////////////////////////////////////////////////////////////
//
// White_lines.v - White_lines_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs
// It outputs 12 bit value of track at a specified pixel location.
// 
///////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps


module White_Lines_Top(
	input wire			clk,
	input wire [9:0]	pix_row, pix_col,
	input wire [11:0]	track_color,
	input wire [9:0]	line1_r_start,
	input wire [9:0]	line1_r_end,
	input wire [9:0]	line2_r_start,
	input wire [9:0]	line2_r_end,
	input wire [9:0]	line3_r_start,
	input wire [9:0]	line3_r_end,
	input wire [9:0]	line4_r_start,
	input wire [9:0]	line4_r_end,
	input wire [9:0]	line5_r_start,
	input wire [9:0]	line5_r_end,
	input wire [9:0]	line6_r_start,
	input wire [9:0]	line6_r_end,
	input wire [9:0]	line_c1_start,
	input wire [9:0]	line_c1_end,
	input wire [9:0]	line_c2_start,
	input wire [9:0]	line_c2_end,
	output reg [11:0]	white_lines_out
);

/*
// 5 lines row start a & end points
parameter LINE_1_R_START = 0;
parameter LINE_1_R_END   = 63;
parameter LINE_2_R_START = 103;
parameter LINE_2_R_END   = 167;
parameter LINE_3_R_START = 207;
parameter LINE_3_R_END   = 271;
parameter LINE_4_R_START = 311;
parameter LINE_4_R_END   = 375;
parameter LINE_5_R_START = 415;
parameter LINE_5_R_END   = 479;


// line column start and end points
parameter LINE_C_START = 318;
parameter LINE_C_END   = 321;
*/

// Color intensity
parameter BLACK = 12'b000000000000;
parameter WHITE	= 12'b111111111111;


// Checking for white lines positions
always @(posedge clk) begin
	// when displaying locations matches display white lines
	// Line 1
	if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line1_r_start && pix_row <= line1_r_end)) begin
		white_lines_out <= WHITE;
	end
	// Line 2
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line2_r_start && pix_row <= line2_r_end)) begin
		white_lines_out <= WHITE;
	end
	// Line 3
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line3_r_start && pix_row <= line3_r_end)) begin
		white_lines_out <= WHITE;
	end
	// Line 4
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line4_r_start && pix_row <= line4_r_end)) begin
		white_lines_out <= WHITE;
	end
	// Line 5
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line5_r_start && pix_row <= line5_r_end)) begin
		white_lines_out <= WHITE;
	end
	// Line 6
	else if(((pix_col >= line_c1_start && pix_col <= line_c1_end) || (pix_col >= line_c2_start && pix_col <= line_c2_end)) && (pix_row >= line6_r_start && pix_row <= line6_r_end)) begin
		white_lines_out <= WHITE;
	end
	// display track color id not white lines
	else if ((pix_col >= 0 && pix_col <= 639) && (pix_row >= 0 && pix_row <= 479)) begin
		white_lines_out <= track_color;
	end
	// display black if no match found
	else begin
		white_lines_out <= BLACK;
    end
end

endmodule
	


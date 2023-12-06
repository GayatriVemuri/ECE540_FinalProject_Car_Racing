//////////////////////////////////////////////////////////////////////////
//
// Track.v - Track_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs
// It outputs 12 bit value of track image at a specified pixel location.
// 
////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps


module Track_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,
	input wire [1:0]    level,
	output reg [11:0] 	track_color_out
);


// Start and end vpoints of the road image.
parameter G1_START = 0;
parameter G1_END   = 125;
parameter B1_START = 126;
parameter B1_END   = 129;
parameter TRACK_START = 130;
parameter TRACK_END = 510;
parameter B2_START = 511;
parameter B2_END   = 514;
parameter G2_START = 515;
parameter G2_END   = 639;
parameter ROW_START = 0;
parameter ROW_END = 479;

// Colors for tracks
parameter GREEN	= 12'b000111110001;					// turn on only 4 bits of green (color[7:4] represents green)
parameter WHITE	= 12'b111111111111;					// turn on only 4 bits of green (color[7:4] represents green)
parameter BLACK = 12'b000000000000;
parameter CLAY = 12'b110010000110;					// R = 12, G = 8, B = 6
parameter DESERT = 12'b111011101100;				// R = 14, G = 14, B = 12
parameter DARK_GREEN = 12'b000001010001;			// R = 0, G = 5, B = 1
parameter LIGHT_BLUE = 12'b010101011110;			// R = 5, G = 5, B = 14
parameter GRAY = 12'b100110011001;					// R = 9, G = 9, B = 9


// Track image
always @(posedge clk) begin
	// left side dark green track
	if ((pix_col >= G1_START && pix_col <= G1_END) && (pix_row >= ROW_START && pix_row <= ROW_END)) begin
	   case(level)
	       2'b00: track_color_out <= GREEN;
	       2'b01: track_color_out <= DARK_GREEN;
	       2'b10: track_color_out <= DESERT;
	       2'b11: track_color_out <= CLAY;
	   endcase
	end
	else if ((pix_col >= B1_START && pix_col <= B1_END) && (pix_row >= ROW_START && pix_row <= ROW_END)) begin
		track_color_out <= BLACK;
	end
	else if ((pix_col >= TRACK_START && pix_col <= TRACK_END) && (pix_row >= ROW_START && pix_row <= ROW_END)) begin
		track_color_out <= GRAY;
	end
	else if ((pix_col >= B2_START && pix_col <= B2_END) && (pix_row >= ROW_START && pix_row <= ROW_END)) begin
		track_color_out <= BLACK;
	end
	else if ((pix_col >= G2_START && pix_col <= G2_END) && (pix_row >= ROW_START && pix_row <= ROW_END)) begin
		case(level)
	       2'b00: track_color_out <= GREEN;
	       2'b01: track_color_out <= DARK_GREEN;
	       2'b10: track_color_out <= DESERT;
	       2'b11: track_color_out <= CLAY;
	   endcase
	end
	else begin
		track_color_out <= BLACK;
	end
end

endmodule
	

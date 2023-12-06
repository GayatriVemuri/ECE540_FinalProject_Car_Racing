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
wire [3:0] 	pixel_dout;

// You win image position start points
reg [9:0] win_x = 260;     // location x start point
reg [9:0] win_y = 232;     // location y start point 
reg [9:0] index_x, index_y;


// ROM for you win image
you_win_mem you_win (
  .clka(clk),    // input wire clka
  .addra(win_addr),  // input wire [10 : 0] addra
  .douta(pixel_dout)  // output wire [3 : 0] douta
);


// getting the x & y coordinates to position in ROM
always @(posedge clk) begin
	index_x <= pix_col - win_x;
	index_y <= pix_row - win_y;
end

always @(posedge clk) begin
	if (score_in == 50) begin
		win_reset_flag <= 1'b1;
	end
	else begin
		win_reset_flag <= 1'b0;
	end
end

// Printing you win image when in boundary or else Black out.
always @(posedge clk) begin
	if ((index_x >= 0 && index_x < 97) && (index_y >= 0 && index_y < 16)) begin
		win_addr <= {index_y[3:0], index_x[6:0]};
		you_win_out <= win_out;
    end
    else begin
        you_win_out <= BLACK;
    end
end

// Concatenate all colors
assign win_out = {pixel_dout, pixel_dout, pixel_dout};

endmodule

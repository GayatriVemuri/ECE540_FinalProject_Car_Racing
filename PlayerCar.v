/////////////////////////////////////////////////////////////////////////////////////
//
// PlayerCar.v - Player_Car_Top module for ECE 540 Final Project
// 
// Author: Gayatri
// Date: 12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs
// It outputs 12 bit value of car image at a specified pixel location else black.
// 
////////////////////////////////////////////////////////////////////////////////////////


`timescale  1 ns / 1 ps


module Player_Car_Top (
	input wire 			clk,
	//input wire          reset,
	input wire [9:0]	pix_row, pix_col,
	input wire [9:0]    car_yellowX, car_yellowY,
	output reg [11:0]	player_car_out
);	

reg [10:0] car_yellow_addr;
wire [11:0] car_yellow_out;
wire [3:0] pixel_dout_red;
wire [3:0] pixel_dout_blue;
wire [3:0] pixel_dout_green;

// Car position start point
reg [9:0] car_x;     // location x start point
reg [9:0] car_y;     // location y start point 
reg [9:0] index_yellowX, index_yellowY;

parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;


always @(posedge clk) begin
    /*if (reset) begin
        car_x <= 305;
        car_y <= 405;
    end
    else begin*/
        car_x <= car_yellowX;
        car_y <= car_yellowY;
    //end
end

// Getting the output from block memory
red_car_red_mem car_red_red (
    .clka(clk),    				// input wire clka
    .addra(car_yellow_addr),  	// input wire [10 : 0] addra
    .douta(pixel_dout_red)  	// output wire [3 : 0] douta
);

red_car_green_mem car_red_green (
    .clka(clk),    				// input wire clka
    .addra(car_yellow_addr),  	// input wire [10 : 0] addra
    .douta(pixel_dout_green)  	// output wire [3 : 0] douta
);

red_car_blue_mem car_red_blue (
    .clka(clk),    				// input wire clka
    .addra(car_yellow_addr),  	// input wire [10 : 0] addra
    .douta(pixel_dout_blue)  	// output wire [3 : 0] douta
);


// getting the x & y coordinates to position in ROM
always @(posedge clk) begin
    index_yellowX <= pix_col - car_x;
    index_yellowY <= pix_row - car_y;
end

// Printing car mage when in boundary or else Black out.
always @(posedge clk) begin
	// 32 x 64 image (64 rows & 32 columns)
    if((index_yellowX >= 0 && index_yellowX < 32) && (index_yellowY >= 0 && index_yellowY < 64)) begin
        car_yellow_addr <= {index_yellowY[5:0], index_yellowX[4:0]};
        player_car_out <= car_yellow_out;
    end
    else begin
        player_car_out <= BLACK;
    end   
end

assign car_yellow_out = {pixel_dout_blue[3:0], pixel_dout_green[3:0], pixel_dout_red[3:0]};

endmodule


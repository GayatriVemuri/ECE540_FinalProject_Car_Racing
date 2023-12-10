/////////////////////////////////////////////////////////////////////////////////////
//
// MovingCars.v - Moving_Cars_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu), Viraj Pashte (vpashte@pdx.edu)
// Date: 12/04/2023
//
// Description:
// ------------
// It takes current pixel location (pix_row, pix_col) from dtg as inputs.
// This module genrates 4 cars which move from top to bottom of screen with a delay.
// It outputs 12 bit value of car image at a specified pixel location else BLACK.
// Also outputs 2 bit level which is given as an input to road and 6 bits score.
//
////////////////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps

module Moving_Cars_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,	// current pixel being display on screen
	output reg [1:0]    level_out,			// current level number
	output reg [5:0]	score_out,		// current score number of car dodged
	output reg [11:0] 	moving_cars_out		// output image of cars.
);

reg		[31:0]	countHz = {32{1'b0}};		// variable for counting
wire	[31:0]	topCountHz = ((100000000 / 500) - 1);	// count value for 500 hz
reg				tickHz = 1'b0;		// register to set if count equal to 500 hz
reg		[3:0]	speed;				// defines value at which white lines should move, varied based on level
reg		[3:0]	countFlag = 4'b0000;		// value used to check against speed value

// car 1 start coordinates
reg [9:0] car_x1 = 170;		// first lane
reg [9:0] car_y1 = 0;		// top of screen

reg [9:0] car_x2 = 400;		// third lane
reg [9:0] car_y2 = 0;		// top of screen

reg [9:0] car_x3 = 300;		//second lane
reg [9:0] car_y3 = 0;		// top of screen

reg [9:0] car_x4 = 450;		//third lane
reg [9:0] car_y4 = 0;		// top of screen

reg [5:0] score = 0;
reg [1:0] level;

// enable wire for cars
reg enable_c1 = 1'b0;
reg enable_c2 = 1'b0;
reg enable_c3 = 1'b0;
reg enable_c4 = 1'b0;

// speed calculation
always @(posedge clk) begin
	case (level)
		2'b00: speed <= 6;		// if level 1 count for 6 times
		2'b01: speed <= 4;		// if level 2 count for 4 times
		2'b10: speed <= 3;		// if level 3 count for 3 times
		2'b11: speed <= 2;		// if level 4 count for 2 time
	endcase
end

// level calculation
always @(posedge clk) begin
    // first 10 cars level 1
    if (score >= 0 && score <= 9) begin
        level <= 2'b00;
    end
    // next 10 cars level 2
    if (score >= 10 && score <= 19) begin
        level <= 2'b01;
    end
    // next 15 cars dodged level 3
    else if (score >= 20 && score <= 34) begin
        level <= 2'b10;
    end
    // next 15 cars dodged level 4
    else if (score >= 35 && score <= 50) begin
        level <= 2'b11;
    end
end

always @(posedge clk) begin					// on positive edge of clock
	if (countHz == topCountHz) begin			// if countHz equal to count value for 500hz then		       
		if (countFlag == speed) begin			// if speed value (varied according to level) equals count value (times base count (500 hz) has reached its value) 
			tickHz <= 1'b1;				// set tickHz register
			countFlag <= 0;				// clear count flag
			
			// car 1-4 enabling with a delay of 100 pixels.
			enable_c1 <= 1'b1;			// enable car 1 to start from top of screen
			if (car_y1 >= 100) begin		// if car 1 crosses 100 pixels enable car 2 from top of screen
                enable_c2 <= 1'b1;				// enable car 2
            end
            if (car_y2 >= 100) begin				// if car 2 crosses 100 pixels enable car 3 from top of screen
                enable_c3 <= 1'b1;				// enable car 3
			end 
			if (car_y3 >= 100) begin		// if car 3 crosses 100 pixels enable car 4 from top of screen
                enable_c4 <= 1'b1;				// enable car 4
			end
		end								
		else begin
			countFlag <= countFlag + 1'b1;		// increment count flag
			tickHz <= 1'b0;				// clear tick register
		end
		countHz <= {32{1'b0}};				// clear compassCount10hz
	end
	else begin						// if reset is low and count not equal then
		countHz <= countHz + 1'b1;			// increment compassCount10hz
		tickHz <= 1'b0;					// clear tickHz register
    end
end


// Increment logic for y (row) position when enable is ON.
always @(posedge clk) begin
    if ((tickHz & enable_c1) == 1'b1) begin		// if count value set and car 1 is set
        car_y1 <= car_y1 + 4;				// increment car row position with 4 pixels
        if (car_y1 > 480) begin				// if car 1 exits the screen
            car_y1 <= 0;				// set it to top of screen
            score <= score + 1;				// increment the score by 1
        end
    end
    if ((tickHz & enable_c2) == 1'b1) begin		// if count value set and car 2 is set
        car_y2 <= car_y2 + 4;				// increment car row position with 4 pixels
        if (car_y2 > 480) begin				// if car 2 exits the screen
            car_y2 <= 0;				// set it to top of screen
            score <= score + 1;				// increment the score by 1
        end
    end
    if ((tickHz & enable_c3) == 1'b1) begin		// if count value set and car 3 is set
        car_y3 <= car_y3 + 4;				// increment car row position with 4 pixels
        if (car_y3 > 480) begin				// if car 3 exits the screen
            car_y3 <= 0;				// set it to top of screen
            score <= score + 1;				// increment the score by 1
        end
    end
    if ((tickHz & enable_c4) == 1'b1) begin		// if count value set and car 4 is set
        car_y4 <= car_y4 + 4;				// increment car row position with 4 pixels
        if (car_y4 > 480) begin				// if car 4 exits the screen
            car_y4 <= 0;				// set it to top of screen
            score <= score + 1;				// increment the score by 1
        end
    end
    if (score > 50) begin				// if score is greater than 50 set it to 50
        score <= 50;
    end
end


// internal wires
wire [11:0] display_car_OR_out;
wire [11:0] display_car_out1;
wire [11:0] display_car_out2;
wire [11:0] display_car_out3;
wire [11:0] display_car_out4;

// for a certain pixel position only one of the car instance will produce color
// doing an OR operation to get the moving car output.
assign display_car_OR_out = display_car_out1 | display_car_out2 | display_car_out3 | display_car_out4;

// giving the output vatues
always @(posedge clk) begin
	moving_cars_out <= display_car_OR_out;
	level_out <= level;
	score_out <= score;
end

// 4 cars instance
Black_Car_2 display_car1 (
	.clk(clk),
	.enable(enable_c1),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x1),
	.car_y(car_y1),
	.dodge_car_out(display_car_out1));

Yellow_Car_1 display_car2 (
	.clk(clk),
	.enable(enable_c2),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x2),
	.car_y(car_y2),
	.dodge_car_out(display_car_out2));
	
SUV_Car_2 display_car3 (
	.clk(clk),
	.enable(enable_c3),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x3),
	.car_y(car_y3),
	.dodge_car_out(display_car_out3));
	
Black_Car_2 display_car4 (
	.clk(clk),
	.enable(enable_c4),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x4),
	.car_y(car_y4),
	.dodge_car_out(display_car_out4));

endmodule


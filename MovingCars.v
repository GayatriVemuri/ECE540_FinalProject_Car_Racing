/////////////////////////////////////////////////////////////////////////////////////
//
// MovingCars.v - Moving_Cars_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/04/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs.
// It also takes X, Y coordinates (starting point) of the car.
// It outputs 12 bit value of car image at a specified pixel location else BLACK.
// Also outputs 2 bit level which is given as an input to road and 6 bits score.
////////////////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps

module Moving_Cars_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,
	output reg [1:0]    level_out,
	output reg [5:0]	score_out,
	output reg [11:0] 	moving_cars_out
);

reg		[31:0]	countHz = {32{1'b0}};					// variable for counting
wire	[31:0]	topCountHz = ((100000000 / 500) - 1);	// count value for 500 hz
reg				tickHz = 1'b0;							// register to set if count equal to 500 hz
wire			reset = 1'b0;
reg		[3:0]	animFlag = 4'b0000;
reg				myFlag = 1'b0;							// flag tells whether painting lines had reached end of screen
reg		[3:0]	speed;									// defines value at which white lines should move, varied based on level
reg		[3:0]	countFlag = 4'b0000;						// value used to check against speed value

// car 1 start coordinates
reg [9:0] car_x1 = 170;		// first lane
reg [9:0] car_y1 = 0;		// top of screen

reg [9:0] car_x2 = 400;		// third lane
reg [9:0] car_y2 = 0;		// top of screen

reg [9:0] car_x3 = 150;		//first lane
reg [9:0] car_y3 = 0;		// top of screen

reg [9:0] car_x4 = 450;		//first lane
reg [9:0] car_y4 = 0;		// top of screen

reg [9:0] car_x5 = 180;		//first lane
reg [9:0] car_y5 = 0;		// top of screen

reg [9:0] car_x6 = 420;		//first lane
reg [9:0] car_y6 = 0;		// top of screen


reg [5:0] score = 0;
reg [1:0] level;

// enable wire for cars
reg enable_c1 = 1'b0;
reg enable_c2 = 1'b0;
reg enable_c3 = 1'b0;
reg enable_c4 = 1'b0;
reg enable_c5 = 1'b0;
reg enable_c6 = 1'b0;

// speed calculation
always @(posedge clk) begin
	case (level)
		2'b00: speed <= 8;								// if level 1 count for 8 times
		2'b01: speed <= 6;								// if level 2 count for 6 times
		2'b10: speed <= 4;								// if level 3 count for 4 times
		2'b11: speed <= 2;								// if level 4 count for 2 time
	endcase
end

// level calculation
always @(posedge clk) begin
    // first 10 cars level 0
    if (score >= 0 && score <= 5) begin
        level <= 2'b00;
    end
    // next 10 cars level 1
    if (score >= 6 && score <= 15) begin
        level <= 2'b01;
    end
    // next 15 cars dodged level 2
    else if (score >= 16 && score <= 25) begin
        level <= 2'b10;
    end
    // next 15 cars dodged level 3
    else if (score >= 26 && score <= 40) begin
        level <= 2'b11;
    end
end

always @(posedge clk) begin								// on positive edge of clock
	if (countHz == topCountHz) begin				// if countHz equal to count value for 500hz then		       
		if (countFlag == speed) begin					// if speed value (varied according to level) equals count value (times base count (500 hz) has reached its value) 
			tickHz <= 1'b1;								// set tickHz register
			countFlag <= 0;
			
			// car 1-6 enabling with a delay of 100 pixels.
			enable_c1 <= 1'b1;
			if (car_y1 >= 100) begin
                enable_c2 <= 1'b1;
            end
            if (car_y2 >= 100) begin
                enable_c3 <= 1'b1;
			end 
			if (car_y3 >= 100) begin
                enable_c4 <= 1'b1;
			end 
			
			else if (car_y4 >= 100) begin
                enable_c5 <= 1'b1;
			end
			/*
			else if (car_y5 >= 100) begin
                enable_c6 <= 1'b1;
			end
			*/
		end								// clear count flag			end
		else begin
			countFlag <= countFlag + 1'b1;				// increment count flag
			tickHz <= 1'b0;								// clear tick register
		end
		countHz <= {32{1'b0}};							// clear compassCount10hz
	end
	else begin											// if reset is low and count not equal then
		countHz <= countHz + 1'b1;						// increment compassCount10hz
		tickHz <= 1'b0;									// clear tickHz register
    end 
end

// Increment logic for y position
always @(posedge clk) begin
    if ((tickHz & enable_c1) == 1'b1) begin
        car_y1 <= car_y1 + 4;
        if (car_y1 > 480) begin
            car_y1 <= 0;
            score <= score + 1;
        end
    end
    if ((tickHz & enable_c2) == 1'b1) begin
        car_y2 <= car_y2 + 4;
        if (car_y2 > 480) begin
            car_y2 <= 0;
            score <= score + 1;
        end
    end
    if ((tickHz & enable_c3) == 1'b1) begin
        car_y3 <= car_y3 + 4;
        if (car_y3 > 480) begin
            car_y3 <= 0;
            score <= score + 1;
        end
    end
    if ((tickHz & enable_c4) == 1'b1) begin
        car_y4 <= car_y4 + 4;
        if (car_y4 > 480) begin
            car_y4 <= 0;
            score <= score + 1;
        end
    end 
    if ((tickHz & enable_c5) == 1'b1) begin
        car_y5 <= car_y5 + 4;
        if (car_y5 > 480) begin
            car_y5 <= 0;
            score <= score + 1;
        end
    end 
    if (score > 40) begin
        score <= 0;
    end
end


wire [11:0] display_car_OR_out;
wire [11:0] display_car_out1;
wire [11:0] display_car_out2;
wire [11:0] display_car_out3;
wire [11:0] display_car_out4;
wire [11:0] display_car_out5;
wire [11:0] display_car_out6;

assign display_car_OR_out = display_car_out1 | display_car_out2 | display_car_out3 | display_car_out4 | display_car_out5 | display_car_out6;

always @(posedge clk) begin
	moving_cars_out <= display_car_OR_out;
	level_out <= level;
	score_out <= score;
end

// 6 Dodge car instance
Dodge_Car_Top display_car1 (
	.clk(clk),
	.enable(enable_c1),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x1),
	.car_y(car_y1),
	.dodge_car_out(display_car_out1));

Dodge_Car_Top display_car2 (
	.clk(clk),
	.enable(enable_c2),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x2),
	.car_y(car_y2),
	.dodge_car_out(display_car_out2));
	
Dodge_Car_Top display_car3 (
	.clk(clk),
	.enable(enable_c3),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x3),
	.car_y(car_y3),
	.dodge_car_out(display_car_out3));
	
Dodge_Car_Top display_car4 (
	.clk(clk),
	.enable(enable_c4),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x4),
	.car_y(car_y4),
	.dodge_car_out(display_car_out4));
	
Dodge_Car_Top display_car5 (
	.clk(clk),
	.enable(enable_c5),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x5),
	.car_y(car_y5),
	.dodge_car_out(display_car_out5));
	
Dodge_Car_Top display_car6 (
	.clk(clk),
	.enable(enable_c6),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x6),
	.car_y(car_y6),
	.dodge_car_out(display_car_out6));
	
endmodule


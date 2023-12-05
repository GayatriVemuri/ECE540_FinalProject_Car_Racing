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
// 
////////////////////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps

module Moving_Cars_Top (
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,
	input wire [1:0]    level,
	output reg [11:0] 	moving_cars_out
);

reg		[31:0]	countHz;								// variable for counting
wire	[31:0]	topCountHz = ((100000000 / 500) - 1);	// count value for 500 hz
reg				tickHz = 1'b0;							// register to set if count equal to 500 hz
wire			reset = 1'b0;
reg		[3:0]	animFlag = 4'b0000;
reg				myFlag = 1'b0;							// flag tells whether painting lines had reached end of screen
reg		[2:0]	speed;									// defines value at which white lines should move, varied based on level
reg		[2:0]	countFlag = 3'b000;						// value used to check against speed value

// car 1 start coordinates
reg [9:0] car_x1 = 170;		//first lane
reg [9:0] car_y1 = 0;		// top of screen
//reg [9:0] car_y1_end = 59;
wire [11:0] display_car_out;


// speed calculation
always @(posedge clk) begin
	case (level)
		2'b00: speed <= 8;								// if level 1 count for 8 times
		2'b01: speed <= 6;								// if level 2 count for 6 times
		2'b10: speed <= 4;								// if level 3 count for 4 times
		2'b11: speed <= 2;								// if level 4 count for 2 time
	endcase
end

always @(posedge clk) begin								// on positive edge of clock
	if (reset) begin									// if reset is high, clear count
		countHz <= {32{1'b0}};
	end
	else if (countHz == topCountHz) begin				// if countHz equal to count value for 500hz then		       
		if (countFlag == speed) begin					// if speed value (varied according to level) equals count value (times base count (500 hz) has reached its value) 
			tickHz <= 1'b1;								// set tickHz register
			countFlag <= 0;
			car_y1 <= car_y1 + 4;
		
		    if (car_y1 > 480) begin
			     car_y1 <= 0;
		    end
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


always @(posedge clk) begin
	moving_cars_out <= display_car_out;
end

Dodge_Car_Top display_car1 (
	.clk(clk),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.car_x(car_x1),
	.car_y(car_y1),
	.dodge_car_out(display_car_out));
	
endmodule


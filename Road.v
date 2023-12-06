//////////////////////////////////////////////////////////////////////////
//
// Road.v - Road_Top module for ECE 540 Final Project
// 
// Author: Gayatri Vemuri (gayatri@pdx.edu)
// Date: 12/02/2023
//
// Description:
// ------------
// It takes current pixel location (pixelRow, pixelCol) from dtg as inputs
// Instantiates white lines & track modules which is used to create 
// an image for the screen.
// It outputs 12 bit value of road image at a specified pixel location.
// 
///////////////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps


module Road_Top(
	input wire 			clk,
	input wire [9:0]	pix_row, pix_col,
	input wire [1:0]    level,
	output reg [11:0]	road_out
);


// Lines start & end
reg [9:0]	line1_r_start = 0;
reg [9:0]	line1_r_end = 47;
reg [9:0]	line2_r_start = 95;
reg [9:0]	line2_r_end = 143;
reg [9:0]	line3_r_start = 191;
reg [9:0]	line3_r_end = 239;
reg [9:0]	line4_r_start = 287;
reg [9:0]	line4_r_end = 335;
reg [9:0]	line5_r_start = 383;
reg [9:0]	line5_r_end = 431;
reg [9:0]	line6_r_start = 383;
reg [9:0]	line6_r_end = 431;
reg [9:0]	line_c1_start = 255;
reg [9:0]	line_c1_end = 258;
reg [9:0]	line_c2_start = 383;
reg [9:0]	line_c2_end = 386;

reg		[31:0]	countHz = {32{1'b0}};								// variable for counting
wire	[31:0]	topCountHz = ((100000000 / 500) - 1);	// count value for 500 hz
reg				tickHz = 1'b0;							// register to set if count equal to 500 hz
reg		[3:0]	animFlag = 4'b0000;
reg				myFlag = 1'b0;							// flag tells whether painting lines had reached end of screen
reg		[3:0]	speed;									// defines value at which white lines should move, varied based on level
reg		[3:0]	countFlag = 4'b0000;						// value used to check against speed value

wire	[11:0]	whiteLinesOut;
wire	[11:0]  track_color;

	
// 00 - 6, 01 - 4, 10 - 2, 11 - 1	
always @(posedge clk) begin
	case (level)
		2'b00: speed <= 6;								// if level 1 count for 8 times
		2'b01: speed <= 4;								// if level 2 count for 6 times
		2'b10: speed <= 2;								// if level 3 count for 4 times
		2'b11: speed <= 1;								// if level 4 count for 2 time
	endcase
end
	
always @(posedge clk) begin								// on positive edge of clock
	if (countHz == topCountHz) begin				// if countHz equal to count value for 500hz then		       
		if (countFlag == speed) begin					// if speed value (varied according to level) equals count value (times base count (500 hz) has reached its value) 
			tickHz <= 1'b1;								// set tickHz register
			countFlag <= 0;
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
    line_c1_start <= 255;
    line_c1_end <= 258;
    line_c2_start <= 383;
    line_c2_end <= 386;
    road_out = whiteLinesOut;
    
    case(myFlag)
        1'b0: begin
            if (tickHz == 1'b1) begin
                line1_r_start <= line1_r_start + 8;
                line1_r_end <= line1_r_end + 8;
                line2_r_start <= line2_r_start + 8;
                line2_r_end <= line2_r_end + 8;
                line3_r_start <= line3_r_start + 8;
                line3_r_end <= line3_r_end + 8;
                line4_r_start <= line4_r_start + 8;
                line4_r_end <= line4_r_end + 8;
                line5_r_start <= line5_r_start + 8;
                line5_r_end <= line5_r_end + 8;
                line6_r_start <= line6_r_start + 8;
                line6_r_end <= line6_r_end + 8;
                
                // setting value for line 6 as line 5 end reaches end of screen
                if (line5_r_end > 479) begin
                    line6_r_start <= 0;
                    line6_r_end <= line5_r_end - 479;
                end
                else begin
                    line6_r_start <= line5_r_start;
                    line6_r_end <= line5_r_end;
                end 
                
                animFlag <= animFlag + 4'b0001;			// increment animation flag every time white lines are incremented
                // if incrementing lines is done for eight times start animation again from start of screen
				if (animFlag == 4'b1100) begin			// 6 times for road + 6 for white line
					myFlag <= 1'b1;						// set myFlag
				end
			end
	   end   
	   1'b1: begin
	       if (tickHz == 1'b1) begin
	           line1_r_start <= 0;
               line1_r_end <= 47;
               line2_r_start <= 95;
               line2_r_end <= 143;
               line3_r_start <= 191;
               line3_r_end <= 239;
               line4_r_start <= 287;
               line4_r_end <= 335;
               line5_r_start <= 383;
               line5_r_end <= 431;
               line6_r_start <= 383;
               line6_r_end <= 431;
               animFlag <= 4'b0000;
               myFlag <= 1'b0;
           end
        end
    endcase
end


White_Lines_Top white_lines (
	.clk(clk),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.track_color(track_color),
	.line1_r_start(line1_r_start),
	.line1_r_end(line1_r_end),
	.line2_r_start(line2_r_start),
	.line2_r_end(line2_r_end),
	.line3_r_start(line3_r_start),
	.line3_r_end(line3_r_end),
	.line4_r_start(line4_r_start),
	.line4_r_end(line4_r_end),
	.line5_r_start(line5_r_start),
	.line5_r_end(line5_r_end),
	.line6_r_start(line6_r_start),
	.line6_r_end(lin6_r_end),
	.line_c1_start(line_c1_start),
	.line_c1_end(line_c1_end),
	.line_c2_start(line_c2_start),
	.line_c2_end(line_c2_end),
    .white_lines_out(whiteLinesOut)
);

Track_Top track (
	.clk(clk),
	.pix_row(pix_row), 
	.pix_col(pix_col),
	.level(level),
	.track_color_out(track_color)
);

endmodule

/*
############################################# 
# ECE 540 project 2
#
# Author:	Rafael Schultz (srafael@pdx.edu)
# Date:		11-Nov-2023	
#
# Changes made to include VGA peripheral
#
# Targeted to Nexys A7 FPGA board
#############################################
*/



//	dtg_top.v - Horizontal & Vertical Display Timing & Sync generator for VESA timing
//	1024 * 768 working
//	Version:		3.0	
//	Author:			Srivatsa Yogendra, John Lynch & Roy Kravitz
//	Last Modified:	11-Nov-2023
//	
//	 Revision History
//	 ----------------
//	 02-Feb-06		JDL	Added video_on output; simplified counter logic
//	 25-Oct-12		Modified for kcpsm6 and Nexys3
//   	 20-Sep-17		Modified the design, to produce signals for 1024*768 resolution
//	 11-Nov-23		Modified to be used on project 2 for ECE540 by Rafael
//
//	Description:
//	------------
//	 This circuit provides pixel location and horizontal and 
//	 vertical sync for a 1024 x 768 video image. 
//	
//	 Inputs:
//			clock           - 75MHz Clock
//			rst             - Active-high synchronous reset
//	 Outputs:
//			horiz_sync_out	- Horizontal sync signal to display
//			vert_sync_out	- Vertical sync signal to display
//			Pixel_row	- (12 bits) current pixel row address // changed to 10 bits by rafael
//			Pixel_column	- (12 bits) current pixel column address // changed to 10 bits by rafael
//			video_on        - 1 = in active video area; 0 = blanking;
//			
//////////

module dtg_top ( // renamed module name by rafael
	input			clock, rst,
	output wire		horiz_sync, vert_sync, video_on, // changed to wire type rafael	
	output reg [9:0]	pixel_row, pixel_column, // changed size rafael
	
	//absolute 1D pixel offset, equal to (row * column width) + column
	output reg [31:0]  pix_num 
);
/*
// Timing parameters (for 75MHz pixel clock and 1024 x 768 display)
//parameter
//		HORIZ_PIXELS = 1024,  HCNT_MAX  = 1327, 		
//		HSYNC_START  = 1053,  HSYNC_END = 1189,

//		VERT_PIXELS  = 768,  VCNT_MAX  = 805,
//		VSYNC_START  = 773,  VSYNC_END = 779;
*/
// Timing parameters (for 31.5MHz pixel clock and 640 x 480 display @ 73Hz)
parameter
		HORIZ_PIXELS = 640,  HCNT_MAX  = 831, 		
		HSYNC_START  = 664,  HSYNC_END = 704,

		VERT_PIXELS  = 480,  VCNT_MAX  = 519,
		VSYNC_START  = 489,  VSYNC_END = 491;    
		
// Timing parameters for 25.20MHz and 640 x 480 display (based on website http://tinyvga.com/vga-timing/640x480@60Hz)
/*parameter
		HORIZ_PIXELS = 640,  HCNT_MAX  = 799, 		
		HSYNC_START  = 656,  HSYNC_END = 752,

		VERT_PIXELS  = 480,  VCNT_MAX  = 524, // changed 523 to 524 rafael
		VSYNC_START  = 490,  VSYNC_END = 492; // changed 491 to 490 rafael */

// generate video signals and pixel counts
always @(posedge clock) begin
	if (rst) begin
	    	pix_num      <= 0;
		pixel_column <= 0;
		pixel_row    <= 0;
	end
	else begin
		// increment horizontal sync counter.  Wrap if at end of row
		if (pixel_column == HCNT_MAX)	
			pixel_column <= 10'd0;
		else	
			pixel_column <= pixel_column + 10'd1;
			
		// increment vertical sync ounter.  Wrap if at end of display.  Increment if end of row
		// reset absolute pixel count on row reset, otherwise increment on every clock cycle
		if ((pixel_row >= VCNT_MAX) && (pixel_column >= HCNT_MAX))
			pixel_row <= 10'd0;
		else if (pixel_column == HCNT_MAX)
			pixel_row <= pixel_row + 10'd1;

		
		//increment pix_num on every clock, when video is on, 
		if ((pixel_column < HORIZ_PIXELS) && (pixel_row < VERT_PIXELS))
		  pix_num <= pix_num + 32'd1;
		//if we are in the vertical blanking area, reset pix_num to 0
		else if (pixel_row >= VERT_PIXELS)
		  pix_num <= 32'd0;

	end
end // always


	// moved these 3 out from always loop and made assign type by rafael

	// generate active-low horizontal sync pulse
	assign horiz_sync =  ~((pixel_column >= HSYNC_START) && (pixel_column < HSYNC_END)); // removed equal at the 2nd comparator rafael
	
	// generate active-low vertical sync pulse
	assign vert_sync = ~((pixel_row >= VSYNC_START) && (pixel_row < VSYNC_END)); // removed equal at the 2nd comparator rafael
	
	// generate the video_on signals
	assign video_on = ((pixel_column < HORIZ_PIXELS) && (pixel_row < VERT_PIXELS));

endmodule
//////////////////////////////////////////////////////////////////////////
//
// vga_top.v - vga_top module for ECE 540 Final Project
// 
// Author: Viraj Pashte (vpashte@pdx.edu), Sahil Khan (sahilk@pdx.edu), Gayatri vemuri (gayatri@pdx.edu)
// Date: 12/02/2023
//
// Description:
// ------------
//
// We use this module to instantiate all other sub modules to display the game.
// Using the WishBone to read and write the peripheral to use the data from the firmware.
// We cocantinate all the signals and get the output through vga out to the display.
///////////////////////////////////////////////////////////////////////////


// Yellow car boundary cell
`define YELLOW_CAR_ROW_1    10'h1AD // 479
`define YELLOW_CAR_ROW_2    10'h195 // 429
`define YELLOW_CAR_COL_1    10'h125 // 269
`define YELLOW_CAR_COL_2    10'h136 // 368


module vga_top(
	// WISHBONE Interface
	wb_clk_i, wb_rst_i, wb_cyc_i, wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i,
	wb_dat_o, wb_ack_o, wb_err_o, wb_inta_o,

	vga_clk, // pixel clock
	// External VGA Interface
	ext_pad_o
);

parameter dw = 32;
parameter aw = 32;

//
// WISHBONE Interface
//
input wire            wb_clk_i;		// Clock
input wire            wb_rst_i;		// Reset
input wire            wb_cyc_i;		// cycle valid input
input wire  [aw-1:0]  wb_adr_i;		// address bus inputs
input wire  [dw-1:0]  wb_dat_i;		// input data bus
input wire  [3:0]     wb_sel_i;		// byte select inputs
input wire            wb_we_i;		// indicates write transfer
input wire            wb_stb_i;		// strobe input
output wire [dw-1:0]  wb_dat_o;		// output data bus
output wire           wb_ack_o;		// normal termination
output wire           wb_err_o;		// termination w/ error
output wire           wb_inta_o;	// Interrupt request output

input wire            vga_clk;		// pixel clock

//
// External VGA Interface
output wire [13:0]  ext_pad_o;		// VGA Outputs


wire video_on;
wire H_SYNC;
wire V_SYNC;
wire [9:0] pix_row;
wire [9:0] pix_col;
wire [31:0] pix_num;
wire [3:0] dout_r;
wire [3:0] dout_g;
wire [3:0] dout_b;

reg [9:0] car_yellowX;     // location x start point
reg [9:0] car_yellowY;     // location y start point 


reg [31:0] VGA_ROW_COL, VGA_DATA;
reg         wb_vga_ack_ff;


always @(posedge wb_clk_i, posedge wb_rst_i) begin
if (wb_rst_i) begin
VGA_ROW_COL = 32'h00 ;
VGA_DATA = 32'h00;
wb_vga_ack_ff = 0 ;
end
else begin
case (wb_adr_i[5:2])
0: begin  
    VGA_ROW_COL = wb_vga_ack_ff && wb_we_i ? wb_dat_i : VGA_ROW_COL;
    car_yellowX = VGA_ROW_COL [9:0]; 
    car_yellowY = VGA_ROW_COL [19:10];
end
1: begin
    VGA_DATA = wb_vga_ack_ff && wb_we_i ? wb_dat_i : VGA_DATA;
   end
endcase


// Ensure 1 wait state even for back to back host requests
wb_vga_ack_ff = ! wb_vga_ack_ff & wb_stb_i & wb_cyc_i;
end
end
assign wb_ack_o = wb_vga_ack_ff;
assign wb_dat_o = (wb_adr_i[5:2]==0) ? VGA_ROW_COL: VGA_DATA;


// Road_Top module which show road image with white lines
wire [11:0] road_out;

// test level logic
wire [1:0] level;

// score wire
wire [5:0] score;

parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;

// Internal Wiress
wire [11:0] player_car_out;
wire [11:0] vga_out;
wire [11:0] moving_cars_out;
wire        win_reset_flag;
wire [11:0] you_win_out;
wire        collision_flag;
wire [11:0] game_over_out;

// DTG module instance
dtg_top dtg_top_inst(
	.clock(vga_clk),
	.rst(wb_rst_i),
	.video_on(video_on),
	.horiz_sync(H_SYNC),
	.vert_sync(V_SYNC),
	.pixel_row(pix_row),
	.pixel_column(pix_col),
	.pix_num(pix_num)
  );
 
// Road module instance  
Road_Top Road (
    .clk(vga_clk),
    //.reset(RESET),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .level(level),
    .road_out(road_out));
    
// Player Car instance     
Player_Car_Top PlayerCar (
	.clk(vga_clk),
	//.reset(RESET),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .car_yellowX(car_yellowX),
    .car_yellowY(car_yellowY),
    .player_car_out(player_car_out));

// Moving cars module instance     
Moving_Cars_Top MovingCar (
    .clk(vga_clk),
    //.reset(RESET),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .level_out(level),
    .score_out(score),
    .moving_cars_out(moving_cars_out));
// You Win instance     
You_Win_Top YouWin (
    .clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .score_in(score),
    .win_reset_flag(win_reset_flag),
    .you_win_out(you_win_out));

// Game Over instance     
Game_Over_Top GameOver (
    .clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .moving_cars_in(moving_cars_out),
    .player_car_in(player_car_out),
    .collosion_flag(collision_flag),
    .game_over_out(game_over_out));

// Combine module instance 
Combine_Top Combine (
	.clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .video_on(video_on),
    .road_in(road_out),
    .player_car_in(player_car_out),
    .moving_cars_in(moving_cars_out),
    .you_win_in(you_win_out),
    .win_reset_flag(win_reset_flag),
    .game_over_in(game_over_out),
    .game_over_flag(collision_flag),
    .vga_out(vga_out));

//
// Generate VGA outputs

assign ext_pad_o = {V_SYNC,H_SYNC,vga_out};

endmodule

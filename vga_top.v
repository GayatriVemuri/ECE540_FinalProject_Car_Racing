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
input wire            wb_clk_i;	// Clock
input wire            wb_rst_i;	// Reset
input wire            wb_cyc_i;	// cycle valid input
input wire  [aw-1:0]  wb_adr_i;	// address bus inputs
input wire  [dw-1:0]  wb_dat_i;	// input data bus
input wire  [3:0]     wb_sel_i;	// byte select inputs
input wire            wb_we_i;	// indicates write transfer
input wire            wb_stb_i;	// strobe input
output wire [dw-1:0]  wb_dat_o;	// output data bus
output wire           wb_ack_o;	// normal termination
output wire           wb_err_o;	// termination w/ error
output wire           wb_inta_o;	// Interrupt request output

input wire            vga_clk;	// pixel clock

//
// External VGA Interface
output wire [13:0]  ext_pad_o;	// VGA Outputs


  wire video_on;
  wire H_SYNC;
  wire V_SYNC;
  wire [9:0] pix_row;
  wire [9:0] pix_col;
  wire [31:0] pix_num;
  wire [3:0] dout_r;
  wire [3:0] dout_g;
  wire [3:0] dout_b;
 

reg [3:0] RED;
reg [3:0] GREEN; 
reg [3:0] BLUE;
  

reg [31:0] wb_vga_reg, wb_vga_reg2;
reg         wb_vga_ack_ff;
always @(posedge wb_clk_i, posedge wb_rst_i) begin
if (wb_rst_i) begin
wb_vga_reg = 32'h00 ;
wb_vga_reg2 = 32'h00;
wb_vga_ack_ff = 0 ;
end
else begin
case (wb_adr_i[5:2])
0: wb_vga_reg = wb_vga_ack_ff && wb_we_i ? wb_dat_o : wb_vga_reg;
1: wb_vga_reg2 = wb_vga_ack_ff && wb_we_i ? wb_dat_o : wb_vga_reg2;
endcase
// Ensure 1 wait state even for back to back host requests
wb_vga_ack_ff = ! wb_vga_ack_ff & wb_stb_i & wb_cyc_i;
end
end
assign wb_ack_o = wb_vga_ack_ff;
assign wb_dat_o = (wb_adr_i[5:2]==0) ? wb_vga_reg: wb_vga_reg2;


// Road_Top module which show road image with white lines
wire [11:0] road_out;

// test level logic
reg [1:0] level;
reg [2:0] level_num = 3'b000;
reg [31:0] count_level = 32'h00000000;
reg [31:0] max_count = 32'h05FFFFFF;

always @(posedge vga_clk) begin
    count_level <= count_level + 1;
    if (count_level == max_count) begin
        count_level <= 32'h00000000;
        level_num <= level_num + 3'b001;
        if (level_num == 3'b100) begin
            level_num <= 3'b000;
        end
    end
    case(level_num)
        3'b000: level <= level_num[1:0];
        3'b001: level <= level_num[1:0];
        3'b010: level <= level_num[1:0];
        3'b011: level <= level_num[1:0];
        default: level <= 2'b00;
    endcase
end

wire [10:0] car_yellow_addr;
reg [11:0] car_yellow_out;
wire [3:0] pixel_dout_red;
wire [3:0] pixel_dout_blue;
wire [3:0] pixel_dout_green;
//wire video_on;

// Car position start point
reg [9:0] car_yellowX = 447;     // location x start point
reg [9:0] car_yellowY = 305;     // location y start point 
reg [9:0] car_r1 = 447;
reg [9:0] car_c1 = 305;
reg [9:0] car_r2 = 479;
reg [9:0] car_c2 = 336;
reg [9:0] index_yellowX, index_yellowY;
reg [4:0] x_max = 32;
reg [5:0] y_max = 64;

parameter WHITE	= 12'b111111111111;
parameter BLACK = 12'b000000000000;


wire [11:0] player_car_out;
wire [11:0] vga_out;
wire [11:0] moving_cars_out;


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
  
Road_Top Road (
    .clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .level(level),
    .road_out(road_out));
    
Player_Car_Top PlayerCar (
	.clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .player_car_out(player_car_out));
    
Moving_Cars_Top MovingCar (
    .clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .level(level),
    .moving_cars_out(moving_cars_out));

Combine_Top Combine (
	.clk(vga_clk),
    .pix_row(pix_row),
    .pix_col(pix_col),
    .video_on(video_on),
    .road_in(road_out),
    .player_car_in(player_car_out),
    .moving_cars_in(moving_cars_out),
    .vga_out(vga_out));

//
// Generate VGA outputs

assign ext_pad_o = {V_SYNC,H_SYNC,vga_out};



endmodule

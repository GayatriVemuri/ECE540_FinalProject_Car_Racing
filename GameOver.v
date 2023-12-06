module Game_Over_Top (
    input wire clk,
    input wire [9:0]    pix_row, pix_col,
    input wire [11:0] 	moving_cars_in,
    input wire [11:0]	player_car_in,
    output reg          collosion_flag,
    output reg [11:0]   game_over_out 

);

reg [10:0] game_over_addr;
wire [3:0] pixel_dout;
wire [11:0] game_out;

reg [9:0] start_x = 243;
reg [9:0] start_y = 232;
reg [9:0] index_x, index_y;

parameter WHITE = 12'b111111111111;
parameter BLACK = 12'b000000000000;

// Rom instance
game_over_mem game_over (
  .clka(clk),               // input wire clka
  .addra(game_over_addr),   // input wire [11 : 0] addra
  .douta(pixel_dout)        // output wire [3 : 0] douta
);

// Collision logic
always @(posedge clk) begin
        if ((player_car_in > BLACK && player_car_in  < WHITE ) && (moving_cars_in > BLACK && moving_cars_in < WHITE)) begin
                collosion_flag <= 1'b1;
        end
        else begin
             collosion_flag <= 1'b0;
        end
end

always @(posedge clk) begin
    if(collosion_flag) begin
        if ((index_x >= 0 && index_x < 135) && (index_y >= 0 && index_y < 16)) begin
            game_over_addr <= {index_y[3:0], index_x[7:0]};
            game_over_out <= game_out;
        end
    else begin
        game_over_out <= BLACK;
        end
    end
end

assign game_out = {pixel_dout, pixel_dout, pixel_dout};

endmodule
`timescale 1ns / 1ps

module vga_controller (
    input  wire        clk_25Mhz,
    input  wire        reset,
    input  wire [9:0]  snake_x,      // Head X position
    input  wire [9:0]  snake_y,      // Head Y position
    input  wire [999:0] value_x,     // Packed body X positions (100 x 10 bits)
    input  wire [999:0] value_y,     // Packed body Y positions (100 x 10 bits)
    input  wire [6:0]  length,       // Current length of snake
    input  wire [9:0]  apple_x,      // Apple X position
    input  wire [9:0]  apple_y,      // Apple Y position
    input  wire [15:0] score,        // Score
    input  wire        game_over,    // Game over signal
    
    output reg  [9:0]  h_counter,
    output reg  [9:0]  v_counter,
    output reg         h_sync,
    output reg         v_sync,
    output reg  [3:0]  vga_r,
    output reg  [3:0]  vga_g,
    output reg  [3:0]  vga_b
);

    // VGA 640x480 @ 60Hz timing constants
    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    // Horizontal & Vertical Sync Counters
    always @(posedge clk_25Mhz or posedge reset) begin
        if (reset) begin
            h_counter <= 0;
            v_counter <= 0;
        end else begin
            if (h_counter < H_TOTAL - 1) begin
                h_counter <= h_counter + 1'b1;
            end else begin
                h_counter <= 0;
                if (v_counter < V_TOTAL - 1)
                    v_counter <= v_counter + 1'b1;
                else
                    v_counter <= 0;
            end
        end
    end

    // Sync Signal Generation (Active Low)
    always @(posedge clk_25Mhz or posedge reset) begin
        if (reset) begin
            h_sync <= 1'b1;
            v_sync <= 1'b1;
        end else begin
            h_sync <= ~((h_counter >= (H_DISPLAY + H_FRONT)) && 
                        (h_counter < (H_DISPLAY + H_FRONT + H_SYNC)));
            v_sync <= ~((v_counter >= (V_DISPLAY + V_FRONT)) && 
                        (v_counter < (V_DISPLAY + V_FRONT + V_SYNC)));
        end
    end

    // Active Display Area Flag
    wire video_on = (h_counter < H_DISPLAY) && (v_counter < V_DISPLAY);

    // Wall Boundary Drawing Logic (8-pixel border wall)
    wire wall_on = (h_counter < 8) || (h_counter >= 632) || 
                   (v_counter < 8) || (v_counter >= 472);

    // Bounding Box checks for Apple & Snake Head
    wire head_hit  = (h_counter >= snake_x - 3) && (h_counter <= snake_x + 3) &&
                     (v_counter >= snake_y - 3) && (v_counter <= snake_y + 3);

    wire apple_hit = (h_counter >= apple_x - 3) && (h_counter <= apple_x + 3) &&
                     (v_counter >= apple_y - 3) && (v_counter <= apple_y + 3);

    // Dynamic Snake Body Hit Detection using a Bounded For-Loop
    integer i;
    reg body_hit;
    reg [9:0] cur_x, cur_y;

    always @(*) begin
        body_hit = 1'b0;
        cur_x = 10'd0;
        cur_y = 10'd0;
        for (i = 1; i < 100; i = i + 1) begin
            if (i < length) begin
                cur_x = value_x[i*10 +: 10];
                cur_y = value_y[i*10 +: 10];
                if ((h_counter >= cur_x - 2) && (h_counter <= cur_x + 2) &&
                    (v_counter >= cur_y - 2) && (v_counter <= cur_y + 2)) begin
                    body_hit = 1'b1;
                end
            end
        end
    end

    // Submodule Connections for Text Displays
    wire [11:0] score_pixel_data;
    wire [11:0] go_pixel_data;

    text_generator display_score (
        .clk(clk_25Mhz),
        .h_counter(h_counter),
        .v_counter(v_counter),
        .score(score),
        .pixel_data(score_pixel_data)
    );

    go_generator display_game_over (
        .clk(clk_25Mhz),
        .h_counter(h_counter),
        .v_counter(v_counter),
        .game_over(game_over),
        .pixel_data(go_pixel_data)
    );

    // Pixel Output Logic with Wall Render Logic
    always @(posedge clk_25Mhz or posedge reset) begin
        if (reset) begin
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else if (video_on) begin
            if (game_over) begin
                // Render Game Over Screen Overlay
                vga_r <= go_pixel_data[11:8];
                vga_g <= go_pixel_data[7:4];
                vga_b <= go_pixel_data[3:0];
            end else if (wall_on) begin
                // Border Walls (Yellow/Amber)
                vga_r <= 4'hF;
                vga_g <= 4'hF;
                vga_b <= 4'h0;
            end else if (head_hit) begin
                // Snake Head (Bright Green)
                vga_r <= 4'h0;
                vga_g <= 4'hF;
                vga_b <= 4'h0;
            end else if (body_hit) begin
                // Snake Body (Darker Green)
                vga_r <= 4'h0;
                vga_g <= 4'hA;
                vga_b <= 4'h0;
            end else if (apple_hit) begin
                // Apple (Red)
                vga_r <= 4'hF;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end else if (score_pixel_data != 12'h000) begin
                // Score Overlay
                vga_r <= score_pixel_data[11:8];
                vga_g <= score_pixel_data[7:4];
                vga_b <= score_pixel_data[3:0];
            end else begin
                // Background (Black)
                vga_r <= 4'h0;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end
        end else begin
            // Blanking Period
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end
    end
endmodule

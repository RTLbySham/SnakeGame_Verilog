`timescale 1ns / 1ps

module snake_top (
    // DE2-115 Onboard 50 MHz Clock and Reset
    input wire CLOCK_50,        // 50 MHz system clock (PIN_Y2)
    input wire reset,           // Reset signal (SW[0])
    input wire [3:0] buttons,   // Pushbuttons for direction (KEY[3:0])

    // DE2-115 VGA Interface Outputs
    output wire VGA_HS,         // Horizontal Sync (PIN_G13)
    output wire VGA_VS,         // Vertical Sync (PIN_C13)
    output wire [7:0] VGA_R,    // Red channel (8 bits)
    output wire [7:0] VGA_G,    // Green channel (8 bits)
    output wire [7:0] VGA_B,    // Blue channel (8 bits)
    output wire VGA_CLK,        // VGA DAC Clock (PIN_A12)
    output wire VGA_BLANK_N,    // VGA DAC Blanking (Active Low) (PIN_F11)
    output wire VGA_SYNC_N      // VGA DAC Sync (Active Low) (PIN_C10)
);

    // Internal Clock Signals
    wire vga_clk;       // 25.175 MHz Pixel Clock from ALTPLL
    wire game_clk;      // Faster movement clock tick for snake game logic

    // Direct Signal Connections to ADV7123 DAC on DE2-115
    assign VGA_CLK     = vga_clk;
    assign VGA_BLANK_N = 1'b1; // Always active
    assign VGA_SYNC_N  = 1'b0; // Unused in standard VGA mode

    // Invert Active-Low DE2-115 Pushbuttons (KEY[3:0])
    wire [3:0] btn_pressed = ~buttons;

    // Intermediate 4-bit Color Signals from VGA Controller
    wire [3:0] vga_r_4bit;
    wire [3:0] vga_g_4bit;
    wire [3:0] vga_b_4bit;

    // Expand 4-bit color outputs to DE2-115 8-bit VGA DAC inputs
    assign VGA_R = {vga_r_4bit, 4'b0000};
    assign VGA_G = {vga_g_4bit, 4'b0000};
    assign VGA_B = {vga_b_4bit, 4'b0000};

    // Snake Body Coordinates & Game State Wires
    wire [999:0] pos_x, pos_y;
    wire [9:0] head_x = pos_x[9:0];
    wire [9:0] head_y = pos_y[9:0];
    
    wire [9:0] pos_x_rand, pos_y_rand;
    reg [9:0] curr_apple_x, curr_apple_y;
    reg [6:0] length;            // Snake length
    reg [3:0] velocity;
    reg [9:0] apple_count;
    reg [15:0] score;
    
    wire signed [10:0] last_vel_x, last_vel_y;
    wire collision;
    
    parameter [19:0] rand_seed = 2026;

    // =========================================================================
    // 1. Clock Generation Subsystem
    // =========================================================================
    vga_pll pll_inst (
        .inclk0 ( CLOCK_50 ),
        .c0     ( vga_clk )
    );

    // Speed adjustment: game_clk updated from ~3 Hz (bit 22) to ~24 Hz (bit 19)
    reg [23:0] clk_divider;
    always @(posedge vga_clk or posedge reset) begin
        if (reset)
            clk_divider <= 24'd0;
        else
            clk_divider <= clk_divider + 1'b1;
    end
    
    assign game_clk = clk_divider[19]; // Increased movement speed (~24 Hz tick)

    // =========================================================================
    // 2. Snake Position Controller & Collision Detection Module
    // =========================================================================
    Snake_Position_Controller control1 (
        .pos_x      ( pos_x ),
        .pos_y      ( pos_y ),
        .buttons    ( btn_pressed ),
        .clock      ( game_clk ),
        .reset      ( reset ),
        .length     ( {3'b000, length} ),
        .velocity   ( velocity ),
        .x_apple    ( curr_apple_x ),
        .y_apple    ( curr_apple_y ),
        .last_vel_x ( last_vel_x ),
        .last_vel_y ( last_vel_y ),
        .collision  ( collision )
    );

    // =========================================================================
    // 3. Pseudo-Random Apple Generator
    // =========================================================================
    Random_Generator random1 (
        .pos_x_rand ( pos_x_rand ),
        .pos_y_rand ( pos_y_rand ),
        .rand_seed  ( rand_seed ),
        .clock_1hz  ( game_clk ),
        .reset      ( reset || collision ),
        .x_apple    ( curr_apple_x ),
        .y_apple    ( curr_apple_y ),
        .velocity   ( velocity )
    );

    // =========================================================================
    // 4. Apple Hit Detection & Score/Growth Handler
    // =========================================================================
    wire [9:0] diff_x = (head_x > curr_apple_x) ? (head_x - curr_apple_x) : (curr_apple_x - head_x);
    wire [9:0] diff_y = (head_y > curr_apple_y) ? (head_y - curr_apple_y) : (curr_apple_y - head_y);
    wire apple_hit = (diff_x <= 10'd5) && (diff_y <= 10'd5);

    always @(posedge game_clk or posedge reset) begin
        if (reset) begin
            curr_apple_x <= 10'd160;
            curr_apple_y <= 10'd320;
            length       <= 7'd1;     // Start with length = 1
            score        <= 16'd0;
            apple_count  <= 10'd0;
            velocity     <= 4'd4;     // Increased velocity step size (4 pixels)
        end else if (collision) begin
            curr_apple_x <= 10'd160;
            curr_apple_y <= 10'd320;
            length       <= 7'd1;     // Reset length on collision
            score        <= 16'd0;
            apple_count  <= 10'd0;
            velocity     <= 4'd4;
        end else begin
            if (apple_hit) begin
                if (length < 7'd64)   // Cap maximum growth length
                    length <= length + 1'b1;
                apple_count  <= apple_count + 1'b1;
                score        <= score + 16'd10;
                curr_apple_x <= pos_x_rand;   // Relocate apple
                curr_apple_y <= pos_y_rand;
            end
        end
    end

    // =========================================================================
    // 5. VGA Render Output Controller Integration
    // =========================================================================
    vga_controller snake_display (
        .clk_25Mhz ( vga_clk ),
        .reset     ( reset ),
        .snake_x   ( head_x ),
        .snake_y   ( head_y ),
        .value_x   ( pos_x ),
        .value_y   ( pos_y ),
        .length    ( length ),
        .apple_x   ( curr_apple_x ),
        .apple_y   ( curr_apple_y ),
        .score     ( score ),
        .game_over ( collision ),
        .h_counter ( ),
        .v_counter ( ),
        .h_sync    ( VGA_HS ),
        .v_sync    ( VGA_VS ),
        .vga_r     ( vga_r_4bit ),
        .vga_g     ( vga_g_4bit ),
        .vga_b     ( vga_b_4bit )
    );

endmodule
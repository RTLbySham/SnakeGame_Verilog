`timescale 1ns / 1ps

module Random_Generator (
    output wire [9:0] pos_x_rand, pos_y_rand,
    input  wire       clock_1hz, reset,
    input  wire [19:0] rand_seed,
    input  wire [9:0]  x_apple, y_apple,
    input  wire [7:0]  velocity
);

    reg [19:0] rand_temp;
    reg [8:0]  select;
    reg [9:0]  x, y;
    
    // Maximal-length LFSR feedback polynomial taps: x^20 + x^17 + 1
    wire xor_sum;
    assign xor_sum = rand_temp[19] ^ rand_temp[16];

    always @(posedge clock_1hz or posedge reset) begin
        if (reset) begin
            rand_temp <= (rand_seed != 20'd0) ? rand_seed : 20'd212701;
            x <= 10'd100;
            y <= 10'd100;
        end 
        else begin
            // Shift LFSR
            rand_temp <= {rand_temp[18:0], xor_sum};

            // Basic range scaling
            x <= (rand_temp[9:0] % 640);
            y <= (rand_temp[19:10] % 480);

            // Level Boundary / Obstacle Overwrite Logic
            if (((x < 11 || x > 629) && (y < 121 || y > 359)) ||
                ((x > 159 && x < 181) && (y > 179 && y < 301))) begin
                select = rand_temp[0] ? 9'd11 : 9'd301;
                y <= select + rand_temp[7:1] + rand_temp[11:8];
                x <= 10'd11 + rand_temp[19:11] + rand_temp[10:5];
            end

            if (((x >= 40 && x <= 300) || (x >= 340 && x <= 600)) && (y >= 100 && y <= 105)) begin
                select = rand_temp[13] ? 9'd15 : 9'd385;
                y <= select + rand_temp[15:11] + rand_temp[7:4];
                x <= 10'd105 + rand_temp[12:5] + rand_temp[16:10];
            end

            if (((x >= 235 && x <= 280) || (x >= 335 && x <= 380)) && (y >= 190 && y <= 290) && (velocity >= 8'd4)) begin
                select = rand_temp[7] ? 9'd11 : 9'd585;
                x <= select + rand_temp[8:4] + rand_temp[15:12];
                y <= 10'd130 + rand_temp[19:13] + rand_temp[12:7];
            end
        end
    end

    assign pos_x_rand = x;
    assign pos_y_rand = y;

endmodule

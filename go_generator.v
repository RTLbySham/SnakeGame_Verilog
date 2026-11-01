`timescale 1ns / 1ps

module go_generator (
    input  wire        clk,
    input  wire [9:0]  h_counter,
    input  wire [9:0]  v_counter,
    input  wire        game_over,
    output reg  [11:0] pixel_data  // 12-bit RGB (4-bit Red, 4-bit Green, 4-bit Blue)
);

    // Font ROM Lookup Storage
    reg [15:0] font_rom_out;
    wire [7:0] rom_addr;
    reg  [3:0] char_index;

    // Centered "GAME OVER" Text Region:
    // Screen Resolution: 640 x 480
    // Text Dimensions: 8 characters * 32 pixels wide = 256 pixels wide, 32 pixels high
    // X Range: 192 to 447 | Y Range: 224 to 255
    wire in_game_over_region = game_over && 
                               (v_counter >= 224 && v_counter < 256) && 
                               (h_counter >= 192 && h_counter < 448);

    // 1. Select active letter index (1 to 7) based on Horizontal position
    always @(*) begin
        if (h_counter >= 192 && h_counter < 224)      char_index = 4'd1; // 'G'
        else if (h_counter >= 224 && h_counter < 256) char_index = 4'd2; // 'A'
        else if (h_counter >= 256 && h_counter < 288) char_index = 4'd3; // 'M'
        else if (h_counter >= 288 && h_counter < 320) char_index = 4'd4; // 'E'
        else if (h_counter >= 320 && h_counter < 352) char_index = 4'd5; // 'O'
        else if (h_counter >= 352 && h_counter < 384) char_index = 4'd6; // 'V'
        else if (h_counter >= 384 && h_counter < 416) char_index = 4'd4; // 'E'
        else if (h_counter >= 416 && h_counter < 448) char_index = 4'd7; // 'R'
        else                                          char_index = 4'd0;
    end

    // 2. Map Row Index (0 to 15) scaled down from 32 vertical pixels
    wire [3:0] row_index = (v_counter[4:1] - 4'd16); 
    assign rom_addr = {char_index, row_index};

    // 3. Font Bitmap ROM Table
    always @(posedge clk) begin
        case (rom_addr)
            // Character 1 (G)
            8'b00010000: font_rom_out <= 16'b0000111111110000;
            8'b00010001: font_rom_out <= 16'b0001111111111000;
            8'b00010010: font_rom_out <= 16'b0011100000011100;
            8'b00010011: font_rom_out <= 16'b0110000000001110;
            8'b00010100: font_rom_out <= 16'b0110000000000110;
            8'b00010101: font_rom_out <= 16'b1110000000000111;
            8'b00010110: font_rom_out <= 16'b1100000000000000;
            8'b00010111: font_rom_out <= 16'b1100000000000000;
            8'b00011000: font_rom_out <= 16'b1100000011111111;
            8'b00011001: font_rom_out <= 16'b1100000011111111;
            8'b00011010: font_rom_out <= 16'b1110000000000111;
            8'b00011011: font_rom_out <= 16'b0110000000000110;
            8'b00011100: font_rom_out <= 16'b0111000000001110;
            8'b00011101: font_rom_out <= 16'b0011100000011100;
            8'b00011110: font_rom_out <= 16'b0001111111111000;
            8'b00011111: font_rom_out <= 16'b0000111111110000;

            // Character 2 (A)
            8'b00100000: font_rom_out <= 16'b0000000111000000;
            8'b00100001: font_rom_out <= 16'b0000001111100000;
            8'b00100010: font_rom_out <= 16'b0000011000110000;
            8'b00100011: font_rom_out <= 16'b0000110000011000;
            8'b00100100: font_rom_out <= 16'b0000110000011000;
            8'b00100101: font_rom_out <= 16'b0001100000001100;
            8'b00100110: font_rom_out <= 16'b0011000000001100;
            8'b00100111: font_rom_out <= 16'b0110000000000110;
            8'b00101000: font_rom_out <= 16'b0110000000000110;
            8'b00101001: font_rom_out <= 16'b1111111111111111;
            8'b00101010: font_rom_out <= 16'b1111111111111111;
            8'b00101011: font_rom_out <= 16'b0110000000000110;
            8'b00101100: font_rom_out <= 16'b0110000000000110;
            8'b00101101: font_rom_out <= 16'b0110000000000110;
            8'b00101110: font_rom_out <= 16'b1111000000001111;
            8'b00101111: font_rom_out <= 16'b1111000000001111;

            // Character 3 (M)
            8'b00110000: font_rom_out <= 16'b1110000000000111;
            8'b00110001: font_rom_out <= 16'b1111000000001111;
            8'b00110010: font_rom_out <= 16'b1111100000011111;
            8'b00110011: font_rom_out <= 16'b1101110000111011;
            8'b00110100: font_rom_out <= 16'b1100111001110011;
            8'b00110101: font_rom_out <= 16'b1100011111100011;
            8'b00110110: font_rom_out <= 16'b1100001111000011;
            8'b00110111: font_rom_out <= 16'b1100000110000011;
            8'b00111000: font_rom_out <= 16'b1100000000000011;
            8'b00111001: font_rom_out <= 16'b1100000000000011;
            8'b00111010: font_rom_out <= 16'b1100000000000011;
            8'b00111011: font_rom_out <= 16'b1100000000000011;
            8'b00111100: font_rom_out <= 16'b1100000000000011;
            8'b00111101: font_rom_out <= 16'b1100000000000011;
            8'b00111110: font_rom_out <= 16'b1100000000000011;
            8'b00111111: font_rom_out <= 16'b1100000000000011;

            // Character 4 (E)
            8'b01000000: font_rom_out <= 16'b1111111111111111;
            8'b01000001: font_rom_out <= 16'b1111111111111111;
            8'b01000010: font_rom_out <= 16'b1100000000000000;
            8'b01000011: font_rom_out <= 16'b1100000000000000;
            8'b01000100: font_rom_out <= 16'b1100000000000000;
            8'b01000101: font_rom_out <= 16'b1100000000000000;
            8'b01000110: font_rom_out <= 16'b1111111111111000;
            8'b01000111: font_rom_out <= 16'b1111111111111000;
            8'b01001000: font_rom_out <= 16'b1100000000000000;
            8'b01001001: font_rom_out <= 16'b1100000000000000;
            8'b01001010: font_rom_out <= 16'b1100000000000000;
            8'b01001011: font_rom_out <= 16'b1100000000000000;
            8'b01001100: font_rom_out <= 16'b1100000000000000;
            8'b01001101: font_rom_out <= 16'b1100000000000000;
            8'b01001110: font_rom_out <= 16'b1111111111111111;
            8'b01001111: font_rom_out <= 16'b1111111111111111;

            // Character 5 (O)
            8'b01010000: font_rom_out <= 16'b0011111111111100;
            8'b01010001: font_rom_out <= 16'b0111111111111110;
            8'b01010010: font_rom_out <= 16'b1110000000000111;
            8'b01010011: font_rom_out <= 16'b1100000000000011;
            8'b01010100: font_rom_out <= 16'b1100000000000011;
            8'b01010101: font_rom_out <= 16'b1100000000000011;
            8'b01010110: font_rom_out <= 16'b1100000000000011;
            8'b01010111: font_rom_out <= 16'b1100000000000011;
            8'b01011000: font_rom_out <= 16'b1100000000000011;
            8'b01011001: font_rom_out <= 16'b1100000000000011;
            8'b01011010: font_rom_out <= 16'b1100000000000011;
            8'b01011011: font_rom_out <= 16'b1100000000000011;
            8'b01011100: font_rom_out <= 16'b1100000000000011;
            8'b01011101: font_rom_out <= 16'b1110000000000111;
            8'b01011110: font_rom_out <= 16'b0111111111111110;
            8'b01011111: font_rom_out <= 16'b0011111111111100;

            // Character 6 (V)
            8'b01100000: font_rom_out <= 16'b1100000000000011;
            8'b01100001: font_rom_out <= 16'b1100000000000011;
            8'b01100010: font_rom_out <= 16'b1100000000000011;
            8'b01100011: font_rom_out <= 16'b1100000000000011;
            8'b01100100: font_rom_out <= 16'b1100000000000011;
            8'b01100101: font_rom_out <= 16'b1100000000000011;
            8'b01100110: font_rom_out <= 16'b1100000000000011;
            8'b01100111: font_rom_out <= 16'b1100000000000011;
            8'b01101000: font_rom_out <= 16'b0110000000000110;
            8'b01101001: font_rom_out <= 16'b0110000000000110;
            8'b01101010: font_rom_out <= 16'b0011000000001100;
            8'b01101011: font_rom_out <= 16'b0011000000001100;
            8'b01101100: font_rom_out <= 16'b0001100000011000;
            8'b01101101: font_rom_out <= 16'b0000110000110000;
            8'b01101110: font_rom_out <= 16'b0000011111100000;
            8'b01101111: font_rom_out <= 16'b0000001111000000;

            // Character 7 (R)
            8'b01110000: font_rom_out <= 16'b1111111111111000;
            8'b01110001: font_rom_out <= 16'b1111111111111100;
            8'b01110010: font_rom_out <= 16'b1100000000001110;
            8'b01110011: font_rom_out <= 16'b1100000000000111;
            8'b01110100: font_rom_out <= 16'b1100000000000111;
            8'b01110101: font_rom_out <= 16'b1100000000000111;
            8'b01110110: font_rom_out <= 16'b1100000000001110;
            8'b01110111: font_rom_out <= 16'b1100000000011000;
            8'b01111000: font_rom_out <= 16'b1111111111111000;
            8'b01111001: font_rom_out <= 16'b1111111111100000;
            8'b01111010: font_rom_out <= 16'b1100000011100000;
            8'b01111011: font_rom_out <= 16'b1100000001110000;
            8'b01111100: font_rom_out <= 16'b1100000000111000;
            8'b01111101: font_rom_out <= 16'b1100000000011100;
            8'b01111110: font_rom_out <= 16'b1100000000001110;
            8'b01111111: font_rom_out <= 16'b1100000000000111;

            default:     font_rom_out <= 16'h0000;
        endcase
    end

    // 4. Output Red Text (`12'hF00`) where Bitmap Bit is High
    wire [3:0] bit_index = h_counter[4:1]; // Scale horizontal pixels by 2
    
    always @(*) begin
        if (in_game_over_region && font_rom_out[4'd15 - bit_index]) begin
            pixel_data = 12'hF00; // Bright Red
        end else begin
            pixel_data = 12'h000; // Transparent / Black
        end
    end

endmodule
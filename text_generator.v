`timescale 1ns / 1ps

module text_generator (
    input  wire        clk,
    input  wire [9:0]  h_counter,
    input  wire [9:0]  v_counter,
    input  wire [15:0] score,
    output reg  [11:0] pixel_data  // 12-bit RGB (4 bits Red, 4 bits Green, 4 bits Blue)
);

    // Font ROM Lookup Table
    reg  [7:0] font_rom_out;
    wire [7:0] rom_addr;
    
    // Internal BCD Digit Storage
    reg  [3:0] digit_val;
    integer bcd_i;
    reg  [15:0] bcd_data;

    // 1. Double-Dabble Binary to BCD Converter (16-bit binary -> 4 BCD digits)
    always @(*) begin
        bcd_data = 16'd0;
        for (bcd_i = 15; bcd_i >= 0; bcd_i = bcd_i - 1) begin
            if (bcd_data[3:0]   >= 5) bcd_data[3:0]   = bcd_data[3:0]   + 3;
            if (bcd_data[7:4]   >= 5) bcd_data[7:4]   = bcd_data[7:4]   + 3;
            if (bcd_data[11:8]  >= 5) bcd_data[11:8]  = bcd_data[11:8]  + 3;
            if (bcd_data[15:12] >= 5) bcd_data[15:12] = bcd_data[15:12] + 3;
            bcd_data = {bcd_data[14:0], score[bcd_i]};
        end
    end

    // HUD Display Region: Top-Left (X: 20 to 83 pixels, Y: 10 to 25 pixels)
    wire score_region = (v_counter >= 10 && v_counter < 26) && 
                         (h_counter >= 20 && h_counter < 84);

    // 2. Select Active Digit based on Horizontal Beam Position
    always @(*) begin
        if (h_counter >= 20 && h_counter < 36)
            digit_val = bcd_data[15:12]; // Thousands digit
        else if (h_counter >= 36 && h_counter < 52)
            digit_val = bcd_data[11:8];  // Hundreds digit
        else if (h_counter >= 52 && h_counter < 68)
            digit_val = bcd_data[7:4];   // Tens digit
        else if (h_counter >= 68 && h_counter < 84)
            digit_val = bcd_data[3:0];   // Ones digit
        else
            digit_val = 4'd0;
    end

    // 3. Form Address for ROM (Row index based on v_counter offset)
    wire [3:0] row_index = v_counter[3:0] - 4'd10; 
    assign rom_addr = {digit_val + 4'd1, row_index};

    // 4. Asynchronous / Pure Combinational Font ROM
    always @(*) begin
        case (rom_addr)
            // Number 0
            8'b00010000: font_rom_out = 8'b00111100;
            8'b00010001: font_rom_out = 8'b01111110;
            8'b00010010: font_rom_out = 8'b01100110;
            8'b00010011: font_rom_out = 8'b01100110;
            8'b00010100: font_rom_out = 8'b01100110;
            8'b00010101: font_rom_out = 8'b01100110;
            8'b00010110: font_rom_out = 8'b01100110;
            8'b00010111: font_rom_out = 8'b01100110;
            8'b00011000: font_rom_out = 8'b01111110;
            8'b00011001: font_rom_out = 8'b00111100;

            // Number 1
            8'b00100000: font_rom_out = 8'b00011000;
            8'b00100001: font_rom_out = 8'b00111000;
            8'b00100010: font_rom_out = 8'b01111000;
            8'b00100011: font_rom_out = 8'b00011000;
            8'b00100100: font_rom_out = 8'b00011000;
            8'b00100101: font_rom_out = 8'b00011000;
            8'b00100110: font_rom_out = 8'b00011000;
            8'b00100111: font_rom_out = 8'b00011000;
            8'b00101000: font_rom_out = 8'b01111110;
            8'b00101001: font_rom_out = 8'b01111110;

            // Number 2
            8'b00110000: font_rom_out = 8'b01111100;
            8'b00110001: font_rom_out = 8'b01111110;
            8'b00110010: font_rom_out = 8'b00000110;
            8'b00110011: font_rom_out = 8'b00000110;
            8'b00110100: font_rom_out = 8'b00001100;
            8'b00110101: font_rom_out = 8'b00011000;
            8'b00110110: font_rom_out = 8'b00110000;
            8'b00110111: font_rom_out = 8'b01100000;
            8'b00111000: font_rom_out = 8'b01111100;
            8'b00111001: font_rom_out = 8'b01111110;

            // Number 3
            8'b01000000: font_rom_out = 8'b01111100;
            8'b01000001: font_rom_out = 8'b01111110;
            8'b01000010: font_rom_out = 8'b00000110;
            8'b01000011: font_rom_out = 8'b00000110;
            8'b01000100: font_rom_out = 8'b00111100;
            8'b01000101: font_rom_out = 8'b00111100;
            8'b01000110: font_rom_out = 8'b00000110;
            8'b01000111: font_rom_out = 8'b00000110;
            8'b01001000: font_rom_out = 8'b01111110;
            8'b01001001: font_rom_out = 8'b01111000;

            // Number 4
            8'b01010000: font_rom_out = 8'b00001100;
            8'b01010001: font_rom_out = 8'b00011000;
            8'b01010010: font_rom_out = 8'b00111000;
            8'b01010011: font_rom_out = 8'b01101100;
            8'b01010100: font_rom_out = 8'b11001100;
            8'b01010101: font_rom_out = 8'b11111110;
            8'b01010110: font_rom_out = 8'b11111110;
            8'b01010111: font_rom_out = 8'b00001100;
            8'b01011000: font_rom_out = 8'b00001100;
            8'b01011001: font_rom_out = 8'b00001100;

            // Number 5
            8'b01100000: font_rom_out = 8'b01111110;
            8'b01100001: font_rom_out = 8'b01111110;
            8'b01100010: font_rom_out = 8'b01100000;
            8'b01100011: font_rom_out = 8'b01100000;
            8'b01100100: font_rom_out = 8'b01111100;
            8'b01100101: font_rom_out = 8'b01111110;
            8'b01100110: font_rom_out = 8'b00000110;
            8'b01100111: font_rom_out = 8'b00000110;
            8'b01101000: font_rom_out = 8'b01111110;
            8'b01101001: font_rom_out = 8'b01111100;

            // Number 6
            8'b01110000: font_rom_out = 8'b00111100;
            8'b01110001: font_rom_out = 8'b01111110;
            8'b01110010: font_rom_out = 8'b01100000;
            8'b01110011: font_rom_out = 8'b01100000;
            8'b01110100: font_rom_out = 8'b01111000;
            8'b01110101: font_rom_out = 8'b01111110;
            8'b01110110: font_rom_out = 8'b01100110;
            8'b01110111: font_rom_out = 8'b01100110;
            8'b01111000: font_rom_out = 8'b01111110;
            8'b01111001: font_rom_out = 8'b00111100;

            // Number 7
            8'b10000000: font_rom_out = 8'b01111110;
            8'b10000001: font_rom_out = 8'b01111110;
            8'b10000010: font_rom_out = 8'b00000110;
            8'b10000011: font_rom_out = 8'b00001100;
            8'b10000100: font_rom_out = 8'b00001100;
            8'b10000101: font_rom_out = 8'b00011000;
            8'b10000110: font_rom_out = 8'b00011000;
            8'b10000111: font_rom_out = 8'b00011000;
            8'b10001000: font_rom_out = 8'b00011000;
            8'b10001001: font_rom_out = 8'b00011000;

            // Number 8
            8'b10010000: font_rom_out = 8'b00111100;
            8'b10010001: font_rom_out = 8'b01111110;
            8'b10010010: font_rom_out = 8'b01100110;
            8'b10010011: font_rom_out = 8'b01100110;
            8'b10010100: font_rom_out = 8'b01111110;
            8'b10010101: font_rom_out = 8'b00111100;
            8'b10010110: font_rom_out = 8'b01100110;
            8'b10010111: font_rom_out = 8'b01100110;
            8'b10011000: font_rom_out = 8'b01111110;
            8'b10011001: font_rom_out = 8'b00111100;

            // Number 9
            8'b10100000: font_rom_out = 8'b00111100;
            8'b10100001: font_rom_out = 8'b01111110;
            8'b10100010: font_rom_out = 8'b01100110;
            8'b10100011: font_rom_out = 8'b01100110;
            8'b10100100: font_rom_out = 8'b01111110;
            8'b10100101: font_rom_out = 8'b00111110;
            8'b10100110: font_rom_out = 8'b00000110;
            8'b10100111: font_rom_out = 8'b00000110;
            8'b10101000: font_rom_out = 8'b01111110;
            8'b10101001: font_rom_out = 8'b00111100;

            default:     font_rom_out = 8'b00000000;
        endcase
    end

    // 5. Corrected Relative Bit Index Selection
    // Bit shift calculation handled via case selection to avoid variable-slice synthesis errors
    wire [2:0] bit_index = (h_counter - 10'd20) >> 1;
    reg pixel_on;

    always @(*) begin
        case (bit_index)
            3'd0: pixel_on = font_rom_out[7];
            3'd1: pixel_on = font_rom_out[6];
            3'd2: pixel_on = font_rom_out[5];
            3'd3: pixel_on = font_rom_out[4];
            3'd4: pixel_on = font_rom_out[3];
            3'd5: pixel_on = font_rom_out[2];
            3'd6: pixel_on = font_rom_out[1];
            3'd7: pixel_on = font_rom_out[0];
            default: pixel_on = 1'b0;
        endcase
    end
    
    always @(*) begin
        if (score_region && pixel_on) begin
            pixel_data = 12'hFFF; // White text
        end else begin
            pixel_data = 12'h000; // Transparent / Black
        end
    end

endmodule
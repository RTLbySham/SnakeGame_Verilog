module vga_pll (
    input  wire inclk0,
    output wire c0
);
    altpll #(
        .inclk0_input_frequency(20000), // 50 MHz input (20,000 ps period)
        .operation_mode("NORMAL"),
        .clk0_multiply_by(1007),
        .clk0_divide_by(2000)           // Generates 25.175 MHz pixel clock output
    ) altpll_component (
        .inclk ({1'b0, inclk0}),
        .clk   ({c0})
    );
endmodule

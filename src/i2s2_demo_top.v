module i2s2_demo_top (
    input wire mclk,        // 22.579 MHz master clock
    input wire locked,      // Indicates the clocking wizard output is stable

    input wire resetn,      // Active low reset

    input wire sdin,        // Serial data input from ADC

    output wire sclk,       // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    output wire lrclk,      // Left-right clock toggling every 32 sclk periods (44.1 kHz)

    output wire sdout       // Serial data output to DAC
    );

    wire rst_n_sync;

    i2s_clocks i2s_clocks (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync)
    );

    // Send the input data straight to the output data
    assign sdout = sdin && rst_n_sync;  // Output data is 0 when in reset or clocking wizard is not locked
    

endmodule
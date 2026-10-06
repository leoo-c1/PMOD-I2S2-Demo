`timescale 1ns/1ps

module tb_i2s_clocks;
    reg mclk;               // 22.5792 MHz master clock
    reg locked;             // Indicates the clocking wizard output is stable

    reg resetn;             // Active low reset

    wire sclk;              // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    wire sclk_pre_rise;     // Pulses for one mclk cycle before rising edge of sclk
    wire sclk_pre_fall;     // Pulses for one mclk cycle before falling edge of sclk

    wire lrclk;             // Left-right clock toggling every 32 sclk periods (44.1 kHz)

    wire rst_n_sync;        // Low when either system is in reset or clocking wizard is not stable

    wire [4:0] sd_count;    // 0 = MSB, 23 = LSB (24-31 is padding)
    wire sd_valid;          // High when sd_count is between 0 and 23, low during padding

    i2s_clocks clock_test (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk),
        .sclk_pre_rise(sclk_pre_rise), .sclk_pre_fall(sclk_pre_fall),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_count(sd_count), .sd_valid(sd_valid)
    );

    always begin
        #22.144 mclk = ~mclk;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb_i2s_clocks);

        resetn = 0;
        locked = 0;
        mclk = 0;

        #50;
        resetn = 1;

        #20; locked = 1;

        #100000
        $finish;
    end

endmodule
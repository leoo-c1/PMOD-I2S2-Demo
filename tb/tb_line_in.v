`timescale 1ns/1ps

module tb_line_in;
    reg mclk;               // 22.5792 MHz master clock
    reg sclk_rise;          // Pulses for one mclk cycle on rising edge of sclk
    reg lrclk;              // Left-right clock, 1 = right, 0 = left

    reg resetn;             // Active low reset            
    reg rst_n_sync;         // Low when either system is in reset or clocking wizard is not stable

    reg sd_adc;             // Serial data from ADC
    reg [4:0] sd_count;     // 23 = MSB, 0 = LSB
    reg sd_valid;           // High when sd_count is between 23 and 0, low during padding

    wire [23:0] left_data;  // 24-bit data on the left channel
    wire left_ready;        // Pulses for one mclk cycle when bit 0 in left channel is filled
    wire [23:0] right_data; // 24-bit data on the right channel
    wire right_ready;       // Pulses for one mclk cycle when bit 0 in right channel is filled

    reg locked = 1'b0;
    reg sclk;
    reg sclk_rise;
    reg sclk_fall;
    reg lrclk;

    i2s_clocks clock_test (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk),
        .sclk_rise(sclk_rise), sclk_fall(sclk_fall),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_count(sd_count), sd_valid(sd_valid)
    );

    line_in input_test (
        .mclk(mclk),
        .sclk_rise(sclk_rise),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_adc(sd_adc),
        .sd_count(sd_count), .sd_valid(sd_valid),
        .left_data(left_data), .left_ready(left_ready),
        .right_data(right_data), .right_ready(right_ready)
    );

    always begin
        #22.144 mclk = ~mclk;
    end

    initial begin
        $dumpfile("tb_line_in.vcd");
        $dumpvars(0, tb_line_in);

        resetn = 0;
        locked = 0;
        mclk = 0;

        #50;
        resetn = 1;

        #20; locked = 1;

        #100
        $finish;
    end

endmodule
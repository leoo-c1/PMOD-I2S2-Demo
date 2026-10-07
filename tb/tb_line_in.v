`timescale 1ns/1ps

module tb_line_in;
    reg mclk;               // 22.5792 MHz master clock
    reg sclk_pre_rise;      // Pulses for one mclk cycle before rising edge of sclk
    reg lrclk;              // Left-right clock, 1 = right, 0 = left

    reg rst_n_sync;         // Low when either system is in reset or clocking wizard is not stable

    reg sd_adc;             // Serial data from ADC
    reg [4:0] sd_count;     // 0 = MSB, 23 = LSB
    reg sd_valid;           // High when sd_count is between 23 and 0, low during padding

    wire [23:0] left_data;  // 24-bit data on the left channel
    wire [23:0] right_data; // 24-bit data on the right channel

    reg locked;
    reg resetn;
    reg sclk;

    i2s_clocks clock_test (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk),
        .sclk_pre_rise(sclk_pre_rise), .sclk_pre_fall(),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_count(sd_count), .sd_valid(sd_valid)
    );

    line_in input_test (
        .mclk(mclk),
        .sclk_pre_rise(sclk_pre_rise),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_adc(sd_adc),
        .sd_count(sd_count), .sd_valid(sd_valid),
        .left_data(left_data), .right_data(right_data)
    );

    always begin
        #10 mclk = ~mclk; // Just going to assume mclk has 20ns period instead of 44.289ns
        // This means serial clock toggles every 80ns and lrclk toggles every 10240ns
    end

    initial begin
        $dumpfile("tb_line_in.vcd");
        $dumpvars(0, tb_line_in);

        resetn = 0;
        locked = 0;
        mclk = 0;
        sd_adc = 0;

        #50;
        resetn = 1;

        #20; locked = 1;

        @ (posedge lrclk);
        send_sample(24'hABCDEF);    // Right channel frame
        @ (negedge lrclk);
        send_sample(24'h123456);    // Left channel frame
        #1000;

        $finish;
    end

    task send_sample(input [23:0] sample);
        integer i;
        begin
            @(negedge sclk);
            for (i = 23; i >= 0; i = i - 1) begin
                sd_adc = sample[i];
                @(negedge sclk);
            end
            sd_adc = 1'b0;  // Send padding
        end
    endtask

endmodule
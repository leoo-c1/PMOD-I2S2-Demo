`timescale 1ns/1ps

module tb_line_out;
    reg mclk;               // 22.5792 MHz master clock
    reg sclk_pre_fall;      // Pulses for one mclk cycle before rising edge of sclk
    reg lrclk;              // Left-right clock, 1 = right, 0 = left

    reg rst_n_sync;         // Low when either system is in reset or clocking wizard is not stable

    reg [23:0] left_data;   // 24-bit data on the left channel
    reg [23:0] right_data;  // 24-bit data on the right channel
    reg [4:0] sd_count;     // 0 = MSB, 23 = LSB

    wire sd_dac;

    reg locked;
    reg resetn;
    reg sclk;

    i2s_clocks clock_test (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk),
        .sclk_pre_rise(), .sclk_pre_fall(sclk_pre_fall),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_count(sd_count), .sd_valid()
    );

    line_out output_test (
        .mclk(mclk),
        .sclk_pre_fall(sclk_pre_fall),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .left_data(left_data), .right_data(right_data),
        .sd_count(sd_count),
        .sd_dac(sd_dac)
    );

    always begin
        #10 mclk = ~mclk; // Just going to assume mclk has 20ns period instead of 44.289ns
        // This means serial clock toggles every 80ns and lrclk toggles every 10240ns
    end

    initial begin
        $dumpfile("tb_line_out.vcd");
        $dumpvars(0, tb_line_out);

        resetn = 0;
        locked = 0;
        mclk = 0;

        #50;
        resetn = 1;

        #20; locked = 1;

        @ (posedge lrclk);
        receive_data(24'hDADBAD, 1);
        receive_data(24'h1A2B3C, 0);
        #1000;

        $finish;
    end

    task receive_data(input [23:0] data, input channel); // Channel = 1 means right, channel = 0 means left
        integer i;
        begin
            wait (sd_count == 23);
            @ (posedge sclk);
            if (channel) right_data = data;
            else
                left_data = data;
        end
    endtask

endmodule
`timescale 1ns/1ps

module tb_i2s2_demo_top;
    reg mclk;        // 22.5792 MHz master clock
    reg locked;      // Indicates the clocking wizard output is stable

    reg resetn;      // Active low reset

    reg sd_adc;      // Serial data from ADC

    wire mclk_adc;   // 22.5792 MHz master clock output to ADC
    wire mclk_dac;   // 22.5792 MHz master clock output to DAC

    // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    wire sclk_adc;   // To ADC
    wire sclk_dac;   // To DAC

    // Left-right clock toggling every 32 sclk periods (44.1 kHz)
    wire lrclk_adc;  // To ADC
    wire lrclk_dac;  // To DAC

    wire sd_dac;     // Serial data to DAC

    // Interconnects
    reg sclk;
    reg sclk_pre_rise;
    reg sclk_pre_fall;
    reg lrclk;
    reg rst_n_sync;
    reg [4:0] sd_count;
    reg sd_valid;
    reg [23:0] left_data;
    reg [23:0] right_data;

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
        $dumpfile("tb_i2s2_demo_top.vcd");
        $dumpvars(0, tb_i2s2_demo_top);

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
        @ (posedge lrclk);
        send_sample(24'hFF00FF);    // Right channel frame
        @ (negedge lrclk);
        send_sample(24'h00FF00);    // Left channel frame
        #50000;

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
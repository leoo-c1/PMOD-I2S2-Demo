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

    i2s2_demo_top top_level_test (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sd_adc(sd_adc),
        .mclk_adc(mclk_adc), .mclk_dac(mclk_dac),
        .sclk_adc(sclk_adc), .sclk_dac(sclk_dac),
        .lrclk_adc(lrclk_adc), .lrclk_dac(lrclk_dac),
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

        @ (posedge lrclk_adc);
        send_sample(24'hABCDEF);    // Right channel frame
        @ (negedge lrclk_adc);
        send_sample(24'h123456);    // Left channel frame
        @ (posedge lrclk_adc);
        send_sample(24'hFF00FF);    // Right channel frame
        @ (negedge lrclk_adc);
        send_sample(24'h00FF00);    // Left channel frame
        #50000;

        $finish;
    end

    task send_sample(input [23:0] sample);
        integer i;
        begin
            @(negedge sclk_adc);
            for (i = 23; i >= 0; i = i - 1) begin
                sd_adc = sample[i];
                @(negedge sclk_adc);
            end
            sd_adc = 1'b0;  // Send padding
        end
    endtask

endmodule
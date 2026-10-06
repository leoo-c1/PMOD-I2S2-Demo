module line_out (
    input wire mclk,                // 22.5792 MHz master clock
    input wire sclk_fall,           // Pulses for one mclk cycle on falling edge of sclk
    input wire lrclk,               // Left-right clock, 1 = right, 0 = left
    input wire lrclk_pre_change,    // Pulses for the mclk cycle before lrclk inverts

    input wire rst_n_sync           // Low when either system is in reset or clocking wizard is not stable

    input wire [23:0] left_data,    // 24-bit data on the left channel
    input wire last_left,           // Pulses for one mclk cycle when bit 0 in left channel is filled
    input wire [23:0] right_data,   // 24-bit data on the right channel
    input wire last_right,          // Pulses for one mclk cycle when bit 0 in right channel is filled

    output reg sd_dac               // Serial data to DAC
    );

    always @ (posedge mclk) begin
        if (!rst_n_sync) begin
            sd_dac <= 1'b0;
        end else begin
            if (sclk_fall) begin
                if (last_right)
            end
        end
    end

endmodule
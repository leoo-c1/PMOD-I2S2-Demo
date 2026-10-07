module line_out (
    input wire mclk,                // 22.5792 MHz master clock
    input wire sclk_pre_fall,       // Pulses for one mclk cycle before falling edge of sclk
    input wire lrclk,               // Left-right clock, 1 = right, 0 = left

    input wire rst_n_sync,          // Low when either system is in reset or clocking wizard is not stable

    input wire [23:0] left_data,    // 24-bit data on the left channel
    input wire [23:0] right_data,   // 24-bit data on the right channel

    input wire [4:0] sd_count,      // 0 = MSB, 23 = LSB (24-31 is padding)

    output reg sd_dac               // Serial data to DAC
    );

    always @ (posedge mclk) begin
        if (!rst_n_sync) begin
            sd_dac <= 1'b0;
        end else begin
            if (sclk_pre_fall) begin
                if (sd_count == 5'd31) begin
                    if (lrclk)
                        sd_dac <= right_data[23];
                    else
                        sd_dac <= left_data[23];
                end else if ((sd_count >= 5'b0) && (sd_count <= 5'd22)) begin
                    if (lrclk)
                        // sd31: id23, sd0: id22, 1: 21, 2: 20
                        sd_dac <= right_data[5'd22 - sd_count];
                    else
                        sd_dac <= left_data[5'd22 - sd_count];
                end else begin
                    // When receiving padding, put 0s on dac
                    sd_dac <= 1'b0;
                end
            end
        end
    end

endmodule
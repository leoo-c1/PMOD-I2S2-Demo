module line_in (
    input wire mclk,                // 22.5792 MHz master clock
    input wire sclk_pre_rise,       // Pulses for one mclk cycle before rising edge of sclk
    input wire lrclk,               // Left-right clock, 1 = right, 0 = left

    input wire rst_n_sync,          // Low when either system is in reset or clocking wizard is not stable

    input wire sd_adc,              // Serial data from ADC
    input wire [4:0] sd_count,      // 23 = MSB, 0 = LSB
    input wire sd_valid,            // High when sd_count is between 23 and 0, low during padding

    output reg [23:0] left_data,    // 24-bit data on the left channel
    output reg last_left,           // Pulses for one mclk cycle when LSB in left channel is filled
    output reg [23:0] right_data,   // 24-bit data on the right channel
    output reg last_right           // Pulses for one mclk cycle when LSB in right channel is filled
   );

    reg [23:0] temp_data = 24'b0;   // Temporary vector to hold samples

    always @ (posedge mclk) begin
        if (!rst_n_sync) begin
            left_data <= 24'b0;
            last_left <= 1'b0;
            right_data <= 24'b0;
            last_right <= 1'b0;
            temp_data <= 24'b0;
        end else begin
            last_left <= 1'b0;
            last_right <= 1'b0;
            if (sclk_pre_rise && sd_valid) begin    // On the rising edge of sclk
                temp_data[5'd23 - sd_count] <= sd_adc;  // Fill temporary vector over time
            
                // On final bit, update left or right data
                if (sd_count == 'b23) begin
                    if (lrclk)
                        right_data <= {temp_data[23:1], sd_adc};
                        last_right <= 1'b1;
                    else begin
                        left_data <= {temp_data[23:1], sd_adc};
                        last_left <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
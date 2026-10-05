module line_in (
    input wire mclk,                // 22.5792 MHz master clock

    input wire sd_adc,              // Serial data from ADC
    input wire [4:0] sd_count,      // 23 = MSB, 0 = LSB
    input wire sd_valid,            // High when sd_count is between 23 and 0, low during padding

    input wire sclk_rise,           // High for one mclk cycle starting from rising edge of sclk
    input wire lrclk,               // Left-right clock, 1 = right, 0 = left

    input wirerst_n_sync,           // Low when either system is in reset or clocking wizard is not stable

    output reg [23:0] left_data,    // 24-bit data on the left channel
    output reg [23:0] right_data,   // 24-bit data on the right channel
    output reg data_ready           // Pulses for one mclk cycle when 24-bit data is ready
   );

    reg [23:0] temp_data = 24'b0;   // Temporary vector to hold samples

    always @ (posedge mclk) begin
        if (!rst_n_sync) begin
            left_data <= 24'b0;
            right_data <= 24'b0;
            data_ready <= 1'b0;
            temp_data <= 24'b0;
        end else begin
            data_ready <= 1'b0;
            if (sclk_rise && sd_valid) begin    // On the rising edge of sclk, read valid serial data
                temp_data[sd_count] <= sd_adc;  // Fill temporary vector over time
            
                // On final bit, update left or right data
                if (sd_count == 'b0) begin
                    if (lrclk)
                        right_data <= {temp_data[23:1], sd_adc};
                    else begin
                        left_data <= {temp_data[23:1], sd_adc};
                        data_ready <= 1'b1;     // Pulse data_ready on last bit of data
                    end
                end
            end
        end
    end

endmodule
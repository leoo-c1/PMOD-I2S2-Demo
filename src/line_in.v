module line_in (
    input wire mclk,                // 22.5792 MHz master clock

    input wire sd_adc,              // Serial data from ADC
    input wire [4:0] sd_count,      // 23 = MSB, 0 = LSB
    input wire sd_valid,            // High when sd_count is between 23 and 0, low during padding

    input wire sclk_rise,           // High for one mclk cycle starting from rising edge of sclk
    input wire lrclk,               // Left-right clock, 1 = right, 0 = left

    input rst_n_sync,               // Low when either system is in reset or clocking wizard is not stable

    output reg [23:0] left_data,    // 24-bit data on the left channel
    output reg [23:0] right_data,   // 24-bit data on the right channel
    output reg data_ready           // Pulses for one mclk cycle when 24-bit data is ready
   );

    

endmodule
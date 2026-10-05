module line_out (
    input wire mclk,                // 22.5792 MHz master clock
    input wire sclk_fall,           // Pulses for one mclk cycle on falling edge of sclk
    input wire lrclk,               // Left-right clock, 1 = right, 0 = left

    input wire rst_n_sync           // Low when either system is in reset or clocking wizard is not stable

    input wire [23:0] left_data,    // 24-bit data on the left channel
    input wire left_ready,          // Pulses for one mclk cycle when left channel data is ready
    input wire [23:0] right_data,   // 24-bit data on the right channel
    input wire right_ready,         // Pulses for one mclk cycle when right channel data is ready

    output reg sd_dac               // Serial data to DAC
    );

    always @ (posedge mclk) begin
        if (!rst_n_sync) begin
            sd_dac <= 1'b0;
        end else begin
            
        end
    end

endmodule
module i2s_clocks (
    input wire mclk,            // 22.5792 MHz master clock
    input wire locked,          // Indicates the clocking wizard output is stable

    input wire resetn,          // Active low reset

    output reg sclk,            // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    output reg sclk_rise,       // Pulses for one mclk cycle on rising edge of sclk
    output reg sclk_fall,       // Pulses for one mclk cycle on falling edge of sclk
    output reg lrclk,           // Left-right clock toggling every 32 sclk periods (44.1 kHz)

    output wire rst_n_sync,     // Low when either system is in reset or clocking wizard is not stable

    output wire [4:0] sd_count, // 0 = MSB, 23 = LSB (24-31 is padding)
    output wire sd_valid        // High when sd_count is between 0 and 23, low during padding
    );

    reg [1:0] mclk_count = 2'b0;    // Counts 4 mclk periods to generate serial clock
    reg [4:0] sclk_count = 5'b0;    // Counts 32 sclk periods to generate lrclk

    // Double flopping to avoid metastability
    reg rst_n_sync_1 = 1'b0;
    reg rst_n_sync_2 = 1'b0;

    wire rst_n_async;
    assign rst_n_async = resetn && locked;
    assign rst_n_sync = rst_n_sync_2;

    // Generate sd_count, it should just be sclk_count delayed by 1 clock cycle
    assign sd_count = sclk_count - 1'b1;

    // Generate sd_valid
    assign sd_valid = (sd_count >= 5'd0) && (sd_count <= 5'd23);

    always @ (posedge mclk) begin
        rst_n_sync_1 <= rst_n_async;
        rst_n_sync_2 <= rst_n_sync_1;

        if (!rst_n_sync_2) begin
            mclk_count <= 2'b0;
            sclk_count <= 5'b0;
            sclk <= 1'b0;
            sclk_rise <= 1'b0;
            sclk_fall <= 1'b0;
            lrclk <= 1'b0;
        end else begin
            if (mclk_count < 'd3) begin
                mclk_count <= mclk_count + 1'b1;
                sclk_rise <= 1'b0;
                sclk_fall <= 1'b0;

            // 4 periods of mclk have passed so invert sclk
            end else begin
                sclk <= ~sclk;
                sclk_rise <= (sclk == 1'b0) ? 1'b1 : 1'b0;
                sclk_fall <= (sclk == 1'b1) ? 1'b1 : 1'b0;
                mclk_count <= 2'b0;

                // Check if 32 sclk periods have occurred for lrclk to be inverted
                if (sclk_count >= 5'd31) begin
                    // Invert lrclk
                    lrclk <= ~lrclk;
                    sclk_count <= 5'b0;
                end else begin
                    sclk_count <= sclk_count + (sclk == 1'b1);  // Increment sclk_count on every falling edge of sclk
                end
            end
        end
    end

endmodule
module i2s_clocks (
    input wire mclk,        // 22.5792 MHz master clock
    input wire locked,      // Indicates the clocking wizard output is stable

    input wire resetn,      // Active low reset

    output reg sclk,        // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    output reg lrclk,       // Left-right clock toggling every 32 sclk periods (44.1 kHz)

    output wire rst_n_sync  // Low when either system is in reset or clocking wizard is not stable
    );

    reg [1:0] mclk_count = 'b0;     // Counts 4 mclk periods to generate serial clock
    reg [5:0] sclk_count = 'b0;     // Counts 64 sclk inversions to generate lrclk

    // Double flopping to avoid metastability
    reg rst_n_sync_1 = 1'b0;
    reg rst_n_sync_2 = 1'b0;

    wire rst_n_async;
    assign rst_n_async = resetn && locked;
    assign rst_n_sync = rst_n_sync_2;

    always @ (posedge mclk) begin
        rst_n_sync_1 <= rst_n_async;
        rst_n_sync_2 <= rst_n_sync_1;

        if (!rst_n_sync_2) begin
            mclk_count <= 'b0;
            sclk_count <= 'b0;
            sclk <= 1'b0;
            lrclk <= 1'b0;
        end else begin
            if (mclk_count < 'd3) begin
                mclk_count <= mclk_count + 1'b1;
            end else if (sclk_count >= 'd63) begin
                sclk <= ~sclk;
                lrclk <= ~lrclk;
                mclk_count <= 'b0;
                sclk_count <= 'b0;
            end else begin
                sclk <= ~sclk;
                mclk_count <= 'b0;
                sclk_count <= sclk_count + 1'b1;
            end
        end
    end

endmodule
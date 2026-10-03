module i2s_clocks (
    input wire mclk,        // 22.579 MHz master clock
    input wire locked_in,   // Indicates the clocking wizard output is stable

    input wire resetn,      // Active low reset

    output reg sclk,        // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    output reg lrclk,       // Left-right clock toggling every 32 sclk periods (44.1 kHz)

    output wire locked_out   // Indicates clocking wizard output is stable
    );

    assign locked_out = locked_in;  // Pass-through

    reg [1:0] mclk_count = 'b0;     // Counts 4 mclk periods to generate serial clock
    reg [5:0] sclk_count = 'b0;     // Counts 64 sclk inversions to generate lrclk

    always @ (posedge mclk) begin
        if (!resetn) begin
            mclk_count <= 'b0;
            sclk_count <= 'b0;
            sclk <= 1'b0;
            lrclk <= 1'b0;
        end else begin
            if (mclk_count < 'd3) begin
                mclk_count <= mclk_count + 1'b1;
            end else begin
                sclk <= ~sclk;
                mclk_count <= 'b0;
                sclk_count <= sclk_count + 1'b1;
            end

            if (sclk_count >= 'd63) begin
                lrclk <= ~lrclk;
                sclk_count <= 'b0;
            end
        end
    end

endmodule
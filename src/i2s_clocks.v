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

    // Used for double flopping to avoid metastability
    reg resetn_1;
    reg resetn_2;
    reg lockin_in_1;
    reg lockin_in_2;

    always @ (posedge mclk) begin
        resetn_1 <= resetn;
        resetn_2 <= resetn_1;
        reg lockin_in_1 <= locked_in;
        reg lockin_in_2 <= locked_in_1;

        if (!resetn_2 || !locked_in_2) begin
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
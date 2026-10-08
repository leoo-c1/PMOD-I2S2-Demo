module i2s2_demo_top (
    input wire mclk,        // 22.5792 MHz master clock
    input wire locked,      // Indicates the clocking wizard output is stable

    input wire resetn,      // Active low reset

    input wire sd_adc,      // Serial data from ADC

    output wire mclk_adc,   // 22.5792 MHz master clock output to ADC
    output wire mclk_dac,   // 22.5792 MHz master clock output to DAC

    // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    output wire sclk_adc,   // To ADC
    output wire sclk_dac,   // To DAC

    // Left-right clock toggling every 32 sclk periods (44.1 kHz)
    output wire lrclk_adc,  // To ADC
    output wire lrclk_dac,  // To DAC

    output wire sd_dac      // Serial data to DAC
    );

    wire rst_n_sync;

    wire sclk_pre_fall;
    wire sclk_pre_rise;

    wire lrclk;

    wire sd_valid;
    wire [4:0] sd_count;

    wire [23:0] left_data;
    wire [23:0] right_data;

    i2s_clocks i2s_clocks (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk_adc),
        .sclk_pre_rise(sclk_pre_rise), .sclk_pre_fall(sclk_pre_fall),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync),
        .sd_count(sd_count), .sd_valid(sd_valid)
    );

    assign sclk_dac = sclk_adc;
    assign lrclk_adc = lrclk;
    assign lrclk_dac = lrclk;

    // Input data from ADC
    line_in line_in (
        .mclk(mclk),
        .sclk_pre_rise(sclk_pre_rise),
        .lrclk(lrclk_adc),
        .rst_n_sync(rst_n_sync),
        .sd_adc(sd_adc),
        .sd_count(sd_count), .sd_valid(sd_valid),
        .left_data(left_data), .right_data(right_data)
    );

    // Route input data straight to output DAC
    // Output data to DAC
    line_out line_out (
        .mclk(mclk),
        .sclk_pre_fall(sclk_pre_fall),
        .lrclk(lrclk_dac),
        .rst_n_sync(rst_n_sync),
        .left_data(left_data), .right_data(right_data),
        .sd_count(sd_count),
        .sd_dac(sd_dac)
    );
    
   // ODDRE1: Dedicated Double Data Rate (DDR) Output Register
   //         Zynq UltraScale+ MPSoC/RFSoC
   // Xilinx HDL Language Template, version 2025.2

   ODDRE1 #(
      .IS_C_INVERTED(1'b0),           // Optional inversion for C
      .IS_D1_INVERTED(1'b0),          // Unsupported, do not use
      .IS_D2_INVERTED(1'b0),          // Unsupported, do not use
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                      // ULTRASCALE_PLUS_ES2)
      .SRVAL(1'b0)                    // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
   )
   ODDRE1_mclk_to_adc (
      .Q(mclk_adc),   // 1-bit output: Data output to IOB
      .C(mclk),   // 1-bit input: High-speed clock input
      .D1(1'b1), // 1-bit input: Parallel data input 1
      .D2(1'b0), // 1-bit input: Parallel data input 2
      .SR(~rst_n_sync)  // 1-bit input: Active-High Async Reset
   );

   ODDRE1 #(
      .IS_C_INVERTED(1'b0),           // Optional inversion for C
      .IS_D1_INVERTED(1'b0),          // Unsupported, do not use
      .IS_D2_INVERTED(1'b0),          // Unsupported, do not use
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
                                      // ULTRASCALE_PLUS_ES2)
      .SRVAL(1'b0)                    // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
   )
   ODDRE1_mclk_to_dac (
      .Q(mclk_dac),   // 1-bit output: Data output to IOB
      .C(mclk),   // 1-bit input: High-speed clock input
      .D1(1'b1), // 1-bit input: Parallel data input 1
      .D2(1'b0), // 1-bit input: Parallel data input 2
      .SR(~rst_n_sync)  // 1-bit input: Active-High Async Reset
   );

   // End of ODDRE1_inst instantiation
    

endmodule
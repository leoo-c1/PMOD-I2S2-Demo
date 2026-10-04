module i2s2_demo_top (
    input wire mclk,        // 22.5792 MHz master clock
    input wire locked,      // Indicates the clocking wizard output is stable

    input wire resetn,      // Active low reset

    input wire sd_adc,      // Serial data from ADC

    output wire mclk_adc,   // 22.5792 MHz master clock output to ADC
    output wire mclk_dac,   // 22.5792 MHz master clock output to DAC
    output wire sclk,       // Serial clock toggling every 4 mclk periods (2.8224 MHz)
    output wire lrclk,      // Left-right clock toggling every 32 sclk periods (44.1 kHz)

    output wire sd_dac      // Serial data to DAC
    );

    wire rst_n_sync;

    i2s_clocks i2s_clocks (
        .mclk(mclk),
        .locked(locked),
        .resetn(resetn),
        .sclk(sclk),
        .lrclk(lrclk),
        .rst_n_sync(rst_n_sync)
    );

    // Send the input data straight to the output data
    assign sd_dac = sd_adc && rst_n_sync;   // Output data is 0 when in reset or clk wizard is not locked

    
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
      .Q(mclk_out_adc),   // 1-bit output: Data output to IOB
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
      .Q(mclk_out_dac),   // 1-bit output: Data output to IOB
      .C(mclk),   // 1-bit input: High-speed clock input
      .D1(1'b1), // 1-bit input: Parallel data input 1
      .D2(1'b0), // 1-bit input: Parallel data input 2
      .SR(~rst_n_sync)  // 1-bit input: Active-High Async Reset
   );

   // End of ODDRE1_inst instantiation
    

endmodule
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Sun Oct  4 23:17:25 2026
//Host        : Leos_Laptop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (lrclk_adc,
    lrclk_dac,
    mclk_adc,
    mclk_dac,
    sclk_adc,
    sclk_dac,
    sd_adc,
    sd_dac);
  output lrclk_adc;
  output lrclk_dac;
  output mclk_adc;
  output mclk_dac;
  output sclk_adc;
  output sclk_dac;
  input sd_adc;
  output sd_dac;

  wire lrclk_adc;
  wire lrclk_dac;
  wire mclk_adc;
  wire mclk_dac;
  wire sclk_adc;
  wire sclk_dac;
  wire sd_adc;
  wire sd_dac;

  design_1 design_1_i
       (.lrclk_adc(lrclk_adc),
        .lrclk_dac(lrclk_dac),
        .mclk_adc(mclk_adc),
        .mclk_dac(mclk_dac),
        .sclk_adc(sclk_adc),
        .sclk_dac(sclk_dac),
        .sd_adc(sd_adc),
        .sd_dac(sd_dac));
endmodule

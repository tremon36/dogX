`timescale 1ns / 1ps

module DOGX_digital_TOP (
    input wire CLK_24M,
    input wire CLK_3M,
    input wire reset,
    input wire [8:0] counter_HSNR_p,
    input wire [8:0] counter_HSNR_n,
    input wire [8:0] counter_HDR_p,
    input wire [8:0] counter_HDR_n,
    input wire [8:0] alpha_th_high,
    input wire [8:0] alpha_th_low,
    input wire [4:0] alpha_timeout_mask,
    input wire alpha_in,
    output wire alpha_out,
    output wire [10:0] converter_output
);

  // HDR and HSNR channels

  logic [8:0] HSNR_output;
  logic [8:0] HDR_output;

  logic [10:0] HSNR_output_extended;
  logic [10:0] HDR_output_extended;

  datapath #(
      .N_BITS_ACC_EXT(3)
  ) HSNR_datapath (
      .CLK_3M(CLK_3M),
      .CLK_24M(CLK_24M),
      .reset(reset),
      .counter_p(counter_HSNR_p),
      .counter_n(counter_HSNR_n),
      .channel_output(HSNR_output)
  );

  datapath #(
      .N_BITS_ACC_EXT(3)
  ) HDR_datapath (
      .CLK_3M(CLK_3M),
      .CLK_24M(CLK_24M),
      .reset(reset),
      .counter_p(counter_HDR_p),
      .counter_n(counter_HDR_n),
      .channel_output(HDR_output)
  );

  always_comb begin
    HSNR_output_extended = { {2{HSNR_output[8]}}, HSNR_output };
    HDR_output_extended  = {HDR_output, 2'b00};
  end

  // Now alpha logic

  logic alpha_internal;
  assign alpha_out = alpha_internal;

  alpha_block_v2 alpha_gen (
      .clk(CLK_24M),
      .reset(reset),
      .hdr_current_value(HDR_output),
      .threshold_high(alpha_th_high),
      .threshold_low(alpha_th_low),
      .timeout_mask(alpha_timeout_mask),
      .alpha(alpha_internal)
  );


  // Generate converter output with alpha

  logic [10:0] converter_output_internal;
  assign converter_output = converter_output_internal;

  always_comb begin
    if (alpha_in) begin
      converter_output_internal = HDR_output_extended;
    end else begin
      converter_output_internal = HSNR_output_extended;
    end
  end


endmodule

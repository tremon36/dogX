`timescale 1ns / 1ps

module alpha_block_v2 (
    input wire clk,
    input wire enable_sampling,
    input wire reset,
    input wire [8:0] hdr_current_value,
    input wire [8:0] threshold_high,
    input wire [8:0] threshold_low,
    input wire [4:0] timeout_mask,
    output wire alpha
);

  logic [8:0] hdr_absolute_value;
  logic alpha_l;

  assign alpha = alpha_l;

  // Compute absolute value

  always_comb begin
    if ($signed(hdr_current_value) < 0) begin
      hdr_absolute_value = -hdr_current_value;
    end else begin
      hdr_absolute_value = hdr_current_value;
    end
  end

  // Set alpha accordingly

  logic [17:0] timeout_current_value;
  logic count_enable;
  logic reset_count;


  always_ff @(posedge clk or negedge reset) begin

    if (!reset) begin
      timeout_current_value <= 0;
    end else begin
      if(enable_sampling) begin
      if (reset_count) timeout_current_value <= 0;
      else if (count_enable) timeout_current_value <= timeout_current_value + 1;
      end
    end
  end

  logic above_threshold;
  logic below_threshold;
  logic timeout_condition_under_th;

  always_comb begin

    above_threshold = $unsigned(hdr_absolute_value) > $unsigned(threshold_high);
    below_threshold = $unsigned(hdr_absolute_value) < $unsigned(threshold_low);
    timeout_condition_under_th = (|(timeout_current_value[17:13] & timeout_mask));
    alpha_l = ~timeout_condition_under_th;

    if (above_threshold) begin
      reset_count  = 1'b1;
      count_enable = 1'b0;
    end else begin
      if (below_threshold) begin
        reset_count = 1'b0;
        if (timeout_condition_under_th) count_enable = 1'b0;
        else count_enable = 1'b1;
      end else begin
        reset_count  = 1'b0;
        count_enable = 1'b0;
      end
    end
  end

endmodule

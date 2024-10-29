`timescale 1ns/1ps

module alpha_block (
    input wire clk,
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

  logic[4:0] timeout_current_value;

  enum logic [1:0] {
    HSNR_MODE,
    HDR_MODE_ABOVE_TH,
    HDR_MODE_UNDER_TH
  } current_state,next_state;


  always_ff @(posedge clk or negedge reset) begin
    if(!reset) begin
        current_state <= HSNR_MODE;
        timeout_current_value <= 0;
    end else begin

        current_state <= next_state;

        unique case (current_state)
        HSNR_MODE : begin
            timeout_current_value <= 5'b0;
        end
        HDR_MODE_ABOVE_TH: begin
            timeout_current_value <= 5'b0;
        end
        HDR_MODE_UNDER_TH: begin
            timeout_current_value <= timeout_current_value + 1;
        end
        endcase
    end
  end

  logic above_threshold;
  logic below_threshold;

  always_comb begin

    above_threshold = $unsigned(hdr_absolute_value) > $unsigned(threshold_high);
    below_threshold = $unsigned(hdr_absolute_value) < $unsigned(threshold_low);

    unique case (current_state)
        HSNR_MODE : begin
            alpha_l = 1'b0;
            if(above_threshold) begin
                next_state = HDR_MODE_ABOVE_TH;
            end else begin
                next_state = HSNR_MODE;
            end
        end
        HDR_MODE_UNDER_TH : begin
            alpha_l = 1'b1;
            if(above_threshold) begin
                next_state = HDR_MODE_ABOVE_TH;
            end else begin
                if(|(timeout_current_value & timeout_mask)) begin
                    next_state = HSNR_MODE;
                end else begin
                    next_state = HDR_MODE_UNDER_TH;
                end
            end
        end
        HDR_MODE_ABOVE_TH: begin
            alpha_l = 1'b1;
            if(below_threshold) begin
                next_state = HDR_MODE_UNDER_TH;
            end else begin
                next_state = HDR_MODE_ABOVE_TH;
            end
        end
    endcase
  end

endmodule

`timescale 1ns / 1ps

module datapath_one_clock #(
    parameter int N_BITS_ACC_EXT = 3
) (
    input wire CLK_24M,
    input wire enable_sampling_3M,
    input wire reset,
    input wire [8:0] counter_p,
    input wire [8:0] counter_n,
    output wire [8:0] channel_output
);

  logic [(N_BITS_ACC_EXT+8):0] acc_value;
  logic [8:0] output_value;
  logic [8:0] input_data;
  logic [8:0] output_value_delayed;

  assign channel_output = output_value - output_value_delayed;

  always_comb begin
    input_data = $signed(counter_p) - $signed(counter_n);
  end

  always_ff @(posedge CLK_24M or negedge reset) begin
    if (!reset) begin
      acc_value <= 0;
      output_value <= 0;
      output_value_delayed <= 0;
    end else begin
      acc_value <= $signed(acc_value) + $signed(input_data - output_value);
      if (enable_sampling_3M) begin
        output_value <= acc_value[(N_BITS_ACC_EXT+8):N_BITS_ACC_EXT];
        output_value_delayed <= output_value;
      end
    end
  end

endmodule

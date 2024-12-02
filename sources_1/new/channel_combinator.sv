`timescale 1ns / 1ps

module channel_combinator (
    input wire reset,
    input wire clk,
    input wire enable_3M,
    input wire select,
    input wire [10:0] data_c1,
    input wire [10:0] data_c2,
    output wire [10:0] data_output
);

  logic [4:0] alpha_sequence;
  logic [14:0] combination_output;
  logic enable_compute;

  assign data_output = combination_output[14:4];  // Discard decimals

  logic select_changed;
  logic select_delayed;

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) select_delayed <= 0;
    else begin
      if (enable_3M) select_delayed <= select;
    end
  end

  assign select_changed = select_delayed != select;

  alpha_sequence_generator alpha_sequence_gen (
      .reset(reset),
      .clk(clk),
      .enable_transition(enable_3M),
      .select(select),                // 0 is channel associated with alpha = 0, 1 is channel associated with alpha = 1
      .alpha_sequence(alpha_sequence)
  );

  progressive_mux pmux (
      .reset(reset),
      .clk(clk),
      .enable_3M(enable_3M),
      .enable_compute(select_changed),
      .data_a(data_c1),
      .data_b(data_c2),
      .alpha_sequence(alpha_sequence),  // 00000 is a, 10000 is b. Linear combination in the middle
      .output_data(combination_output)
  );

endmodule

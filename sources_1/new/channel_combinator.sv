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

  logic [ 4:0] alpha_sequence;
  logic [14:0] combination_output;

  assign data_output = combination_output[14:4];  // Discard decimals

  alpha_sequence_generator alphagen (
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
      .data_a(data_c1),
      .data_b(data_c2),
      .alpha_sequence(alpha_sequence),  // 00000 is a, 10000 is b. Linear combination in the middle
      .output_data(combination_output)
  );

endmodule


module alpha_sequence_generator (
    input wire reset,
    input wire clk,
    input wire enable_transition,
    input wire select, // 0 is channel associated with alpha = 0, 1 is channel associated with alpha = 1
    output wire [4:0] alpha_sequence
);

  logic [4:0] alpha_sequence;

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      alpha_sequence <= 0;
    end else begin
      if (enable_transition) begin
        if (select) begin
          if (!alpha_sequence[4]) begin  // if alpha_sequence != 10000 (max value)
            alpha_sequence <= alpha_sequence + 1;
          end
        end else begin
          if (alpha_sequence != 0) begin
            alpha_sequence <= alpha_sequence - 1;
          end
        end
      end
    end
  end
endmodule

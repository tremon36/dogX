`timescale 1ns / 1ps

module progressive_mux_v2_tb;

  logic clk;
  ClockGenerator #(.CLOCK_FREQ_MHZ(24)) cgen (.clk(clk));

  logic reset;
  initial begin
    reset = 0;
    @(posedge clk);
    #1;
    reset = 1;
  end

  logic enable_3M;
  initial begin
    forever begin
      enable_3M = 1;
      @(posedge clk);
      #1;
      enable_3M = 0;
      repeat (6) @(posedge clk);
      #1;
    end
  end

  // DUT

  logic [ 4:0] alpha_sequence;  // 00.000 to 01.000
  logic [10:0] data_a;
  logic [10:0] data_b;
  logic [14:0] output_data;
  logic enable_compute;

  progressive_mux DUT (
      .reset(reset),
      .clk(clk),
      .enable_3M(enable_3M),
      .alpha_sequence(alpha_sequence),
      .enable_compute(enable_compute),
      .data_a(data_a),
      .data_b(data_b),
      .output_data(output_data)
  );

  // Now TB

  initial begin

    data_a = $signed(7);
    data_b = $signed(-33);
    alpha_sequence = 0;
    enable_compute = 0;

    repeat (10) @(negedge enable_3M);
    #1;
    enable_compute = 1;
    while (alpha_sequence != 5'b10000) begin
      @(negedge enable_3M);
      #1;
      enable_compute = 0;
      alpha_sequence = alpha_sequence + 1;
    end

    repeat (10) @(negedge enable_3M);
    #1;
    $stop;

  end

endmodule

`timescale 1ns / 1ps

module dc_filter (
    input wire reset,
    input wire CLK_24M,
    input wire enable_3M,
    input wire [8:0] c_data,
    output wire [8:0] o_data
);

  logic [ 8:0] b;
  logic [8:0] c;
  logic [22:0] d;
  logic [22:0] e;
  logic [38:0] f;
  logic [38:0] g;
  logic [22:0] h;

  always_ff @(posedge CLK_24M or negedge reset) begin
    if (!reset) begin
      b <= 0;
      e <= 0;
    end else begin
      if (enable_3M) begin
        b <= c_data;
        e <= d;
      end
    end
  end

  always_comb begin
    c = c_data - b;
    f = {e, 16'd0};
    g = f - {{16{e[22]}},e};
    h = g[38:16];
    d = {c,14'd0} + h;
  end

  assign o_data = d[22:14];

endmodule

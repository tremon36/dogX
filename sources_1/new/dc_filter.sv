
`define N_DECIMALS 23

module dc_filter (
    input wire reset,
    input wire CLK_24M,
    input wire enable_3M,
    input wire [8:0] c_data,
    output logic [`N_DECIMALS+8:0] filter_out,
    output wire [8:0] o_data
);

  // FILTER
  // d is the otuput of filter

  logic signed [ 8:0] b;
  logic signed [ 8:0] c;
  logic signed [`N_DECIMALS+8:0] d;
  logic signed [`N_DECIMALS+8:0] e;
  logic signed [`N_DECIMALS+8:0] e_shifted;
  logic signed [`N_DECIMALS+8:0] g;
  logic signed [`N_DECIMALS+8:0] e_dd;

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
    e_shifted = e >>> 16;
    g = e - (e_shifted + e_shifted[`N_DECIMALS-1]); // Add MSB of decimals to round instead of truncate
    d = (c << `N_DECIMALS) + g;
  end

  // SIGMA-DELTA for quantization noise shaping

  logic signed [`N_DECIMALS:0] decimals; // Not -1 because of sign
  logic signed [`N_DECIMALS+8:0] h;
  logic signed [`N_DECIMALS+1:0] l;
  logic signed [`N_DECIMALS:0] k;
  logic signed [`N_DECIMALS:0] j;

  always_ff @(posedge CLK_24M or negedge reset) begin
    if (!reset) begin
      k <= 0;
      j <= 0;
    end else begin
      if (enable_3M) begin
        j <= decimals;
        k <= j;
      end
    end
  end

  assign decimals = {1'b0,h[`N_DECIMALS-1:0]};

  always_comb begin
    l = (j << 1) - k;
    h = d + l;
  end

  assign o_data = h[`N_DECIMALS+8:`N_DECIMALS];
  assign filter_out = d;


endmodule

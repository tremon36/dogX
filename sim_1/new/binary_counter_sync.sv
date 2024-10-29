module binary_counter_sync #(
    parameter int N_BITS = 8
  )(
    input wire clk,
    input wire reset,
    input wire count_enable = 1,
    output wire [N_BITS-1:0] value
  );

  logic [N_BITS-1:0] estado;
  logic [N_BITS-1:0] t;

  assign value = estado;

  integer i;
  integer j;

  always_comb
  begin
    t[0] = count_enable;
    for ( i = 1; i < N_BITS; i++)
    begin
      t[i] = estado[i-1] & t[i-1];
    end
  end

  always_ff @(posedge clk or negedge reset)
  begin

    if(!reset)
    begin
      estado <= 0;
    end

    else
    begin
      for( j = 0; j < N_BITS; j++)
      begin
        estado[j] <= t[j] ^ estado[j];
      end
    end
  end

endmodule


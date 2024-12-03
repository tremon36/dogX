
module ClockGenerator #(
    parameter real CLOCK_FREQ_MHZ = 3
) (
    output logic clk
);
  real waittime;
  initial begin
    clk = 1'b1;
    waittime = 1 / (2 * CLOCK_FREQ_MHZ / 1e3);
    forever begin
      #(waittime) clk = ~clk;
    end
  end

endmodule

module ring_osc_16 #(
    parameter real GAIN = 1.0,
    parameter real F0,
    parameter real SAMPLE_TIME_NS = 4
) (
    input real input_voltage,  // min -1, max 1
    output logic [15:0] phases
);

  real next_delay = 5;

  function compute_next_delay();
    next_delay = 1 / (input_voltage * GAIN * F0 + F0) * 1000000000;
  endfunction

  always begin
    compute_next_delay();
    #SAMPLE_TIME_NS;
  end

  always begin

    phases = 16'b0101010101010101;
    #next_delay;
    phases = 16'b1101010101010101;
    #next_delay;
    phases = 16'b1001010101010101;
    #next_delay;
    phases = 16'b1011010101010101;
    #next_delay;
    phases = 16'b1010010101010101;
    #next_delay;
    phases = 16'b1010110101010101;
    #next_delay;
    phases = 16'b1010100101010101;
    #next_delay;
    phases = 16'b1010101101010101;
    #next_delay;
    phases = 16'b1010101001010101;
    #next_delay;
    phases = 16'b1010101011010101;
    #next_delay;
    phases = 16'b1010101010010101;
    #next_delay;
    phases = 16'b1010101010110101;
    #next_delay;
    phases = 16'b1010101010100101;
    #next_delay;
    phases = 16'b1010101010101101;
    #next_delay;
    phases = 16'b1010101010101001;
    #next_delay;
    phases = 16'b1010101010101011;
    #next_delay;
    phases = 16'b1010101010101010;
    #next_delay;
    phases = 16'b0010101010101010;
    #next_delay;
    phases = 16'b0110101010101010;
    #next_delay;
    phases = 16'b0100101010101010;
    #next_delay;
    phases = 16'b0101101010101010;
    #next_delay;
    phases = 16'b0101001010101010;
    #next_delay;
    phases = 16'b0101011010101010;
    #next_delay;
    phases = 16'b0101010010101010;
    #next_delay;
    phases = 16'b0101010110101010;
    #next_delay;
    phases = 16'b0101010100101010;
    #next_delay;
    phases = 16'b0101010101101010;
    #next_delay;
    phases = 16'b0101010101001010;
    #next_delay;
    phases = 16'b0101010101011010;
    #next_delay;
    phases = 16'b0101010101010010;
    #next_delay;
    phases = 16'b0101010101010110;
    #next_delay;
    phases = 16'b0101010101010100;
    #next_delay;

  end

endmodule

module graycount(
    input wire clk,
    input wire [15:0] phases,
    output wire [4:0] sampled_binary
    );

    logic [4:0] gray;
    logic [4:0] binary;

    assign sampled_binary = binary;

    always_ff @(posedge clk) begin
        gray[0] <= phases[1] ^ phases[3] ^ phases[5] ^
                   phases[7] ^ phases[9] ^ phases[11] ^
                   phases[13] ^ phases[15];
        gray[1] <= phases[2] ^ phases[6] ^ phases[10] ^ phases[14];
        gray[2] <= phases[4] ^ phases[12];
        gray[3] <= phases[8];
        gray[4] <= phases[0];
    end

    integer i;
    always_comb begin
        binary[4] = gray[4];
        for(i = 3; i >= 0;i--) begin
            binary[i] = gray[i] ^ binary[i+1];
        end
    end

endmodule

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


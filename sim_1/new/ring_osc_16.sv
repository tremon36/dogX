`timescale 1ns / 1ps

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

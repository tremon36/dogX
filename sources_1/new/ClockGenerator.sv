`timescale 1ns / 1ps
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
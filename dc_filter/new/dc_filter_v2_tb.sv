`timescale 1ns/1ps

module dc_filter_v2_tb;

logic clk;

ClockGenerator #(.CLOCK_FREQ_MHZ(24.576)) cgen (.clk(clk));

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
    repeat (7) @(posedge clk);
    #1;
  end
end

// Generate sine wave



logic [8:0] filter_input;
logic [8:0] filter_output;
logic [31:0] filter_out_intern;

real amplitude_1 = 100;
real offset_1 = 15;
real period_1_2 = (1 / (1000.0)) * 1e9; // period in ns
real sine_1 = 0;

real a = 0;
real b = 0;
real c = 0;
real c_d = 0;
real d = 0;
real e = 0;
real e_d = 0;
real f = 0;

int sd_out = 0;

initial begin
  forever begin
      @(negedge enable_3M);
      #1;
      sine_1 = (amplitude_1 * $sin(2*3.14159265358979323846/period_1_2 * $realtime) + offset_1);

      // Modulate input to sigma delta for filter input. Filter is intended for use with a 9 bit input sigma delta modulation

      c_d = c;
      e_d = e;

      f = $floor(e_d);
      sd_out = $rtoi(f);
      filter_input = sd_out;

      a = sine_1;
      b = a - f;
      c = b + c_d;
      d = c - f;
      e = d + e_d;

  end
end

// save to file

int fd;
initial begin
    fd = $fopen("dc_filter_out.csv","w");
    if(!fd) begin
        $display("FATAL: ERROR OPENING FILE");
        $finish;
    end
end

initial begin
    forever begin
        @(posedge enable_3M);
        @(negedge clk);
        $fdisplay(fd,"%f,%d,%d,%d",sine_1,$signed(filter_input),$signed(filter_output),$signed(filter_out_intern));
    end
end

// DUT

dc_filter DUT (
    .reset(reset),
    .CLK_24M(clk),
    .enable_3M(enable_3M),
    .c_data(filter_input),
    .filter_out(filter_out_intern),
    .o_data(filter_output)
);

// Signals

initial begin
    repeat (3_072_000 * 2) @(posedge clk);
    $fclose(fd);
    $display("FINISHED");
    $stop;
end


endmodule

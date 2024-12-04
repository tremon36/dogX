`timescale 1ns / 10ps

module dc_filter_v2_tb;

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
    repeat (7) @(posedge clk);
    #1;
  end
end

// Generate sine wave

logic [8:0] filter_input;
logic [8:0] filter_output;

real amplitude_1 = 128;
real offset_1 = 30;
real period_1_2 = (1 / (5000.0)) * 1e9; // period in ns
int sine_1 = 0;

initial begin
  forever begin
      @(negedge enable_3M);
      #1;
      sine_1 = $rtoi(amplitude_1 * $sin(2*3.14159265358979323846/period_1_2 * $realtime) + offset_1);
      filter_input = sine_1;
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
        $fdisplay(fd,"%d,%d",$signed(sine_1),$signed(filter_output));
    end
end

// DUT

dc_filter DUT (
    .reset(reset),
    .CLK_24M(clk),
    .enable_3M(enable_3M),
    .c_data(filter_input),
    .o_data(filter_output)
);

// Signals

initial begin
    repeat (6_000_000) @(posedge clk);
    $fclose(fd);
    $display("FINISHED");
    $stop;
end


endmodule

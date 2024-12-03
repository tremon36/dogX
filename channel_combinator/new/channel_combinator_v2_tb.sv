`timescale 1ns / 1ps

module channel_combinator_v2_tb;

  // open file for results

  int fd;
  initial begin
    fd = $fopen("channel_combinator_tb.csv", "w");
    if(fd == 0) begin
        $display("FATAL: CANNOT OPEN channel_combinator_tb.csv");
        $finish;
    end
  end

  // Generate clk, reset, enable

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

  // Now DUT

  logic select;  // 0 is c1, 1 is c2
  logic [10:0] channel_1_data;
  logic [10:0] channel_2_data;
  logic [10:0] combination;

  channel_combinator combinator (
      .reset(reset),
      .clk(clk),
      .enable_3M(enable_3M),
      .select(select),
      .data_c1(channel_1_data),
      .data_c2(channel_2_data),
      .data_output(combination)
  );

  // Now TB

  // Generate continuous sine waves both for channel 1 and channel 2.
  // Both sine waves should have a frequency of 10 KHz (100 us period)
  // Use offset difference between channel 1 and channel 2, also slight differnce in amplitude

  real amplitude_1 = 128;
  real amplitude_2 = 114;

  real offset_1 = 0;
  real offset_2 = -3;

  real period_1_2 = (1 / (10e3)) * 1e9; // period in ns

  int sine_1 = 0;
  int sine_2 = 0;

  initial begin
    forever begin
        @(negedge enable_3M);
        #1;
        sine_1 = $rtoi(amplitude_1 * $sin(2*3.12159/period_1_2 * $realtime) + offset_1);
        channel_1_data = sine_1;
        sine_2 = $rtoi(amplitude_2 * $sin(2*3.12159/period_1_2 * $realtime) + offset_2);
        channel_2_data = sine_2;
    end
  end


  initial begin
    forever begin
        @(posedge enable_3M);
        @(negedge clk);
        $fdisplay(fd,"%d;%d;%d;%d",select,sine_1,sine_2,$signed(combination));
    end
  end

  initial begin
    select = 0;
    repeat(100) @(negedge enable_3M);
    #1;
    select = !select;
    repeat(100) @(negedge enable_3M);
    #1;
    select = !select;
    repeat(50) @(negedge enable_3M);
    #1;
    select = !select;
    repeat(11) @(negedge enable_3M);
    #1;
    select = !select;
    repeat(100) @(negedge enable_3M);
    #1;
    $fclose(fd);
    $stop;
  end



endmodule

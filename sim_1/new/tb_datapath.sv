`timescale 1ns / 1ps

module tb_datapath;

  real sineval_n = 0;
  real sineval_p = 0;
  real t_delay = 7;
  real sinefreq = 10000;
  int  fd;

  // File for output data

  initial begin
    fd = $fopen("./data_out2.csv", "w");
    if (fd) begin
      $display("file ./data_out2.csv opened succesfully");
      $fdisplay("data_out2");
    end else begin
      $display("FAILED TO OPEN FILE ./data_out2.csv");
      $stop;
    end
  end

  final begin
    $fclose(fd);
    $display("closed file sucessfuly");
  end

  //  Clock & reset generation

  logic CLK_24M;
  logic CLK_3M;
  logic reset;

  initial begin
    CLK_24M = 1;
    forever begin
      #20.833333333333336;
      CLK_24M = !CLK_24M;
    end
  end

  initial begin
    CLK_3M = 0;
    #20.833333333333336;
    forever begin
      CLK_3M = !CLK_3M;
      #166.66666666666669;
    end
  end

  initial begin
    reset = 0;
    @(posedge CLK_3M);
    reset = 1;
  end


  // Counter values generation using sine, graycount and extension ----------------------------------------------------------------------------------

  function compute_sine();
    // 1KHz sine of 0.5 amplitude
    sineval_n = 0.4 * $sin(2 * 3.14159 * sinefreq * $realtime / 1000000000);
    sineval_p = -sineval_n;
  endfunction

  always begin
    compute_sine();
    #t_delay;
  end


  logic [15:0] phases_n;
  logic [15:0] phases_p;

  // Oscillators

  ring_osc_16 #(
      .GAIN(1),
      .F0  (196608000)
  ) HSNR_n (
      .input_voltage(sineval_n),
      .phases(phases_n)
  );

  ring_osc_16 #(
      .GAIN(1),
      .F0  (196608000)
  ) HSNR_p (
      .input_voltage(sineval_p),
      .phases(phases_p)
  );

  // Counters

  logic [8:0] counter_p = 0;
  logic [8:0] counter_n = 0;
  logic [4:0] graycounter_p = 0;
  logic [4:0] graycounter_n = 0;

  graycount direct_counter_p (
      .clk(CLK_24M),
      .phases(phases_p),
      .sampled_binary(counter_p[4:0])
  );


  binary_counter_sync #(
      .N_BITS(4)
  ) extender_p (
      .clk  (~counter_p[4]),
      .reset(reset),
      .value(counter_p[8:5])
  );

  graycount direct_counter_n (
    .clk(CLK_24M),
    .phases(phases_n),
    .sampled_binary(counter_n[4:0])
);


binary_counter_sync #(
    .N_BITS(4)
) extender_n (
    .clk  (~counter_n[4]),
    .reset(reset),
    .value(counter_n[8:5])
);

// ---------------------------------------------------------------------------------------------------------------------------

  // DUT

  logic [8:0] output_data;

  datapath #(
      .N_BITS_ACC_EXT(3)
  ) dut (
      .CLK_24M(CLK_24M),
      .CLK_3M(CLK_3M),
      .reset(reset),
      .counter_p(counter_p),
      .counter_n(counter_n),
      .channel_output(output_data)
  );

  // Save data to file

  always_ff @(posedge CLK_3M) begin
    $fdisplay(fd,"%d", $signed(output_data));
  end

  // Run 1 s (3e6 clock cycles)
  initial begin
    repeat (300000) @(posedge CLK_3M);
    $finish;
  end

endmodule

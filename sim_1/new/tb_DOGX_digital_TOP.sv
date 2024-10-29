`timescale 1ns / 1ps

module tb_DOGX_digital_TOP;

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
    // Carrying sine (4 Hz), 0.6 amplitude
    real carrier = 0.6*$sin(2 * 3.14159 * 4 * $realtime / 1000000000);
    // 1 Khz sine (small)
    sineval_n = 0.05*$sin(2 * 3.14159 * sinefreq * $realtime / 1000000000) + carrier;
    sineval_p = -sineval_n;
  endfunction

  always begin
    compute_sine();
    #t_delay;
  end


  logic [15:0] phases_n_HDR;
  logic [15:0] phases_p_HDR;
  logic [15:0] phases_n_HSNR;
  logic [15:0] phases_p_HSNR;

  // Oscillators

  ring_osc_16 #(
      .GAIN(1),
      .F0  (196608000)
  ) HSNR_n (
      .input_voltage(sineval_n),
      .phases(phases_n_HSNR)
  );

  ring_osc_16 #(
      .GAIN(1),
      .F0  (196608000)
  ) HSNR_p (
      .input_voltage(sineval_p),
      .phases(phases_p_HSNR)
  );

  ring_osc_16 #(
      .GAIN(0.25),
      .F0  (196608000)
  ) HDR_n (
      .input_voltage(sineval_n),
      .phases(phases_n_HDR)
  );

  ring_osc_16 #(
      .GAIN(0.25),
      .F0  (196608000)
  ) HDR_p (
      .input_voltage(sineval_p),
      .phases(phases_p_HDR)
  );

  // Counters

  logic [8:0] counter_p_HSNR = 0;
  logic [8:0] counter_n_HSNR = 0;
  logic [8:0] counter_p_HDR = 0;
  logic [8:0] counter_n_HDR = 0;

  graycount direct_counter_p_HSNR (
      .clk(CLK_24M),
      .phases(phases_p_HSNR),
      .sampled_binary(counter_p_HSNR[4:0])
  );

  binary_counter_sync #(
      .N_BITS(4)
  ) extender_p_HSNR (
      .clk  (~counter_p_HSNR[4]),
      .reset(reset),
      .value(counter_p_HSNR[8:5])
  );

  graycount direct_counter_n_HSNR (
      .clk(CLK_24M),
      .phases(phases_n_HSNR),
      .sampled_binary(counter_n_HSNR[4:0])
  );


  binary_counter_sync #(
      .N_BITS(4)
  ) extender_n_HSNR (
      .clk  (~counter_n_HSNR[4]),
      .reset(reset),
      .value(counter_n_HSNR[8:5])
  );

  // HDR

  graycount direct_counter_p_HDR (
      .clk(CLK_24M),
      .phases(phases_p_HDR),
      .sampled_binary(counter_p_HDR[4:0])
  );


  binary_counter_sync #(
      .N_BITS(4)
  ) extender_p_HDR (
      .clk  (~counter_p_HDR[4]),
      .reset(reset),
      .value(counter_p_HDR[8:5])
  );

  graycount direct_counter_n_HDR (
      .clk(CLK_24M),
      .phases(phases_n_HDR),
      .sampled_binary(counter_n_HDR[4:0])
  );


  binary_counter_sync #(
      .N_BITS(4)
  ) extender_n_HDR (
      .clk  (~counter_n_HDR[4]),
      .reset(reset),
      .value(counter_n_HDR[8:5])
  );

  // ---------------------------------------------------------------------------------------------------------------------------

  // DUT

  logic [10:0] output_data;
  logic alpha;

  DOGX_digital_TOP dut (
      .CLK_24M(CLK_24M),
      .CLK_3M(CLK_3M),
      .reset(reset),
      .counter_HSNR_n(counter_n_HSNR),
      .counter_HSNR_p(counter_p_HSNR),
      .counter_HDR_n(counter_n_HDR),
      .counter_HDR_p(counter_p_HDR),
      .alpha_th_high(9'd10),
      .alpha_th_low(9'd7),
      .alpha_timeout_mask(5'b10000),
      .alpha_out(alpha),
      .alpha_in(alpha),
      .converter_output(output_data)
  );

  // Save data to file

  always_ff @(posedge CLK_3M) begin
    $fdisplay(fd, "%d,%d", $signed(output_data), alpha);
  end

  // Run 1 s (3e6 clock cycles)
  initial begin
    repeat (3000000) @(posedge CLK_3M);
    $finish;
  end

endmodule

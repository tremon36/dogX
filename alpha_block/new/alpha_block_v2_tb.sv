`timescale 1ns/1ps

module alpha_block_v2_tb;

  // Clock and reset
  logic clk;
  logic reset;

  // Inputs to DUT
  logic [8:0] hdr_current_value;
  logic [8:0] threshold_high;
  logic [8:0] threshold_low;
  logic [4:0] timeout_mask;
  logic enable_sampling_3M;

  // Output from DUT
  wire alpha;

  // Instantiate DUT
  alpha_block_v2 dut (
    .clk(clk),
    .enable_sampling(enable_sampling_3M),
    .reset(reset),
    .hdr_current_value(hdr_current_value),
    .threshold_high(threshold_high),
    .threshold_low(threshold_low),
    .timeout_mask(timeout_mask),
    .alpha(alpha)
  );

  // Clock generation (10ns period)
  initial clk = 0;
  always #5 clk = ~clk;

  // enable generation
  int count = 0;
  always begin
    @(posedge clk);
    enable_sampling_3M = count == 0;
    count = count + 1;
    if (count == 8) count = 0;
  end

  // Test task to apply stimulus
  task test_case (
    input logic [8:0] hdr_value,
    input logic  [8:0] th_high,
    input logic [8:0] th_low,
    input logic [4:0] t_mask
  );
    begin
      @(posedge clk);
      hdr_current_value = hdr_value;
      threshold_high = th_high;
      threshold_low = th_low;
      timeout_mask = t_mask;
    end
  endtask

  // Testbench control
  initial begin
    // Initialize signals
    hdr_current_value = 9'b0;
    threshold_high = 9'd200;
    threshold_low = 9'd50;
    timeout_mask = 5'b11111;

    // Reset DUT
    reset = 0;
    @(posedge clk);
    reset = 1;
    #1;

    // Apply test cases
    $display("Starting test cases...");
    
    // Test case 1: hdr_current_value within thresholds
    test_case(9'd100, 9'd200, 9'd50, 5'b10000);
    #80;

    // Test case 2: hdr_current_value above threshold_high
    test_case(9'd210, 9'd200, 9'd50, 5'b10000);
    #80;

    // Test case 3: hdr_current_value below threshold_low
    test_case(9'd40, 9'd200, 9'd50, 5'b10000);
    #80;

    // Test case 4: hdr_current_value oscillating around threshold_high
    test_case(9'd195, 9'd200, 9'd50, 5'b10000);
    #80;
    test_case(9'd205, 9'd200, 9'd50, 5'b10000);
    #80;

    // Test case 5: Timeout condition with hdr_current_value below threshold_low

    test_case(9'd40, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

    // Now go between thresholds for a while
    test_case(9'd70, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

    // Now above TH
    test_case(9'd201, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

     // Now go between thresholds for a while
    test_case(9'd70, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

    // Now go below thresholds for a while
    test_case(-9'sd12, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

    // Now go below thresholds for a while
    test_case(9'sd12, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

    // Now go above thresholds for a while
    test_case(-9'sd205, 9'd200, 9'd50, 5'b10000);
    repeat (40*8) @(posedge clk);

    $display("All test cases completed.");
    $stop;
  end

endmodule

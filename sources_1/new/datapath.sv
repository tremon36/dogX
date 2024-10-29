`timescale 1ns / 1ps

module datapath #(
    parameter int N_BITS_ACC_EXT = 3
) (
    input wire CLK_3M,
    input wire CLK_24M,
    input wire reset,
    input wire [8:0] counter_p,
    input wire [8:0] counter_n,
    output wire [8:0] channel_output
);

  logic [(N_BITS_ACC_EXT+8):0] acc_value;
  logic [8:0] output_value;
  logic [8:0] input_data;
  logic [8:0] output_value_delayed;

  assign channel_output = output_value - output_value_delayed;

  always_comb begin
    input_data = $signed(counter_p) - $signed(counter_n);
  end

  always_ff @(posedge CLK_24M or negedge reset) begin
    if (!reset) begin
      acc_value <= 0;
    end else begin
      acc_value <= $signed(acc_value) + $signed(input_data - output_value);
    end
  end

  always_ff @(posedge CLK_3M or negedge reset) begin
    if (!reset) begin
        output_value <= 0;
        output_value_delayed <= 0;
      end else begin
        output_value <= acc_value[(N_BITS_ACC_EXT+8):N_BITS_ACC_EXT];
        output_value_delayed <= output_value;
      end
  end

endmodule

//module datapath #(
//    parameter int N_BITS_ACC_EXT = 3
//) (
//    input wire CLK_24M,
//    input wire CLK_3M,
//    input wire reset,
//    input wire [8:0] counter_p,
//    input wire [8:0] counter_n,
//    output wire [8:0] channel_output
//);
//
//  logic [11:0] acc;
//  logic [8:0] diff1;
//  logic [8:0] out_r;
//  logic [8:0] out_r_delayed;
//  logic [11:0] diff1_extended;
//  logic [8:0] in;
//
//  assign in = $signed(counter_p) - $signed(counter_n);
//
//  assign channel_output = out_r - out_r_delayed;
//  assign diff1_extended = {{3{diff1[8]}}, diff1};
//
//  always_ff @(posedge CLK_24M or negedge reset) begin
//
//    if (!reset) begin
//      acc <= 0;
//    end else begin
//      acc <= acc + diff1_extended;
//    end
//
//  end
//
//  always_comb begin
//    diff1 = in - out_r;
//  end
//
//  always_ff @(posedge CLK_3M or negedge reset) begin
//    if (!reset) begin
//      out_r <= 0;
//    end else begin
//      out_r <= acc[11:3];
//    end
//  end
//
//  always_ff @(posedge CLK_3M or negedge reset) begin
//    if (!reset) begin
//      out_r_delayed <= 0;
//    end else begin
//      out_r_delayed <= out_r;
//    end
//  end



//endmodule
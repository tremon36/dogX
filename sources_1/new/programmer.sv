`timescale 1ns / 1ps

/*
    PROGRAMMER MODULE - Ricardo Carrero Bardon - 22/11/2024

    The module programming interface is SPI (mode 00)
    CS is used both as a sync input and a clock input.
    SCLK is a clock input.
    SDI is the data input for the programmer.
    Connect all the output programming ports to the corresponding place in the design

*/

module programmer (
    input wire reset,
    input wire SDI,
    input wire SCLK,
    input wire CS,
    output wire [7:0] GTHDR,
    output wire [7:0] GTHSNR,
    output wire [3:0] FCHSNR,
    output wire HSNR_EN,
    output wire HDR_EN,
    output wire BG_PROG_EN,
    output wire [3:0] BG_PROG,
    output wire LDOA_BP,
    output wire LDOD_BP,
    output wire LDOD_mode_1V,
    output wire LDOA_tweak,
    output wire [8:0] ATHHI,
    output wire [8:0] ATHLO,
    output wire [4:0] ATO,
    output wire PALPHA,
    output wire DCFILT,
    output wire REF_OUT,
    output wire DRESET,
    output wire HO
);

  `define NUM_REGS 19
  `define NUM_BITS 59

  logic [`NUM_BITS-1:0] prog_data;

  // Assign each output to the corresponding data

  assign GTHDR = prog_data[7:0];
  assign GTHSNR = prog_data[15:8];
  assign FCHSNR = prog_data[19:16];
  assign HSNR_EN = prog_data[20];
  assign HDR_EN = prog_data[21];
  assign BG_PROG_EN = prog_data[22];
  assign BG_PROG = prog_data[26:23];
  assign LDOA_BP = prog_data[27];
  assign LDOD_BP = prog_data[28];
  assign LDOD_mode_1V = prog_data[29];
  assign LDOA_tweak = prog_data[30];
  assign ATHHI = prog_data[39:31];
  assign ATHLO = prog_data[48:40];
  assign ATO = prog_data[53:49];
  assign PALPHA = prog_data[54];
  assign DCFILT = prog_data[55];
  assign REF_OUT = prog_data[56];
  assign DRESET = prog_data[57];
  assign HO = prog_data[58];

  // Populate input prog_data_aux with SCLK

  logic [`NUM_BITS-1:0] prog_data_aux;


  always_ff @(posedge SCLK or negedge reset) begin
    if (!reset) begin
      prog_data_aux <= 0;
    end else begin
      if (!CS) begin  // Only do a shift when CS is low
        prog_data_aux[`NUM_BITS-1]   <= SDI;
        prog_data_aux[`NUM_BITS-2:0] <= prog_data_aux[`NUM_BITS-1:1];
      end
    end
  end

  always_ff @(posedge CS or negedge reset) begin
    if (!reset) begin
      prog_data <= 0;
    end else begin
      prog_data <= prog_data_aux;
    end
  end
endmodule

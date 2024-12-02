
module DOGX_TOP (

    input wire CLK_24M,  // CLK from DLL
    input wire reset,    // Reset only used for simulation, leave connected to 1

    input wire SCLK,  // CLK for programming port
    input wire SDI,   // Serial data for programming port
    input wire CS,    // Chip select for programming port

    input wire [8:0] counter_HSNR_p,  // Counters from VCOs (already extended)
    input wire [8:0] counter_HSNR_n,
    input wire [8:0] counter_HDR_p,
    input wire [8:0] counter_HDR_n,

    input  wire  alpha_in,  // Alpha out and in
    output logic alpha_out,

    output logic [7:0] GTHDR,         // Programming bits for analog side
    output logic [7:0] GTHSNR,
    output logic [3:0] FCHSNR,
    output logic       HSNR_EN,
    output logic       HDR_EN,
    output logic       BG_PROG_EN,
    output logic [3:0] BG_PROG,
    output logic       LDOA_BP,
    output logic       LDOD_BP,
    output logic       LDOD_mode_1V,
    output logic       LDOA_tweak,
    output logic       REF_OUT,
    output logic       HO,

    output logic [10:0] converter_output  // Digital output

);

  // Programmer

  logic [8:0] ATHHI;
  logic [8:0] ATHLO;
  logic [4:0] ATO;
  logic DRESET;
  logic PALPHA;


  programmer DOGX_programmer (
      .reset(reset),
      .SDI(SDI),
      .SCLK(SCLK),
      .CS(CS),
      .GTHDR(GTHDR),
      .GTHSNR(GTHSNR),
      .FCHSNR(FCHSNR),
      .HSNR_EN(HSNR_EN),
      .HDR_EN(HDR_EN),
      .BG_PROG_EN(BG_PROG_EN),
      .BG_PROG(BG_PROG),
      .LDOA_BP(LDOA_BP),
      .LDOD_BP(LDOD_BP),
      .LDOD_mode_1V(LDOD_mode_1V),
      .LDOA_tweak(LDOA_tweak),
      .ATHHI(ATHHI),
      .ATHLO(ATHLO),
      .ATO(ATO),
      .PALPHA(PALPHA),
      .REF_OUT(REF_OUT),
      .DRESET(DRESET),
      .HO(HO)
  );


  // Converter

  DOGX_digital_converter DOGX_converter (
    .CLK_24M(CLK_24M),
    .reset(DRESET),
    .counter_HSNR_p(counter_HSNR_p),
    .counter_HSNR_n(counter_HSNR_n),
    .counter_HDR_p(counter_HDR_p),
    .counter_HDR_n(counter_HDR_n),
    .alpha_th_high(ATHHI),
    .alpha_th_low(ATHLO),
    .alpha_timeout_mask(ATO),
    .alpha_in(alpha_in),
    .alpha_out(alpha_out),
    .use_progressive_alpha(PALPHA),
    .converter_output(converter_output)
);



endmodule

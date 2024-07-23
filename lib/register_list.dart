import 'package:dogx_ui/register.dart';

class RegisterList {

  static final List<Register> regList = List<Register>.unmodifiable(
    [
      Register(
          name: "ATH_HI",
          nbits: 10,
          signed: false,
          help: "High threshold for alpha block",
          value: 100
      ),

      Register(name: "ATH_LO",
          nbits: 13,
          signed: true,
          help: "Low threshold for alpha block"
      ),

      Register(name: "GTHDR",
          nbits: 8,
          signed: false,
          help: "Analog gain trimming of HDR channel through programmable resistor, check table for states"
      ),

      Register(name: "GTHSNR",
          nbits: 8,
          signed: false,
          help: "Analog gain trimming of HSNR channel through programmable resistor, check table for states"
      ),

      Register(name: "FCHSNR",
          nbits: 4,
          signed: false,
          help: "Analog frequency tunning of HSNR channel through current mirror adjust, 0-15uA increase"
      ),

      Register(name: "HSNR_EN",
          nbits: 1,
          signed: false,
          help: "Enable HSNR channel"
      ),

      Register(name: "HDR_EN",
          nbits: 1,
          signed: false,
          help: "Enable HDR channel"
      ),

      Register(name: "BG_PROG_EN",
          nbits: 1,
          signed: false,
          help: "Enable bandgap programming"
      ),

      Register(name: "BG_PROG",
          nbits: 4,
          signed: true,
          help: "0000-> Nominal.\n 0001-0111 -> Trim (+2% to +18%).\n 1000-1111 -> Trim (-18% to -2%)"
      ),

      Register(name: "LDOA_BP",
          nbits: 1,
          signed: false,
          help: "Analog LDO bypass"
      ),

      Register(name: "LDOD_BP",
          nbits: 1,
          signed: false,
          help: "Digital LDO bypass"
      ),

      Register(name: "LDOD_mode_1V",
          nbits: 1,
          signed: false,
          help: "Digital LDO 0.9V -> 1V"
      ),

      Register(name: "LDOA_tweak",
          nbits: 1,
          signed: false,
          help: "Increase current LDOA"
      ),

      Register(name: "NSW",
          nbits: 1,
          signed: false,
          help: "Noise shaper Wordlength.  ‘0’ 12 bits - ‘1’ 11 bits"
      ),

      Register(name: "OCHDR",
          nbits: 5,
          signed: true,
          help: "offset calibration HDR"
      ),

      Register(name: "OCHSNR",
          nbits: 5,
          signed: true,
          help: "offset calibration HSNR"
      ),

      Register(name: "ATO",
          nbits: 5,
          signed: false,
          help: "alpha timeout (24 - 390 Hz)"
      ),

      Register(name: "REF_OUT",
          nbits: 1,
          signed: false,
          help: "Oscillator reference phases out (freq/4)"
      ),


    ]
  );
}
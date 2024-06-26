import 'package:dogx_ui/register.dart';

class RegisterList {

  static final List<Register> regList = List<Register>.unmodifiable(
    [
      Register(name: "ATH_HI", nbits: 10, help: "High threshold for alpha block"),
      Register(name: "ATH_LO", nbits: 13, help: "Low threshold for alpha block"),
    ]
  );
}
import 'package:dogx_ui/reg_provider.dart';
import 'package:dogx_ui/register.dart';
import 'package:dogx_ui/register_list.dart';
import 'package:dogx_ui/register_view.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class CommandProcessor {
  static void processCommand(String command) {
    String regname = command.split(":").first;
    String regval = command.split(":").last;
    RegisterList.regList.firstWhere((Register r) => r.name == regname).value = int.parse(regval);
   // print(RegisterList.regList);
    RegProvider().requestUpdate();
  }
}
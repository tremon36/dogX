import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialReader {
  static Future<void> listen(
      String serialPortName, Function(String) onValue) async {
    SerialPort port = SerialPort(serialPortName);
    if (!port.isOpen) {
      port.openReadWrite();
    }
    SerialPortReader reader = SerialPortReader(port,timeout: 0);

    reader.stream.listen((event) {
        onValue(ascii.decode(event));
    });
  }
}

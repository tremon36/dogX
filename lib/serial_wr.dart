import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialWR {

  late SerialPort port;
  bool initialized = false;

  void begin(String serialPortName) {
    port = SerialPort(serialPortName);
    if (!port.isOpen) {
      port.openReadWrite();
      initialized = true;
    }
  }

  Future<void> listen(Function(String) onValue) async {

    if(!initialized) throw Exception("Initialize port first");
    SerialPortReader reader = SerialPortReader(port,timeout: 0);
    
    String currentRead = "";
    reader.stream.listen((event) {

      List<int> bytes = [];
      bytes.addAll(event);
      bytes.removeWhere((int e) => e < 41 && e != 10);

        currentRead = "$currentRead${ascii.decode(bytes)}";
        if(currentRead.contains("\n")) {
          currentRead = currentRead.replaceAll("\r", "");
          List<String> received = currentRead.split("\n");
          onValue(received.first);
          currentRead = received.last;
        }
    });
  }
  
  void print(Uint8List data) {
    
    if(!initialized) throw Exception("Initialize port first");
    port.write(data);

  }


}

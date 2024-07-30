import 'dart:convert';
import 'dart:io';

import 'package:dogx_ui/register.dart';

class JsonFileHandler {

  static Future<void> writeListToJsonFile(List<Register> list) async {
    // Convert list of Register objects to list of Maps
    List<Map<String, dynamic>> jsonList = list.map((register) => register.toJson()).toList();

    // Convert list of Maps to JSON string with pretty printing
    String jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    // Get the current directory
    Directory current = Directory.current;

    // Write JSON string to a file
    File file = File('${current.path}/registers.json');
    await file.writeAsString(jsonString, flush: true);
  }

  static Future<List<Register>> readListFromJsonFile() async {
    // Get the current directory
    Directory current = Directory.current;

    // Read the JSON string from the file
    File file = File('${current.path}/registers.json');
    if (await file.exists()) {
      String jsonString = await file.readAsString();

      // Convert JSON string to list of Maps
      List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert list of Maps to list of Register objects
      List<Register> list = jsonList.map((json) => Register.fromJson(json)).toList();
      return list;
    } else {
      // Return an empty list if the file does not exist
      return [];
    }
  }
}

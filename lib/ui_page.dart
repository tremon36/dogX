import 'dart:typed_data';

import 'package:dogx_ui/command_processor.dart';
import 'package:dogx_ui/json_file_handler.dart';
import 'package:dogx_ui/reg_provider.dart';
import 'package:dogx_ui/register.dart';
import 'package:dogx_ui/register_list.dart';
import 'package:dogx_ui/register_view.dart';
import 'package:dogx_ui/serial_wr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';

class UIpage extends StatefulWidget {
  const UIpage({super.key});

  @override
  _UIpageState createState() => _UIpageState();
}

class _UIpageState extends State<UIpage> {
  List<String> availablePorts = [];
  String selectedPort = "";
  SerialWR serialWR = SerialWR();

  @override
  void initState() {
    availablePorts = SerialPort.availablePorts;
    if (availablePorts.isNotEmpty) {
      selectedPort = availablePorts.first;
      serialWR.begin(selectedPort);
    }

    if (selectedPort != "" && serialWR.initialized) {
      serialWR.listen((String newLine) {
        print(newLine);
        setState(() {
          CommandProcessor.processCommand(newLine);
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Programmer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[

          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: DropdownButton<String>(
              value: selectedPort,
              icon: const Icon(Icons.menu),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onTap: () {
                availablePorts = SerialPort.availablePorts;
              },
              onChanged: (String? newValue) {
                setState(() {
                  if(selectedPort != newValue) {
                    for(Register r in RegisterList.regList) {
                      r.syncedWithChip = false;
                    }
                  }
                  selectedPort = newValue!;
                  if (selectedPort != "") {
                    serialWR.begin(selectedPort);
                    serialWR.listen((String newLine) {
                      CommandProcessor.processCommand(newLine);
                      print(newLine);
                    });
                  }
                });
              },
              items:
              availablePorts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {
                  JsonFileHandler.writeListToJsonFile(RegisterList.regList);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Register values saved to registers.json"))
                  );
                },
                child: const Icon(Icons.save),
              )
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300.0, // Maximum width of each item
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
            childAspectRatio: 1.95, // Adjust aspect ratio if needed
          ),
          itemCount: RegisterList.regList.length,
          // Adjust this based on how many items you want
          itemBuilder: (context, index) {
            return Consumer<RegProvider>(
              builder: (context, appState, _) =>
                  RegisterView(register: RegisterList.regList[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (Register reg in RegisterList.regList) {
            if (!reg.syncedWithChip) {
              serialWR.print(reg.getSendData());
              print(reg);
              reg.syncedWithChip = true;
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Sending data to $selectedPort")
            ),
          );
        },
        child: Icon(Icons.update),
      ),
    );
  }
}

import 'dart:convert';
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
  List<String> _logs = ["Serial console log"];
  String selectedPort = "";
  SerialWR serialWR = SerialWR();
  double upperSectionRatio = 0.2;

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
          //CommandProcessor.processCommand(newLine);
          _logs.add(newLine);
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
                  if (selectedPort != newValue) {
                    for (Register r in RegisterList.regList) {
                      r.syncedWithChip = false;
                    }
                  }
                  if (selectedPort != newValue) {
                    selectedPort = newValue!;
                    if (selectedPort != "") {
                      serialWR.begin(selectedPort);
                      serialWR.listen((String newLine) {
                        CommandProcessor.processCommand(newLine);
                        print(newLine);
                      });
                    }
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                      Text("Register values saved to registers.json")));
                },
                child: const Icon(Icons.save),
              )),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double availableHeight = constraints.maxHeight;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First section (registers) takes adjustable space
              SizedBox(
                height: availableHeight * upperSectionRatio,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300.0, // Maximum width of each item
                      crossAxisSpacing: 2.0,
                      mainAxisSpacing: 2.0,
                      childAspectRatio: 1.95, // Adjust aspect ratio if needed
                    ),
                    itemCount: RegisterList.regList.length,
                    itemBuilder: (context, index) {
                      return Consumer<RegProvider>(
                        builder: (context, appState, _) =>
                            RegisterView(register: RegisterList.regList[index]),
                      );
                    },
                  ),
                ),
              ),
              // Draggable divider
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  setState(() {
                    upperSectionRatio += details.delta.dy / availableHeight;
                    if (upperSectionRatio < 0.1) upperSectionRatio = 0.1;
                    if (upperSectionRatio > 0.9) upperSectionRatio = 0.9;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: Container(
                    height: 4.0,
                    color: Colors.grey,
                    child: Center(
                      child: Icon(Icons.drag_handle, color: Colors.black45),
                    ),
                  ),
                ),
              ),
              // Second section (Log/Console) takes the remaining height
              SizedBox(
                height: availableHeight * (1 - (upperSectionRatio + 0.02)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10, right: 90),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: FloatingActionButton(
            heroTag: 'reset_button', // Unique hero tag
            onPressed: () {
              Uint8List c = prepareCommandData("HIZ:", Uint8List(0));
              serialWR.print(c);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sending RESET to $selectedPort")),
                snackBarAnimationStyle: AnimationStyle(duration:
                Duration(milliseconds: 500)),
              );
            },
            child: Text('Reset'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: FloatingActionButton(
            heroTag: 'hiz_button', // Unique hero tag
            onPressed: () {
              Uint8List c = prepareCommandData("HIZ:", Uint8List(0));
              serialWR.print(c);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sending HIZ to $selectedPort")),
                snackBarAnimationStyle: AnimationStyle(duration:
                Duration(milliseconds: 500)),
              );

            },
            child: Text('HiZ'),
          ),
        ),
        FloatingActionButton(
          heroTag: 'update_button', // Unique hero tag
          onPressed: () {

            serialWR.print(prepareCommandData("DATA:", RegisterList.getSendData()));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sending data to $selectedPort")),
              snackBarAnimationStyle: AnimationStyle(duration:
              Duration(milliseconds: 500)),
            );
          },
          child: Icon(Icons.update),
        ),
      ],
    ),/* FloatingActionButton(
        onPressed: () {
          /*
          bool changed = false;
          for (Register reg in RegisterList.regList) {
            if (!reg.syncedWithChip) {
              changed = true;
              serialWR.print(reg.getSendData());
              print(reg);
              reg.syncedWithChip = true;
            }
          }
          if(changed) {
            String toSend = "RUN\n";
            int byteAmount = toSend.length+1;
            List<int> list = [byteAmount];
            list.addAll(ascii.encode(toSend));
            serialWR.print(Uint8List.fromList(list));
          } */

          serialWR.print(RegisterList.getSendData());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sending data to $selectedPort")),
          );
        },
        child: Icon(Icons.update),
      ),*/
    );
  }

  Uint8List prepareCommandData(String commandText, Uint8List data) {

    Uint8List command = ascii.encode(commandText);
    Uint8List toSend = Uint8List(data.length+command.length);

    for(int i = 0; i< command.length; i++){
      toSend[i] = command[i];
    }

    for(int i = command.length; i < command.length+data.length;i++){
      toSend[i] = data[i];
    }

    return toSend;
  }
}

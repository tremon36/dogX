import 'dart:typed_data';

import 'package:dogx_ui/register.dart';
import 'package:dogx_ui/register_list.dart';
import 'package:dogx_ui/register_view.dart';
import 'package:dogx_ui/serial_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class UIpage extends StatefulWidget {
  const UIpage({super.key});

  @override
  _UIpageState createState() => _UIpageState();
}

class _UIpageState extends State<UIpage> {

  List<String> availablePorts = [];
  String selectedPort = "";


  @override
  void initState() {
    availablePorts = SerialPort.availablePorts;
    if(availablePorts.isNotEmpty) selectedPort = availablePorts.first;
    if(selectedPort != "") {
      SerialReader.listen(selectedPort, (String newLine) {
        print(newLine);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DOG X',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
                  selectedPort = newValue!;
                  if(selectedPort != "") {
                    SerialReader.listen(selectedPort, (String newLine) {
                      print(newLine);
                    });
                  }
                });
              },
              items: availablePorts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                );
              }).toList(),
            ),
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
            childAspectRatio:1.95, // Adjust aspect ratio if needed
          ),
          itemCount: RegisterList.regList.length, // Adjust this based on how many items you want
          itemBuilder: (context, index) {
            return RegisterView(
              register: RegisterList.regList[index]
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SerialPort(selectedPort).openReadWrite();
          SerialPort(selectedPort).write(RegisterList.regList.first.getSendData());

        },
        child: Icon(Icons.update),
      ),
    );
  }
}

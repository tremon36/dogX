import 'package:dogx_ui/register.dart';
import 'package:dogx_ui/register_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UIpage extends StatefulWidget {
  const UIpage({super.key});

  @override
  _UIpageState createState() => _UIpageState();
}

class _UIpageState extends State<UIpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DOG X',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400.0, // Maximum width of each item
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5, // Adjust aspect ratio if needed
          ),
          itemCount: 20, // Adjust this based on how many items you want
          itemBuilder: (context, index) {
            return RegisterView(
              register: Register(
                name: "ATH_HI",
                nbits: 10,
              ),
            );
          },
        ),
      ),
    );
  }
}

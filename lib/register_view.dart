import 'package:dogx_ui/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  final Register register;

  const RegisterView({super.key, required this.register});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _decController = TextEditingController();
  final TextEditingController _binController = TextEditingController();

  void changeDecimalText() {
    try {
      print(widget.register.binToDec(_binController.text));
      _decController.removeListener(changeBinaryText);
      _decController.text = widget.register.binToDec(_binController.text);
      _decController.addListener(changeBinaryText);
    } catch (e) {}
    ;
  }

  void changeBinaryText() {
    try {
      print(widget.register.decTobin(_decController.text));
      _binController.removeListener(changeDecimalText);
      _binController.text = widget.register.decTobin(_decController.text);
      _binController.addListener(changeDecimalText);
    } catch (e) {}
    ;
  }

  @override
  void initState() {
    _decController.addListener(changeBinaryText);
    _binController.addListener(changeDecimalText);
    super.initState();
  }

  @override
  void dispose() {
    _decController.dispose();
    _binController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.register.help,
      preferBelow: false,
      waitDuration: Duration(milliseconds: 700),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 180,
          width: 250,
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        widget.register.name,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      // This will push the following Text widget to the right
                      Text(
                        '${widget.register.nbits} bits',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // Spacing between the text and the first input field
                  TextField(
                    style: const TextStyle(fontSize: 16),
                    controller: _decController,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                      hintText: 'Decimal',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Spacing between the input fields
                  TextField(
                    style: const TextStyle(fontSize: 16),
                    controller: _binController,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                      hintText: 'Binary',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

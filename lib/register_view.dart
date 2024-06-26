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
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 180,
        width: 250,
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.register.name,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 0.0),
                // Spacing between the text and the first input field
                TextField(
                  controller: _controller1,
                  onChanged: (String newVal) {
                    try {
                      print(widget.register.decTobin(newVal));
                      _controller2.text = widget.register.decTobin(newVal);
                    } catch(e) {};
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Decimal',
                  ),
                ),
                const SizedBox(height: 0.0),
                // Spacing between the input fields
                TextField(
                  controller: _controller2,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Binary',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

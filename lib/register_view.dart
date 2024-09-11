import 'package:dogx_ui/reg_provider.dart';
import 'package:dogx_ui/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterView extends StatefulWidget {
  final Register register;

  const RegisterView({super.key, required this.register});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _decController = TextEditingController();
  final TextEditingController _binController = TextEditingController();
  Set<LogicalKeyboardKey> _pressedKeys = Set<LogicalKeyboardKey>();

  void changeDecimalText() {
    try {
      bool overflow = false;
      int newval = int.parse(widget.register.binToDec(_binController.text));
      if (newval > widget.register.maxVal()) {
        newval = widget.register.maxVal();
        overflow = true;
      }
      if (newval < widget.register.minVal()) {
        newval = widget.register.minVal();
        overflow = true;
      }

      widget.register.value = newval;
      widget.register.syncedWithChip = false;

      _binController.removeListener(changeDecimalText);
      _decController.removeListener(changeBinaryText);
      if (overflow) {
        _binController.text = widget.register.decTobin(newval.toString());
      }
      _decController.text = newval.toString();
      _binController.addListener(changeDecimalText);
      _decController.addListener(changeBinaryText);
    } catch (e) {}
  }

  void changeBinaryText() {
    try {
      int newval = int.parse(_decController.text);
      bool overflow = false;
      if (newval > widget.register.maxVal()) {
        newval = widget.register.maxVal();
        overflow = true;
      }
      if (newval < widget.register.minVal()) {
        newval = widget.register.minVal();
        overflow = true;
      }

      widget.register.value = newval;
      widget.register.syncedWithChip = false;

      _binController.removeListener(changeDecimalText);
      _decController.removeListener(changeBinaryText);
      _binController.text = widget.register.decTobin(newval.toString());
      if (overflow) {
        _decController.text = newval.toString();
      }
      _binController.addListener(changeDecimalText);
      _decController.addListener(changeBinaryText);
    } catch (e) {}
  }

  @override
  void initState() {
    _decController.text = widget.register.value.toString();
    _binController.text =
        widget.register.decTobin(widget.register.value.toString());
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
    _decController.text = widget.register.value.toString();

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Tooltip(
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
                          '${widget.register.nbits} bits ${widget.register.signed ? "signed" : "unsigned"}',
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w300),
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w300),
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
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey); // Add the pressed key
      if(_checkForShortcut()){
        return KeyEventResult.handled;// Check for keyboard shortcut
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey); // Remove key on release
    }
    return KeyEventResult.ignored;

     // Mark event as handled
  }

  bool _checkForShortcut() {
    bool upIsPressed =
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp);


    bool downIsPressed = _pressedKeys.contains(LogicalKeyboardKey.arrowDown);

    if(downIsPressed) {
      widget.register.value--;
      RegProvider().requestUpdate();
      return true;
    } else if (upIsPressed) {
      widget.register.value++;
      RegProvider().requestUpdate();
      return true;
    }
    return false;
  }
}

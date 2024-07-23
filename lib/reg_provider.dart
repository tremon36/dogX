import 'package:flutter/cupertino.dart';

class RegProvider extends ChangeNotifier {

  static final RegProvider _provider = RegProvider._internal();


  factory RegProvider() {
    return _provider;
  }

  RegProvider._internal();

  void requestUpdate() {
    notifyListeners();
  }
}
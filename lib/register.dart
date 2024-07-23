import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class Register {
  String name;
  String help;
  int value;
  int nbits;
  bool signed;

  Register({this.name = "", this.value = 0, this.nbits = 1, this.help = "", this.signed = true});

  String decTobin(String dec) {
    int rem = int.parse(dec);
    bool isNeg = rem < 0;
    if (isNeg) {
      rem = -rem;
    }
    String bin = "";
    while (rem != 0 && rem != 1) {
      bin = "${rem % 2}${bin}";
      rem = rem ~/ 2;
    }
    bin = "${rem}${bin}";
    while (bin.length < nbits) {
      bin = "0${bin}";
    }

    if (isNeg && signed) {
      for (int i = 0; i < bin.length; i++) {
        bin[i] == '0'
            ? bin = bin.replaceCharAt(i, '1')
            : bin = bin.replaceCharAt(i, '0');
      }
      int i = bin.length - 1;
      if (bin[i] != '0') {
        while (bin[i] == '1') {
          bin = bin.replaceCharAt(i, '0');
          i--;
        }
        bin = bin.replaceCharAt(i, '1');
      } else {
        bin = bin.replaceCharAt(i, '1');
      }
    }

    return bin;
  }

  String binToDec(String bin) {
    bool isNeg = false;
    if (bin.length < nbits) {
      while (bin.length < nbits) {
        bin = "0${bin}";
      }
    }
    isNeg = bin[0] == '1';
    if (isNeg && signed) {
      for (int i = 0; i < bin.length; i++) {
        bin[i] == '0'
            ? bin = bin.replaceCharAt(i, '1')
            : bin = bin.replaceCharAt(i, '0');
      }
      int i = bin.length - 1;
      if (bin[i] != '0') {
        while (bin[i] == '1') {
          bin = bin.replaceCharAt(i, '0');
          i--;
        }
        bin = bin.replaceCharAt(i, '1');
      } else {
        bin = bin.replaceCharAt(i, '1');
      }
    }
    int res = 0;
    for (int j = nbits - 1; j >= 0; j--) {
      if (bin[j] == '1') {
        res += pow(2, nbits - 1 - j).round();
      }
    }
    if (isNeg && signed) res = -res;
    return res.toString();
  }


  int maxVal() {
    int max = pow(2, nbits).round()-1;
    if(signed) max = max ~/ 2;
    return max;
  }

  int minVal() {
    if(!signed) return 0;
    return -pow(2, nbits - 1).round();
  }

  Uint8List getSendData() {
    String toSend = decTobin(value.toString());
    toSend = "$name:$toSend";
    int byteAmount = toSend.length+1;
    List<int> list = [byteAmount];
    list.addAll(ascii.encode(toSend));
    return Uint8List.fromList(list);
  }
}



extension on String {
  String replaceCharAt(int index, String newChar) {
    return substring(0, index) + newChar + substring(index + 1);
  }
}

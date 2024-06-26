class Register {

  String name;
  int value;
  int nbits;

  Register({this.name = "",this.value = 0, this.nbits = 1});

  String decTobin(String dec) {
    int rem = int.parse(dec);
    bool isNeg = rem < 0;
    if(isNeg) {
      rem = -rem;
    }
    String bin = "";
    while(rem != 0 && rem != 1) {
      bin = "${rem%2}${bin}";
      rem = rem ~/ 2;
    }
    bin = "${rem}${bin}";
    while(bin.length < nbits) {
      bin = "0${bin}";
    }

    if(isNeg) {
     for(int i = 0; i < bin.length; i++) {
       bin[i] == '0' ? bin = bin.replaceCharAt(i, '1') : bin = bin.replaceCharAt(i, '0');
     }
     int i = bin.length-1;
     if(bin[i] != '0') {
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

  static String binToDec(String bin) {
      return "";
  }
}

extension on String {
  String replaceCharAt( int index, String newChar) {
    return substring(0, index) + newChar + substring(index + 1);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgressDialogPrimary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var brightness =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    ;
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
      backgroundColor: brightness
          ? Colors.white.withOpacity(0.70)
          : Colors.black.withOpacity(
              0.70), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
    );
  }
}

String getFileName(String? url) {
  if (url == null || url.trim().length == 0) return "";
  RegExp regExp = new RegExp(r'.+(/|%2F)(.+)\?.+');
  //This Regex won't work if you remove ?alt...token
  var matches = regExp.allMatches(url);

  var match = matches.elementAt(0);
  print("${Uri.decodeFull(match.group(2)!)}");
  return Uri.decodeFull(match.group(2)!);
}


class LimitRangeTextInputFormatter extends TextInputFormatter {
  LimitRangeTextInputFormatter(this.min, this.max, {this.defaultIfEmpty = false});

  final int min;
  final int max;
  final bool defaultIfEmpty;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    int? value = int.tryParse(newValue.text);
    String? enforceValue;
    if(value != null) {
      if (value < min) {
        enforceValue = min.toString();
      } else if (value > max) {
        enforceValue = max.toString();
      }
    }
    else{
      if(defaultIfEmpty) {
        enforceValue = min.toString();
      }
    }
    // filtered interval result
    if(enforceValue != null){
      return TextEditingValue(text: enforceValue, selection: TextSelection.collapsed(offset: enforceValue.length));
    }
    // value that fit requirements
    return newValue;
  }
}

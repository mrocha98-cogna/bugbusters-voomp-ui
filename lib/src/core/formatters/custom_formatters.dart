import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 11) newText = newText.substring(0, 11);

    String formatted = "";
    for (int i = 0; i < newText.length; i++) {
      if (i == 3 || i == 6) formatted += ".";
      else if (i == 9) formatted += "-";
      formatted += newText[i];
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 11) newText = newText.substring(0, 11);

    String formatted = "";
    if (newText.isNotEmpty) {
      formatted = "(";
      for (int i = 0; i < newText.length; i++) {
        if (i == 2) formatted += ") ";
        else if (i == 7) formatted += "-";
        formatted += newText[i];
      }
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

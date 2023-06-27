import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension CommaSeparatedEditingController on TextEditingController {
  String get textWithoutCommas => text.replaceAll(',', '');
}

class QuantityInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final formatter = NumberFormat('#,###.########', 'en_US');
    final parts = newValue.text.split('.');
    String newText = parts[0];
    if (newText == '') {
      newText = '0';
    }
    final parsedValue =
        int.tryParse(newText.replaceAll(formatter.symbols.GROUP_SEP, ''));
    if (parsedValue != null) {
      final newString = formatter.format(parsedValue) +
          (parts.length == 1 ? '' : '.${parts[1].replaceAll(',', '')}');
      try {
        return TextEditingValue(
          text: newString,
          selection: TextSelection.collapsed(
              offset: newValue.selection.baseOffset +
                  (newString.length - newValue.text.length)),
        );
      } catch (_) {
        return newValue.copyWith(text: newString);
      }
    }
    return oldValue;
  }
}

import 'package:flutter/services.dart';
import 'package:raven_back/extensions/extensions.dart';
import 'package:raven_back/utilities/utilities.dart';
import 'dart:math' as math;

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class MainAssetNameTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase();
    text = ['RVN', 'RAVEN', 'RAVENCOIN'].contains(text)
        ? ''
        : text
            .replaceAll('..', '.')
            .replaceAll('._', '.')
            .replaceAll('__', '_')
            .replaceAll('_.', '_')
            .replaceAll('//', '/');
    if (text.startsWith('_') || text.startsWith('.')) {
      text = text.substring(1, text.length);
    }
    if (newValue.text.length == text.length) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return TextEditingValue(
      text: text,
      selection: newValue.selection.baseOffset < oldValue.selection.baseOffset
          ? newValue.selection
          : oldValue.selection,
    );
  }
}

class CommaIntValueTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.isInt
        ? newValue.text.toInt().toCommaString()
        : newValue.text;
    if (newValue.text.length == text.length) {
      return newValue;
    }
    return TextEditingValue(
      text: text,
      //selection: oldValue.selection,
      //selection: newValue.selection.copyWith(
      //    baseOffset: newValue.selection.baseOffset + 2,
      //    extentOffset: newValue.selection.extentOffset + 2),
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains('.') &&
        value.substring(value.indexOf('.') + 1).length <= decimalRange) {
      var split = value.split('.');
      var tail = split
          .sublist(1)
          .join()
          .replaceAll('.', '')
          .replaceAll(',', '')
          .replaceAll('-', '')
          .replaceAll(' ', '');
      truncated = split.first + '.' + tail;
      newSelection = newValue.selection.copyWith(
          baseOffset: truncated.length, extentOffset: truncated.length);
    } else if (value.contains('.') &&
        value.substring(value.indexOf('.') + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == '.') {
      truncated = '0.';
      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }
    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

class VerifierStringTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = utils.removeCharsOtherThan(newValue.text.toUpperCase(),
        chars: utils.strings.verifierStringAllowed);
    if (newValue.text.length == text.length) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return TextEditingValue(
      text: text,
      selection: oldValue.selection,
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';

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

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
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
    String text = newValue.text.toUpperCase();
    text = <String>['RVN', 'RAVEN', 'RAVENCOIN'].contains(text)
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
    final String text = newValue.text.isInt
        ? newValue.text.asSatsInt().toCommaString()
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
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);
  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    final String value = newValue.text
        .replaceAll(',', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');

    if (value.contains('.') &&
        value.substring(value.indexOf('.') + 1).length <= decimalRange) {
      final List<String> split = value.split('.');
      final String tail = split.sublist(1).join().replaceAll('.', '');
      truncated = '${split.first}.$tail';
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
    );
  }
}

class VerifierStringTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = removeCharsOtherThan(newValue.text.toUpperCase(),
        chars: verifierStringAllowed);
    if (newValue.text.length == text.length) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return TextEditingValue(
      text: text,
      selection: oldValue.selection,
    );
  }
}

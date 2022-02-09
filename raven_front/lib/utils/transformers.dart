import 'package:flutter/services.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_back/utils/utilities.dart';

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
    var text = utils.removeCharsOtherThan(newValue.text.toUpperCase(),
        chars: utils.strings.mainAssetAllowed);
    text = ['RVN', 'RAVEN', 'RAVENCOIN'].contains(text)
        ? ''
        : text
            .replaceAll('..', '.')
            .replaceAll('._', '.')
            .replaceAll('__', '_')
            .replaceAll('_.', '_');
    if (text.startsWith('_') || text.startsWith('.')) {
      text = text.substring(1, text.length);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
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
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

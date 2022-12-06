import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/utilities/utilities.dart';

extension StringNumericExtension on String {
  /// assumes the string is an amount
  int toSats([int divisibility = 8]) {
    String x = trim();
    if (x == '' || x == '.') {
      return 0;
    }
    if (!x.contains('.')) {
      x = '$x.';
    }
    final List<String> s = x.split('.');
    if (s.length > 2) {
      return 0;
    }
    if (s.last.length > divisibility) {
      s[1] = s[1].substring(0, divisibility);
    } else if (s.last.length < divisibility) {
      s[1] = s[1] + '0' * (divisibility - s.last.length);
    }
    final String textSats = '${s.first}${s.last}';
    if (textSats.length > 19) {
      return int.parse(textSats.substring(0, 19));
    }
    return int.parse(textSats);
  }

  /// assumes the string is already in sats.
  int asSatsInt() {
    String text = removeChars(
      split('.').first,
      chars: utils.strings.punctuation + utils.strings.whiteSapce,
    );
    if (text.length > 19) {
      text = text.substring(0, 19);
    }
    if (text == '') {
      return 0;
    }
    //if (int.parse(text) > 21000000000) {
    //  return 21000000000;
    //}
    return text.asInt();
  }
}

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      toString().split('.').first.asSatsInt().toCommaString() +
      (toString().split('.').last == '0'
          ? ''
          : '.${toString().split('.').last}');
}

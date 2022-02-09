import 'dart:typed_data';

import 'package:raven_back/utils/utilities.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase({bool underscoreAsSpace = false}) =>
      replaceAll(RegExp(' +'), ' ')
          // for enums especially:
          .replaceAll(underscoreAsSpace ? RegExp('_+') : ' ', ' ')
          .split(' ')
          .map((str) => str.toCapitalized())
          .join(' ');
}

extension StringTrimExtension on String {
  String trimPattern(String pattern) {
    var tempString = this;
    if (startsWith(pattern)) {
      tempString = substring(pattern.length, tempString.length);
    }
    if (endsWith(pattern)) {
      tempString = substring(0, tempString.length - pattern.length);
    }
    return tempString;
  }
}

extension StringBytesExtension on String {
  Uint8List get bytes => Uint8List.fromList(codeUnits);
}

extension StringNumericExtension on String {
  bool get isInt {
    try {
      int.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  int toInt() {
    var text = utils.removeChars(
      // ignore: unnecessary_this
      this.split('.').first,
      chars: utils.strings.punctuation + utils.strings.whiteSapce,
    );
    if (text == '') {
      return 0;
    }
    if (int.parse(text) > 21000000000) {
      return 21000000000;
    }
    return asInt();
  }

  int asInt() {
    try {
      return int.parse(this);
    } catch (e) {
      return 0;
    }
  }
}

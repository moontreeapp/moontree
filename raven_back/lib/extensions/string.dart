import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
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

  String cutOutMiddle({int length = 6}) {
    if (this.length > length * 2) {
      return substring(0, length) +
          '...' +
          substring(this.length - length, this.length);
    }
    return this;
  }
}

extension StringBytesExtension on String {
  Uint8List get bytes => Uint8List.fromList(codeUnits);
  Uint8List get hexBytes => Uint8List.fromList(hex.decode(this));
  List<int> get uft8Bytes => utf8.encode(this);
}

extension StringCharactersExtension on String {
  List get characters => split('');
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
      split('.').first,
      chars: utils.strings.punctuation + utils.strings.whiteSapce,
    );
    if (text == '') {
      return 0;
    }
    if (int.parse(text) > 21000000000) {
      return 21000000000;
    }
    return text.asInt();
  }

  int asInt() {
    try {
      return int.parse(this);
    } catch (e) {
      return 0;
    }
  }
}

extension IntReadableNumericExtension on int {
  String toCommaString({String comma = ','}) {
    var str = toString();
    var i = 0;
    var ret = '';
    for (var c in str.characters.reversed) {
      if (i == 3) {
        ret = '$c$comma$ret';
        i = 1;
      } else {
        ret = '$c$ret';
        i += 1;
      }
    }
    return ret;
  }
}

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      toString().split('.').first.toInt().toCommaString() +
      (toString().split('.').last == '0'
          ? ''
          : '.' + toString().split('.').last);
}

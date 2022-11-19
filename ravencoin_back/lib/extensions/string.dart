import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:bs58/bs58.dart';
import 'package:ravencoin_back/utilities/utilities.dart';
import 'package:ravencoin_back/utilities/transform.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      1 < length ? substring(0, 1).toUpperCase() + substring(1) : toUpperCase();

  String toTitleCase({bool underscoresAsSpace = false}) =>
      replaceAll(RegExp(' +'), ' ')
          // for enums especially:
          .replaceAll(underscoresAsSpace ? RegExp('_+') : ' ', ' ')
          .split(' ')
          .map((String str) => str.toCapitalized())
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
  Uint8List get bytesUint8 => Uint8List.fromList(bytes);
  Uint8List get hexBytes => Uint8List.fromList(hex.decode(this));
  Uint8List get hexBytesForScript =>
      Uint8List.fromList([0x54, 0x20] + hex.decode(this));
  List<int> get bytes => utf8.encode(this);
  String get hexToUTF8 => utf8.decode(hexBytes);
  String get hexToAscii => List.generate(
        length ~/ 2,
        (i) => String.fromCharCode(
            int.parse(substring(i * 2, (i * 2) + 2), radix: 16)),
      ).join();
  Uint8List get base58Decode => base58.decode(this);
}

extension StringCharactersExtension on String {
  List get characters => split('');
}

extension StringNumericExtension on String {
  /// assumes the string is an amount
  int toSats([divisibility = 8]) {
    var x = trim();
    if (x == '' || x == '.') {
      return 0;
    }
    if (!x.contains('.')) {
      x = '$x.';
    }
    var s = x.split('.');
    if (s.length > 2) {
      return 0;
    }
    if (s.last.length > divisibility) {
      s[1] = s[1].substring(0, divisibility);
    } else if (s.last.length < divisibility) {
      s[1] = s[1] + '0' * (divisibility - s.last.length);
    }
    var textSats = '${s.first}${s.last}';
    if (textSats.length > 19) {
      return int.parse(textSats.substring(0, 19));
    }
    return int.parse(textSats);
  }

  /// assumes the string is already in sats.
  int asSatsInt() {
    var text = utils.removeChars(
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

  int asInt() {
    try {
      return int.parse(this);
    } catch (e) {
      return 0;
    }
  }

  double toDouble() {
    return double.parse(trim().split(',').join(''));
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

  double toAmount() => satToAmount(this);
}

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      toString().split('.').first.asSatsInt().toCommaString() +
      (toString().split('.').last == '0'
          ? ''
          : '.' + toString().split('.').last);
}

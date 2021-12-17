import 'dart:typed_data';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase([bool underscoreAsSpace = false]) =>
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

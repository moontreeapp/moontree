import 'package:raven_front/utils/strings.dart';

bool stringIsInt(String text) {
  try {
    int.parse(text);
    return true;
  } catch (e) {
    return false;
  }
}

String removeChars(
  String text, {
  String? chars,
}) {
  chars = chars ?? Strings.punctuationProblematic;
  for (var char in characters(chars)) {
    text = text.replaceAll(char, '');
  }
  return text;
}

/// Unused...

List enumerate(String text) {
  return List<int>.generate(text.length, (i) => (i + 1) - 1);
}

List characters(String text) {
  return text.split('');
}

String removeCharsOtherThan(
  String text, {
  String? chars,
}) {
  chars = chars ?? Strings.alphanumeric;
  var ret = '';
  for (var char in characters(text)) {
    if (chars.contains(char)) {
      ret = '$ret$char';
    }
  }
  return ret;
}

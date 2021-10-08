import 'package:raven_mobile/utils/strings.dart';

List enumerate(String text) {
  return List<int>.generate(text.length, (i) => i + 1);
}

List characters(String text) {
  return text.split('');
}

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
  //for (var ix in enumerate(chars)) {
  //  text = text.replaceAll(chars.substring(ix - 1, ix), '');
  //}
  for (var char in characters(chars)) {
    text = text.replaceAll(char, '');
  }
  return text;
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

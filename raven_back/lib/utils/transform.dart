import 'dart:math';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_back/utils/strings.dart';

double satToAmount(int x, {int divisibility = 8}) =>
    (x / divisor(divisibility));
int amountToSat(double x, {int divisibility = 8}) =>
    (x * divisor(divisibility)).floor().toInt();

int divisor(int divisibility) => int.parse('1' + ('0' * min(divisibility, 8)));

String removeChars(
  String text, {
  String? chars,
}) {
  chars = chars ?? punctuationProblematic;
  for (var char in chars.characters) {
    text = text.replaceAll(char, '');
  }
  return text;
}

List enumerate(String text) {
  return List<int>.generate(text.length, (i) => (i + 1) - 1);
}

String removeCharsOtherThan(
  String text, {
  String? chars,
}) {
  chars = chars ?? alphanumeric;
  var ret = '';
  for (var char in text.characters) {
    if (chars.contains(char)) {
      ret = '$ret$char';
    }
  }
  return ret;
}

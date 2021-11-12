import 'dart:ui';
import 'package:tuple/tuple.dart';
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

/// this function takes a string and returns two colors
/// it is meant to be used to determine the gradient colors for uniconed assets
/// in a deterministic way
/// there are 255**3 (16,581,375) possible colors and
/// roughly 38 possible symbols ** 30 digits: up to 2.47e+47 possibilities
/// we want two colors though so its really just
/// what I kind of want is longer strings to make more nuanced stuff
/// while shorter strings (min 3) produce pure tones or close to them, harmonics
/// ok, so here's part of the plan for this hashlike function:
/// (take off the last character if it's a symbole other than . and _),
/// split the string in half.
Tuple2<Color, Color> getGradient(String s) {
  s = verifyGradientString(s);
  var tuple = splitGradientString(s);
  return Tuple2(getGradientColor(tuple.item1), getGradientColor(tuple.item2));
}

String verifyGradientString(String s) {
  if (s.length < 3)
    throw ArgumentError('string should be at least 3 characters long');
  s = s.toUpperCase();
  if (!s.contains(RegExp(r'^[A-Z0-9_.]*$')))
    throw ArgumentError('string is limited to letters, numbers, _, and .');
  if (!s.startsWith('_')) throw ArgumentError('string cannot start with _');
  return s;
}

Tuple2<String, String> splitGradientString(String s) {
  var middle = s.length ~/ 2 + 1;
  return Tuple2(s.substring(0, middle), s.substring(middle, s.length));
}

Color getGradientColor(String s) {
  // convert string to 3 integers (ignore _ .)
  // '0' = 0,0,0
  // '1' = 0,0,255
  // '2' = 0,255,0
  // ...
  // '7' = 255,255,255
  // '8' = 0,0,128
  // '9' = 0,128,0
  // 'A' = 0,128,128
  // 'B' = 128,0,0
  // 'C' = 128,0,128
  // 'D' = 128,128,0
  // 'E' = 128,128,128
  // 'F' = 0,0,64
  //...
  // 'L' = 64,64,64
  //...
  // 'T' = 0,0,32
  //...
  // 'Z' = 32,32,32
  // '00' = 0,0,16
  //...
  // 'ZZ' = 1,1,1
  // '000' =
  //...
  // 'ZZZ' = 1,1,1
  // idk, lets try something else...

  var encoding = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._';
  var nuanceEncoding = [256, 128, 64, 32, 16, 8, 4, 2, 1];
  encoding.indexOf('A');
  // the longer the string, the more nuanced the numbers. for example:
  // 'a' = 0,0,255 while 'abcdefghijklmnopqrstuvwxyz' = 169,23,72
  // colors = 16,777,216

  /** ok I get it
   * I'm trying to transform the space of colors to get the mapping.
   * instead of 0,0,0 -> 0,0,1 -> ... 255,255,255,
   * couting up all 16,777,216 possible colors incrementally, 
   * I want to transform the space, so that it's still a perfect hash function
   * but jumps around from 0,0,0 -> 0,0,255 -> 0,255,0 etc, 
   * eventually ending at something int he middle like 128,126,128?
   * (127,127,127 would be very near the beginning since it's half).
   * so I can order the orderings and take the nth one that I prefer
   * ok, so (n-1)! is the number of possible orderings, which means we're
   * dealing with numbers bigger than God.
   * if the first ordering is simple incremental cardinality, and the last is
   * that but in reverse... we can say we want the middle right? wouldn't that
   * give us the greatest biforcation from the start: White, Black, etc.. 
   * anyway, I'm gonna shelve this for now.
   */

  var red = 0;
  var green = 0;
  var blue = 0;

  // convert to color:
  return Color.fromRGBO(red, green, blue, 1.0);
}

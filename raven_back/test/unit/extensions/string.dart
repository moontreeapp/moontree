// dart test test/unit/extensions/string.dart
import 'package:test/test.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_back/extensions/validation.dart';

void main() {
  group('String Extensions', () {
    test('toCapitalized', () {
      expect(''.toCapitalized(), '');
      expect('abc'.toCapitalized(), 'Abc');
      expect('foo bar'.toCapitalized(), 'Foo bar');
      expect('fOO BaR'.toCapitalized(), 'FOO BaR');
    });
    test('toTitleCase', () {
      expect(''.toTitleCase(), '');
      expect('abc'.toTitleCase(), 'Abc');
      expect('foo bar'.toTitleCase(), 'Foo Bar');
      expect('fOO BaR'.toTitleCase(), 'FOO BaR');
      expect('user_name'.toTitleCase(), 'User_name');
      expect('user_name'.toTitleCase(underscoresAsSpace: true), 'User Name');
    });
    test('trimPattern', () {
      expect(''.trimPattern(''), '');
      expect('abc'.trimPattern(''), 'abc');
      expect('abc'.trimPattern('a'), 'bc');
      expect('  abc '.trimPattern('  '), 'abc ');
      //expect('abc j xyz'.trimPattern(RegExp(r"(\w+)")), 'j'); not coded yet
    });
    test('bytes', () {
      expect(''.bytes, []);
      expect('abc'.bytes, [97, 98, 99]);
    });
    test('test characters', () {
      expect('abc'.characters, ['a', 'b', 'c']);
    });
    test('test stringIsInt', () {
      expect('abc'.isInt, false);
      expect('a1'.isInt, false);
      expect('123'.isInt, true);
      expect('123.0'.isInt, false);
      expect('123.1'.isInt, false);
      expect('123.'.isInt, false);
      expect('.0'.isInt, false);
    });
  });
}

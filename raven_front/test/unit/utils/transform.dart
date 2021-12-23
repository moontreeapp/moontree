import 'package:flutter_test/flutter_test.dart';
import 'package:raven_front/utils/transform.dart';

void main() {
  test('test enumerate', () {
    expect(enumerate('abc'), [0, 1, 2]);
  });
  test('test characters', () {
    expect(characters('abc'), ['a', 'b', 'c']);
  });
  test('test stringIsInt', () {
    expect(stringIsInt('abc'), false);
    expect(stringIsInt('a1'), false);
    expect(stringIsInt('123'), true);
    expect(stringIsInt('123.0'), false);
    expect(stringIsInt('123.1'), false);
    expect(stringIsInt('123.'), false);
    expect(stringIsInt('.0'), false);
  });
  test('test removeChars', () {
    expect(removeChars('abcabc', chars: 'b'), 'acac');
    expect(removeChars('abcabc', chars: 'bc'), 'aa');
    expect(removeChars('a.&_ #'), 'a.&_ #');
    expect(removeChars('a?`<>'), 'a');
  });
  test('test removeCharsOtherThan', () {
    expect(removeCharsOtherThan('abcabc', chars: 'b'), 'bb');
    expect(removeCharsOtherThan('abcabc', chars: 'bc'), 'bcbc');
    expect(removeCharsOtherThan('a.&_ #'), 'a');
    expect(removeCharsOtherThan('a?`<>'), 'a');
  });
}

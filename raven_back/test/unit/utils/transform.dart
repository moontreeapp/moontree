import 'package:test/test.dart';
import 'package:raven_back/utilities/transform.dart';

void main() {
  /* 
  * so we can put assets on the same basis as rvn, one asset satoshi = one rvn sat
  */

  test('sats to amount', () {
    expect(satToAmount(1012345678), 10.12345678);
    expect(satToAmount(1012300000000), 10123);
    expect(satToAmount(10), 0.00000010);
  });

  test('amount to sat', () {
    expect(amountToSat(10.12345678), 1012345678);
    expect(amountToSat(10123), 1012300000000);
    expect(amountToSat(0.00000010), 10);
  });

  test('test enumerate', () {
    expect(enumerate('abc'), [0, 1, 2]);
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

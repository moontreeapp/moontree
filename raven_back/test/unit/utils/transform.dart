import 'package:test/test.dart';
import 'package:raven_back/utils/transform.dart';

void main() {
  /* there are two ways to put assets in the database without using double.
  * lets look at rvn first:
  *   rvn divisibility: 8 -> 1012345678 is 10.12345678
  *
  * so we can put assets on the same basis as rvn, one asset satoshi = one rvn sat
  * I think this is not preferred because it looks like divisility = 8 but its not. 
  *   mt0 alternatively: 2-> 1012000000 is 10.12
  * maybe this would be preferred if we saved the values as a string but we don't
  *
  * or we can save the asset in the database without the extra zeros. where
  * one rvn sat = x asset sats. Either way is a fine way of thinking aobut it 
  * but I think this is preferred because it simplifies calculations:
  * mt0 divisibility: 2 -> 1012345678 is 10123456.78 
  * mt0      meaning:            1012 is 10.12
  */

  test('sats to amount', () {
    expect(satToAmount(1012345678), 10.12345678);
    expect(satToAmount(1012300000000), 10123);
    expect(satToAmount(10), 0.00000010);

    expect(satToAmount(1012345678, divisibility: 2), 10123456.78);
    expect(satToAmount(1012300000, divisibility: 2), 10123000);
    expect(satToAmount(10, divisibility: 2), 0.10);
  });

  test('amount to sat', () {
    expect(amountToSat(10.12345678), 1012345678);
    expect(amountToSat(10123), 1012300000000);
    expect(amountToSat(0.00000010), 10);

    expect(amountToSat(10.12345678, divisibility: 2), 1012);
    expect(amountToSat(10123, divisibility: 2), 1012300);
    expect(amountToSat(0.10, divisibility: 2), 10);

    // round down if more detail provided? or error? this shouldn't happen.
    expect(amountToSat(10.129, divisibility: 2), 1012);
    expect(amountToSat(0.00000010, divisibility: 2), 0);
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

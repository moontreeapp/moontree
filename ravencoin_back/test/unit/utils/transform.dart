import 'package:test/test.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

void main() {
  /* 
  * so we can put assets on the same basis as rvn, one asset satoshi = one rvn sat
  */

  test('sats to amount', () {
    expect(1012345678.asCoin, 10.12345678);
    expect(1012300000000.asCoin, 10123);
    expect(10.asCoin, 0.00000010);
  });

  test('amount to sat', () {
    expect(10.12345678.asSats, 1012345678);
    expect(10123.asSats, 1012300000000);
    expect(0.00000010.asSats, 10);
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

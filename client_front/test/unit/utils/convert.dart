import 'package:client_front/application/manage/reissue/cubit.dart'
    show asCoinToSats;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test populateData', () {
    expect(asCoinToSats(''), 0);
    expect(asCoinToSats('.'), 0);
    expect(asCoinToSats('0.'), 0);
    expect(asCoinToSats('.0'), 0);
    expect(asCoinToSats('1'), 100000000);
    expect(asCoinToSats('1.'), 100000000);
    expect(asCoinToSats('.1'), 10000000);
    expect(asCoinToSats('.123'), 12300000);
    expect(asCoinToSats('1.0'), 100000000);
    expect(asCoinToSats('1.1'), 110000000);
    expect(asCoinToSats('1.23'), 123000000);
    expect(asCoinToSats('123'), 12300000000);
    expect(asCoinToSats('123.456'), 12345600000);
    expect(asCoinToSats('123.12345678'), 12312345678);
    expect(asCoinToSats('123.123456789'), null);
    expect(asCoinToSats('21000000000'), 2100000000000000000);
    expect(asCoinToSats('21000000001'), null);
    expect(asCoinToSats('21000000000.1'), null);
    expect(asCoinToSats('21000000000.00000001'), null);
  });
}

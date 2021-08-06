// dart test test/sandbox/balances_test.dart
import 'package:raven/models/balance.dart';
import 'package:raven/models/balances.dart';
import 'package:test/test.dart';

void main() {
  test('balances init 1', () {
    var bal = Balances({'String': Balance(confirmed: 1, unconfirmed: 0)});
  });

  test('balances init 2', () {
    var bal = Balances();
    bal['String'] = Balance(confirmed: 1, unconfirmed: 0);
  });

  test('balances has typical map functions', () {
    var bal = Balances({'String': Balance(confirmed: 1, unconfirmed: 0)});
    expect(bal.length, 1);
  });
}

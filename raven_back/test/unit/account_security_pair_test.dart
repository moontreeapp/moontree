// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/change.dart';
import 'package:test/test.dart';

import 'package:raven/account_security_pair.dart';
import '../fixtures/histories.dart';
import '../fixtures/fixtures.dart' as fixtures;

void main() async {
  setUp(fixtures.useFixtureSources);

  test('AccountSecurityPair is unique in Set', () {
    var s = <AccountSecurityPair>{};
    var pair = AccountSecurityPair(
        'a', Security(symbol: 'RVN', securityType: SecurityType.Crypto));
    s.add(pair);
    s.add(pair);
    expect(s.length, 1);
  });

  test('uniquePairsFromHistoryChanges', () {
    var changes = [
      Added(0, histories().map['0']),
      Added(1, histories().map['1']),
      Updated(0, histories().map['0'])
    ];
    var pairs = uniquePairsFromHistoryChanges(changes);
    expect(pairs, {
      AccountSecurityPair('a0', RVN),
      AccountSecurityPair('a0', USD),
    });
  });
}

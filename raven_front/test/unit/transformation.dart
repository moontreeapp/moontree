import 'package:flutter_test/flutter_test.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/text.dart';

void main() {
  test('test amount to sat', () {
    expect(TextComponents().rvnSats(0.00000123), 123);
    expect(TextComponents().amountSats(0.00000123), 123);
    expect(TextComponents().amountSats(0.0123, precision: 4), 123);
  });

  test('test sat to amount', () {
    expect(TextComponents().satsRVN(123), 0.00000123);
    expect(TextComponents().satsToAmount(123), 0.00000123);
    expect(TextComponents().satsToAmount(123, precision: 4), 0.0123);
    expect(TextComponents().satsToAmount(123, precision: 0), 123);
  });

  test('test RVN as readable USD', () {
    expect(TextComponents().rvnUSD(0.0), r'$ 0.00');
    expect(TextComponents().rvnUSD(123.0), r'$ 0.00');
    expect(TextComponents().rvnUSD(123.0, rate: 0.1), r'$ 12.30');
  });

  test('test Asset as readable USD', () {
    // testing this I discovered something: we save rvn transfers as sats (sats in balances)
    // but I think assets are not in sats. this hasn't been a problem yet because
    // we have been passing integer amounts around. and we modified the view to
    // assume it was an amount, not sats when it's a ravenAsset, but that's not right
    // and we sold have trouble in the balance anyway when we start passing doubles around
    // since it expects integers because its in sats. anyway, we either need to
    // translate the amount to sats when saving balances based on percision, but
    // wait does that mean we need to save it earlier? in the vouts in the amount?
    // I think so I think we assumed the amount is in sats too... but its not when
    // it comes from electrum
    var security =
        Security(symbol: 'MOONTREE', securityType: SecurityType.RavenAsset);
    expect(TextComponents().securityAsReadable(0, symbol: 'MOONTREE'), '0');
    expect(TextComponents().securityAsReadable(123, symbol: 'MOONTREE'), '123');
    expect(TextComponents().securityAsReadable(123, security: security), '123');
    // no rate known (requires additioanl integration tests)
    expect(
        TextComponents().securityAsReadable(0, symbol: 'MOONTREE', asUSD: true),
        r'$ 0.00');
    expect(
        TextComponents()
            .securityAsReadable(123, symbol: 'MOONTREE', asUSD: true),
        r'$ 0.00');
    expect(
        TextComponents()
            .securityAsReadable(123, security: security, asUSD: true),
        r'$ 0.00');
  });
}

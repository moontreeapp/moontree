import 'package:raven/raven.dart';

String toUSDBalance(
        {required double balance,
        required double rate,
        String prefix = '\$ ',
        int precision = 2}) =>
    balance == 0
        ? prefix + '0'
        : prefix + (balance * rate).toStringAsFixed(precision);

int amountAsSats(double amount, {int precision = 8}) =>
    (amount * int.parse('1' + '0' * precision)).toInt();
double satsAsAmount(int sats, {int precision = 8}) =>
    (sats / int.parse('1' + '0' * precision));

/// returns a string representation of the sats (all value is stored as sats in the backend)
String humanReadableSecurity(
  int sats, {
  Security? security,
  String? symbol,
  bool asUSD = false,
}) {
  security ??
      symbol ??
      (() => throw OneOfMultipleMissing(
          'security or symbol required to identify record.'))();
  symbol = security?.symbol ?? symbol ?? 'RVN';
  if (symbol == 'RVN') {
    /// rvn sats -> rvn -> usd
    var asAmount = (symbol == 'RVN'
        ? RavenText.satsRVN(sats)
        : RavenText.satsToAmount(sats));
    return asUSD
        ? RavenText.rvnUSD(RavenText.satsRVN(sats))
        : asAmount.toString();
  }

  /// asset sats -> asset -> rvn -> usd
  security = security ??
      Security(symbol: symbol, securityType: SecurityType.RavenAsset);
  return asUSD
      ? RavenText.rvnUSD(RavenText.satsToAmount(
            sats, /* precision: symbol.precision... */
          ) *
          rates.assetToRVN(security))
      : RavenText.satsToAmount(
          sats, /* precision: symbol.precision... */
        ).toString();
}

class RavenText {
  RavenText();

  static String rvnUSD(double balance) =>
      toUSDBalance(balance: balance, rate: rates.rvnToUSD);

  static int rvnSats(double amount) => amountAsSats(amount);
  static double satsRVN(int amount) => satsAsAmount(amount);

  static double satsToAmount(int sats, {int precision = 8}) =>
      satsAsAmount(sats, precision: precision);
  static int amountSats(double amount, {int precision = 8}) =>
      amountAsSats(amount, precision: precision);

  static String securityAsReadable(int sats,
          {Security? security, String? symbol, bool asUSD = false}) =>
      humanReadableSecurity(sats,
          security: security, symbol: symbol, asUSD: asUSD);
}

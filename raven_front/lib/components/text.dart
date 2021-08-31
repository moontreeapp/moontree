import 'package:raven/raven.dart';

String toUSDBalance(
        {required double balance,
        required double rate,
        String prefix = '\$ ',
        int percision = 2}) =>
    balance == 0
        ? prefix + '0'
        : prefix + (balance * rate).toStringAsFixed(percision);

int amountAsSats(double amount, {int percision = 8}) =>
    (amount * int.parse('1' + '0' * percision)).toInt();
double satsAsAmount(int sats, {int percision = 8}) =>
    (sats / int.parse('1' + '0' * percision));

/// asset sats -> asset -> rvn -> usd
/// rvn sats -> rvn -> usd
String securityToUSD(int sats, {Security? security, String? symbol}) {
  security ??
      symbol ??
      (() => throw OneOfMultipleMissing(
          'security or symbol required to identify record.'))();
  security = Security(
      symbol: security?.symbol ?? symbol ?? '',
      securityType: SecurityType.RavenAsset); // only used for assets
  return security.symbol == 'RVN'
      ? RavenText.rvnUSD(RavenText.satsRVN(sats))
      : RavenText.rvnUSD(
          RavenText.satsToAmount(sats) * rates.assetToRVN(security));
}

class RavenText {
  RavenText();

  static String rvnUSD(double balance) =>
      toUSDBalance(balance: balance, rate: rates.rvnToUSD);
  static int rvnSats(double amount) => amountAsSats(amount);
  static double satsRVN(int amount) => satsAsAmount(amount);
  static double satsToAmount(int sats) => satsAsAmount(sats);
  static int amountSats(double amount) => amountAsSats(amount);
  static String securityInUSD(int sats, {Security? security, String? symbol}) =>
      securityToUSD(sats, security: security, symbol: symbol);
}

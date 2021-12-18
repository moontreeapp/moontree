import 'package:intl/intl.dart';
import 'package:raven_back/raven_back.dart';

class TextComponents {
  TextComponents();

  String rvnUSD(
    double balance, {
    double? rate,
    String prefix = '\$ ',
  }) =>
      balance == 0
          ? NumberFormat('$prefix#,##0.00', 'en_US').format(0)
          : NumberFormat('$prefix#,##0.00', 'en_US')
              .format((balance * (rate ?? services.rate.rvnToUSD ?? 0.0)));

  int rvnSats(double amount) => _amountAsSats(amount);
  double satsRVN(int amount) => _satsAsAmount(amount);

  int amountSats(double amount, {int precision = 8}) =>
      _amountAsSats(amount, precision: precision);
  double satsToAmount(int sats, {int precision = 8}) =>
      _satsAsAmount(sats, precision: precision);

  /// returns a string representation of the value as amount or fiat
  String securityAsReadable(
    int amount, {
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
      var asAmount = satsRVN(amount);
      return asUSD
          ? rvnUSD(asAmount)
          : NumberFormat('#,##0.########', 'en_US').format(asAmount);
    }
    // asset sats -> asset -> rvn -> usd
    security = security ??
        securities.bySymbolSecurityType
            .getOne(symbol, SecurityType.RavenAsset) ??
        Security(symbol: symbol, securityType: SecurityType.RavenAsset);
    return asUSD
        ? rvnUSD(amount * (services.rate.assetToRVN(security) ?? 0.0))
        : NumberFormat(
                '#,##0${(security.asset?.precision ?? 0) > 0 ? '.' + '0' * (security.asset?.precision ?? 0) : ''}',
                'en_US')
            .format(amount);
  }

  static int _amountAsSats(double amount, {int precision = 8}) =>
      (amount * int.parse('1' + '0' * precision)).toInt();

  static double _satsAsAmount(int sats, {int precision = 8}) =>
      (sats / int.parse('1' + '0' * precision));
}

import 'package:intl/intl.dart';
import 'package:raven/raven.dart';

class TextComponents {
  TextComponents();

  String rvnUSD(
    double balance, {
    double? rate,
    String prefix = '\$ ',
    int precision = 2,
  }) =>
      balance == 0
          ? NumberFormat('$prefix#,##0.00', 'en_US').format(0)
          : NumberFormat('$prefix#,##0.00', 'en_US').format((balance *
              (rate ??
                  services.rate.rvnToUSD ??
                  0.0)) /*.toStringAsFixed(precision)*/);

  int rvnSats(double amount) => _amountAsSats(amount);
  double satsRVN(int amount) => _satsAsAmount(amount);

  double satsToAmount(int sats, {int precision = 8}) =>
      _satsAsAmount(sats, precision: precision);
  int amountSats(double amount, {int precision = 8}) =>
      _amountAsSats(amount, precision: precision);

  /// returns a string representation of the sats (all value is stored as sats in the backend)
  String securityAsReadable(
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
      var asAmount = (symbol == 'RVN' ? satsRVN(sats) : satsToAmount(sats));
      return asUSD
          ? rvnUSD(satsRVN(sats))
          : NumberFormat('#,##0.########', 'en_US').format(asAmount);
    }
    // asset sats -> asset -> rvn -> usd
    security = security ??
        securities.bySymbolSecurityType
            .getOne(symbol, SecurityType.RavenAsset) ??
        Security(symbol: symbol, securityType: SecurityType.RavenAsset);

    return asUSD
        ? rvnUSD(satsToAmount(sats, precision: 2) *
            (services.rate.assetToRVN(security) ?? 0.0))
        : NumberFormat(
                '#,##0${(security.precision ?? 0) > 0 ? '.' + '0' * (security.precision ?? 0) : ''}',
                'en_US')
            .format(satsToAmount(sats, precision: security.precision ?? 8));
  }

  static int _amountAsSats(double amount, {int precision = 8}) =>
      (amount * int.parse('1' + '0' * precision)).toInt();

  static double _satsAsAmount(int sats, {int precision = 8}) =>
      (sats / int.parse('1' + '0' * precision));
}

import 'package:intl/intl.dart';
import 'package:raven_back/raven_back.dart';

class TextComponents {
  TextComponents();

  String rvnUSD(
    double amount, {
    double? rate,
    String prefix = '\$ ',
  }) =>
      amount == 0
          ? NumberFormat('$prefix#,##0.00', 'en_US').format(0)
          : NumberFormat('$prefix#,##0.00', 'en_US')
              .format((amount * (rate ?? services.rate.rvnToUSD ?? 0.0)));

  /// returns a string representation of the value as amount or fiat
  String securityAsReadable(
    int sats, {
    Security? security,
    String? symbol,
    bool asUSD = false,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == 'RVN') {
      var asAmount = satToAmount(sats);
      return asUSD
          ? rvnUSD(asAmount)
          : NumberFormat('#,##0.########', 'en_US').format(asAmount);
    }
    // asset sats -> asset -> rvn -> usd
    security = getSecurityOf(symbol: symbol, security: security);
    var asset = getAssetOf(symbol: symbol);
    var asAmount = satToAmount(sats, divisibility: asset?.divisibility ?? 0);
    return asUSD
        ? rvnUSD(asAmount * (services.rate.assetToRVN(security) ?? 0.0))
        : NumberFormat(
                '#,##0${(asset?.divisibility ?? 0) > 0 ? '.' + '#' * (asset?.divisibility ?? 0) : ''}',
                'en_US')
            .format(asAmount);
  }

  Security getSecurityOf({
    Security? security,
    String? symbol,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == 'RVN') {
      return res.securities.RVN;
    }
    if (symbol == 'USD') {
      return res.securities.USD;
    }
    return security ??
        res.securities.bySymbolSecurityType
            .getOne(symbol, SecurityType.RavenAsset) ??
        Security(symbol: symbol, securityType: SecurityType.RavenAsset);
  }

  Asset? getAssetOf({
    Security? security,
    String? symbol,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == 'RVN') {
      return null;
    }
    security = security ??
        res.securities.bySymbolSecurityType
            .getOne(symbol, SecurityType.RavenAsset) ??
        Security(symbol: symbol, securityType: SecurityType.RavenAsset);
    return res.assets.bySymbol.getOne(symbol);
  }

  String getSymbol({
    Security? security,
    String? symbol,
  }) {
    security ??
        symbol ??
        (() => throw OneOfMultipleMissing(
            'security or symbol required to identify record.'))();
    return security?.symbol ?? symbol ?? 'RVN';
  }
}

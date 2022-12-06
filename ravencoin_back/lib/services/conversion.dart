import 'package:intl/intl.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class ConversionService {
  String rvnUSD(
    double amount, {
    double? rate,
    String prefix = r'$ ',
  }) =>
      amount == 0
          ? NumberFormat('$prefix#,##0.00', 'en_US').format(0)
          : NumberFormat('$prefix#,##0.00', 'en_US')
              .format(amount * (rate ?? services.rate.rvnToUSD ?? 0.0));

  /// returns a string representation of the value as amount or fiat
  String securityAsReadable(
    int sats, {
    Security? security,
    String? symbol,
    bool asUSD = false,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == pros.securities.currentCoin.symbol) {
      final double asAmount = satToAmount(sats);
      return asUSD
          ? rvnUSD(asAmount)
          : NumberFormat('#,##0.########', 'en_US').format(asAmount);
    }
    // asset sats -> asset -> rvn -> usd
    security = getSecurityOf(symbol: symbol, security: security);
    final Asset? asset = getAssetOf(symbol: symbol);
    final double asAmount = satToAmount(sats);
    return asUSD
        ? rvnUSD(asAmount * (security.toRVNRate))
        : NumberFormat(
                '#,##0${(asset?.divisibility ?? 0) > 0 ? '.${'#' * (asset?.divisibility ?? 0)}' : ''}',
                'en_US')
            .format(asAmount);
  }

  Security getSecurityOf({
    Security? security,
    String? symbol,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == pros.securities.currentCoin.symbol) {
      return pros.securities.currentCoin;
    }
    if (symbol == 'USD') {
      return pros.securities.USD;
    }
    return security ??
        pros.securities.primaryIndex
            .getOne(symbol, pros.settings.chain, pros.settings.net) ??
        Security(
            symbol: symbol, chain: pros.settings.chain, net: pros.settings.net);
  }

  Asset? getAssetOf({
    Security? security,
    String? symbol,
  }) {
    symbol = getSymbol(symbol: symbol, security: security);
    if (symbol == pros.securities.currentCoin.symbol) {
      return null;
    }
    security = security ??
        pros.securities.primaryIndex
            .getOne(symbol, pros.settings.chain, pros.settings.net) ??
        Security(
            symbol: symbol, chain: pros.settings.chain, net: pros.settings.net);
    return pros.assets.primaryIndex
        .getOne(symbol, security.chain, security.net);
  }

  String getSymbol({
    Security? security,
    String? symbol,
  }) {
    security ??
        symbol ??
        (() => throw OneOfMultipleMissing(
            'security or symbol required to identify record.'))();
    return security?.symbol ?? symbol ?? pros.securities.currentCoin.symbol;
  }
}

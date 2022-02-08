import 'package:raven_back/raven_back.dart';

class AssetHolding {
  final String symbol;
  final Balance? main;
  final Balance? admin;
  final Balance? restricted;
  final Balance? qualifier;
  final Balance? unique;
  final Balance? channel;
  final Balance? crypto;
  final Balance? fiat;

  AssetHolding({
    required this.symbol,
    this.main,
    this.admin,
    this.restricted,
    this.qualifier,
    this.unique,
    this.channel,
    this.crypto,
    this.fiat,
  });

  factory AssetHolding.fromAssetHolding(
    AssetHolding existing, {
    String? symbol,
    Balance? main,
    Balance? admin,
    Balance? restricted,
    Balance? qualifier,
    Balance? unique,
    Balance? channel,
    Balance? crypto,
    Balance? fiat,
  }) =>
      AssetHolding(
        symbol: symbol ?? existing.symbol,
        main: main ?? existing.main,
        admin: admin ?? existing.admin,
        restricted: restricted ?? existing.restricted,
        qualifier: qualifier ?? existing.qualifier,
        unique: unique ?? existing.unique,
        channel: channel ?? existing.channel,
        crypto: crypto ?? existing.crypto,
        fiat: fiat ?? existing.fiat,
      );

  @override
  String toString() => 'AssetHolding('
      'symbol: $symbol, '
      'main: $main, '
      'admin: $admin, '
      'restricted: $restricted, '
      'qualifier: $qualifier, '
      'unique: $unique, '
      'channel: $channel, '
      'crypto: $crypto, '
      'fiat: $fiat, '
      ')';

  String get typesView =>
      (main != null ? 'Main ' : '') +
      (admin != null ? 'Admin ' : '') +
      (restricted != null ? 'Restricted ' : '') +
      (qualifier != null ? 'Qualifier ' : '') +
      (unique != null ? 'Unique ' : '') +
      (channel != null ? 'Channel ' : '') +
      (crypto != null ? 'Crypto ' : '') +
      (fiat != null ? 'Fiat ' : '');

  int get length => [
        main,
        admin,
        restricted,
        qualifier,
        unique,
        channel,
        crypto,
        fiat,
      ].where((element) => element != null).length;

  String? get singleSymbol => length > 1
      ? null
      : (mainSymbol ??
          adminSymbol ??
          restrictedSymbol ??
          qualifierSymbol ??
          uniqueSymbol ??
          channelSymbol ??
          cryptoSymbol ??
          fiatSymbol);

  String? get mainSymbol => main != null ? symbol : null;
  String? get subSymbol =>
      main != null ? '/${symbol}' : null; // sub mains allowed
  String? get adminSymbol => admin != null ? '${symbol}!' : null; // must be top
  String? get restrictedSymbol =>
      restricted != null ? '\$${symbol}' : null; // must be top
  String? get qualifierSymbol =>
      qualifier != null ? '#${symbol}' : null; // sub qualifiers allowed
  String? get uniqueSymbol =>
      unique != null ? '#${symbol}' : null; // must be subasset
  String? get channelSymbol =>
      channel != null ? '~${symbol}' : null; // must be subasset
  String? get cryptoSymbol => crypto != null
      ? (crypto?.security.symbol ?? symbol)
      : null; // not a raven asset
  String? get fiatSymbol => fiat != null
      ? (fiat?.security.symbol ?? symbol)
      : null; // not a raven asset

  // returns the best value (main, qualifier, restricted, admin, channel, unique, crypto, fiat)
  Balance? get balance =>
      main ??
      qualifier ??
      restricted ??
      admin ??
      unique ??
      channel ??
      crypto ??
      fiat;
}

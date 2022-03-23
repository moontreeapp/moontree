import 'package:raven_back/raven_back.dart';

class AssetHolding {
  final String symbol;
  final Balance? main;
  final Balance? admin;
  final Balance? restricted;
  final Balance? restrictedAdmin;
  final Balance? nft;
  final Balance? channel;
  final Balance? sub;
  final Balance? subAdmin;
  final Balance? qualifier;
  final Balance? qualifierSub;
  final Balance? crypto;
  final Balance? fiat;

  AssetHolding({
    required this.symbol,
    this.main,
    this.admin,
    this.restricted,
    this.restrictedAdmin,
    this.nft,
    this.channel,
    this.sub,
    this.subAdmin,
    this.qualifier,
    this.qualifierSub,
    this.crypto,
    this.fiat,
  });

  factory AssetHolding.fromAssetHolding(
    AssetHolding existing, {
    String? symbol,
    Balance? main,
    Balance? admin,
    Balance? restricted,
    Balance? restrictedAdmin,
    Balance? nft,
    Balance? channel,
    Balance? sub,
    Balance? subAdmin,
    Balance? qualifier,
    Balance? qualifierSub,
    Balance? crypto,
    Balance? fiat,
  }) =>
      AssetHolding(
        symbol: symbol ?? existing.symbol,
        main: main ?? existing.main,
        admin: admin ?? existing.admin,
        restricted: restricted ?? existing.restricted,
        restrictedAdmin: restrictedAdmin ?? existing.restrictedAdmin,
        nft: nft ?? existing.nft,
        channel: channel ?? existing.channel,
        sub: sub ?? existing.sub,
        subAdmin: subAdmin ?? existing.subAdmin,
        qualifier: qualifier ?? existing.qualifier,
        qualifierSub: qualifierSub ?? existing.qualifierSub,
        crypto: crypto ?? existing.crypto,
        fiat: fiat ?? existing.fiat,
      );

  @override
  String toString() => 'AssetHolding('
      'symbol: $symbol, '
      'main: $main, '
      'admin: $admin, '
      'restricted: $restricted, '
      'restrictedAdmin: $restrictedAdmin, '
      'nft: $nft, '
      'channel: $channel, '
      'sub: $sub, '
      'subAdmin: $subAdmin, '
      'qualifier: $qualifier, '
      'qualifierSub: $qualifierSub, '
      'crypto: $crypto, '
      'fiat: $fiat, '
      ')';

  String get typesView =>
      (main != null ? 'Main' : '') +
      (admin != null ? 'Admin' : '') +
      (restricted != null ? 'Restricted' : '') +
      (restrictedAdmin != null ? 'RestrictedAdmin' : '') +
      (nft != null ? 'Nft' : '') +
      (channel != null ? 'Channel' : '') +
      (sub != null ? 'Sub' : '') +
      (subAdmin != null ? 'SubAdmin' : '') +
      (qualifier != null ? 'Qualifier' : '') +
      (qualifierSub != null ? 'QualifierSub' : '') +
      (crypto != null ? 'Crypto ' : '') +
      (fiat != null ? 'Fiat ' : '');

  int get length => [
        main,
        admin,
        restricted,
        restrictedAdmin,
        nft,
        channel,
        sub,
        subAdmin,
        qualifier,
        qualifierSub,
        crypto,
        fiat,
      ].where((element) => element != null).length;

  int get subLength => [
        sub,
        subAdmin,
      ].where((element) => element != null).length;

  int get mainLength => [
        main,
        admin,
        restricted,
        restrictedAdmin,
      ].where((element) => element != null).length;

  String? get singleSymbol => length > 1
      ? null
      : (restrictedAdminSymbol ??
          restrictedSymbol ??
          mainSymbol ??
          adminSymbol ??
          subSymbol ??
          subAdminSymbol ??
          nftSymbol ??
          channelSymbol ??
          qualifierSymbol ??
          qualifierSubSymbol ??
          cryptoSymbol ??
          fiatSymbol);

  String? get mainSymbol => main != null ? symbol : null;
  String? get adminSymbol => admin != null ? '$symbol!' : null;
  String? get restrictedSymbol => restricted != null ? '\$$symbol' : null;
  String? get restrictedAdminSymbol =>
      restrictedAdmin != null ? '\$$symbol!' : null;
  String? get nftSymbol => nft != null ? '$symbol' : null;
  String? get channelSymbol => channel != null ? '$symbol' : null;
  String? get subSymbol => sub != null ? '$symbol' : null;
  String? get subAdminSymbol => subAdmin != null ? '$symbol!' : null;
  String? get qualifierSymbol => qualifier != null ? '#$symbol' : null;
  String? get qualifierSubSymbol => qualifierSub != null ? '#$symbol' : null;
  String? get cryptoSymbol => crypto != null
      ? (crypto?.security.symbol ?? symbol)
      : null; // not a raven asset
  String? get fiatSymbol => fiat != null
      ? (fiat?.security.symbol ?? symbol)
      : null; // not a raven asset

  String get first => symbol.split('/').first;
  String get head => symbol.contains('/')
      ? symbol.split('/').sublist(0, symbol.split('/').length - 1).join('/')
      : symbol;
  String get tail => symbol.contains('/')
      ? symbol.split('/').sublist(1, symbol.split('/').length).join('/')
      : symbol;
  String get last => symbol.split('/').last.split('~').last.split('#').last;
  String get notLast => symbol.substring(0, symbol.length - last.length);

  // shouldn't be used?
  // returns the best value (main, qualifier, restricted, admin, channel, nft, crypto, fiat)
  Balance? get balance =>
      main ??
      restrictedAdmin ??
      restricted ??
      admin ??
      sub ??
      subAdmin ??
      nft ??
      channel ??
      qualifier ??
      qualifierSub ??
      crypto ??
      fiat;
}

import 'package:client_back/client_back.dart';

class AssetHolding {
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
    this.coin,
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
    Balance? coin,
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
        coin: coin ?? existing.coin,
        fiat: fiat ?? existing.fiat,
      );

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
  final Balance? coin;
  final Balance? fiat;

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
      'coin: $coin, '
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
      (coin != null ? 'Coin ' : '') +
      (fiat != null ? 'Fiat ' : '');

  int get length => <Balance?>[
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
        coin,
        fiat,
      ].where((Balance? element) => element != null).length;

  int get subLength => <Balance?>[
        sub,
        subAdmin,
      ].where((Balance? element) => element != null).length;

  int get mainLength => <Balance?>[
        main,
        admin,
        restricted,
        restrictedAdmin,
      ].where((Balance? element) => element != null).length;

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
          coinSymbol ??
          fiatSymbol);

  String? get mainSymbol => main != null ? symbol : null;
  String? get adminSymbol => admin != null ? '$symbol!' : null;
  String? get restrictedSymbol => restricted != null ? '\$$symbol' : null;
  String? get restrictedAdminSymbol =>
      restrictedAdmin != null ? '\$$symbol!' : null;
  String? get nftSymbol => nft != null ? '$symbol' : null; // # ?
  String? get channelSymbol => channel != null ? '$symbol' : null; //~ ?
  String? get subSymbol => sub != null ? '$symbol' : null; // / ?
  String? get subAdminSymbol => subAdmin != null ? '$symbol!' : null;
  String? get qualifierSymbol => qualifier != null ? '#$symbol' : null;
  String? get qualifierSubSymbol => qualifierSub != null ? '#$symbol' : null;
  String? get coinSymbol => coin != null
      ? (coin?.security.symbol ?? symbol)
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
  // returns the best value (main, qualifier, restricted, admin, channel, nft, coin, fiat)
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
      coin ??
      fiat;
  int get value => <Balance?>[
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
        coin,
        fiat,
      ].where((Balance? element) => element != null).fold(
          0,
          (int previousValue, Balance? element) =>
              (element?.value ?? 0) + previousValue);
}

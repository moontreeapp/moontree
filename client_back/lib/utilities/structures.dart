import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:moontree_utils/extensions/extensions.dart';
import 'package:wallet_utils/wallet_utils.dart';

class AssetHolding {
  final String symbol;
  final BalanceView? main;
  final BalanceView? admin;
  final BalanceView? restricted;
  final BalanceView? restrictedAdmin;
  final BalanceView? nft;
  final BalanceView? channel;
  final BalanceView? sub;
  final BalanceView? subAdmin;
  final BalanceView? qualifier;
  final BalanceView? qualifierSub;
  final BalanceView? coin;
  final BalanceView? fiat;

  AssetHolding({
    required this.symbol,
    Chain? chain,
    Net? net,
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
  }) {
    symbolSymbol =
        Symbol(symbol)(chain ?? pros.settings.chain, net ?? pros.settings.net);
  }

  late Symbol symbolSymbol;

  factory AssetHolding.fromAssetHolding(
    AssetHolding existing, {
    String? symbol,
    BalanceView? main,
    BalanceView? admin,
    BalanceView? restricted,
    BalanceView? restrictedAdmin,
    BalanceView? nft,
    BalanceView? channel,
    BalanceView? sub,
    BalanceView? subAdmin,
    BalanceView? qualifier,
    BalanceView? qualifierSub,
    BalanceView? coin,
    BalanceView? fiat,
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

  int get length => <BalanceView?>[
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
      ].where((BalanceView? element) => element != null).length;

  int get subLength => <BalanceView?>[
        sub,
        subAdmin,
      ].where((BalanceView? element) => element != null).length;

  int get mainLength => <BalanceView?>[
        main,
        admin,
        restricted,
        restrictedAdmin,
      ].where((BalanceView? element) => element != null).length;

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
  String? get coinSymbol =>
      coin != null ? (coin?.symbol ?? symbol) : null; // not a raven asset
  String? get fiatSymbol =>
      fiat != null ? (fiat?.symbol ?? symbol) : null; // not a raven asset

  String get first => symbolSymbol.first;
  String get head => symbolSymbol.head;
  String get tail => symbolSymbol.tail;
  String get last => symbolSymbol.last;
  String get notLast => symbolSymbol.notLast;

  // shouldn't be used?
  // returns the best value (main, qualifier, restricted, admin, channel, nft, coin, fiat)
  BalanceView? get balance =>
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
  int get value => <BalanceView?>[
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
      ].where((BalanceView? element) => element != null).fold(
          0,
          (int previousValue, BalanceView? element) =>
              ((element?.satsConfirmed ?? 0) +
                  (element?.satsUnconfirmed ?? 0)) +
              previousValue);

  Security get security => Security(
      symbol: symbol,
      chain: symbolSymbol.chain ?? pros.settings.chain,
      net: symbolSymbol.net ?? pros.settings.net);
}

class Symbol {
  final String symbol;
  final Chain? chain;
  final Net? net;

  Symbol(this.symbol, {this.chain, this.net}) {
    if (!symbol.isAssetPath && !coins.contains(symbol)) {
      throw Exception('invalid symbol');
    }
  }
  static const coins = [SymbolRVN.coinSymbol, SymbolEVR.coinSymbol];

  Symbol call([Chain? chain, Net? net]) => Symbol.generate(
        symbol,
        chain ?? pros.settings.chain,
        net ?? pros.settings.net,
      );

  factory Symbol.generate(String symbol, Chain chain, Net net) =>
      chain == Chain.ravencoin
          ? SymbolRVN(symbol, chain, net)
          : SymbolEVR(symbol, chain, net);

  /* required API */

  bool get isCoin =>
      (chain == Chain.ravencoin && symbol == 'RVN') ||
      (chain == Chain.evrmore && symbol == 'EVR');

  bool get isReissuableType =>
      !isCoin && !isAdmin && !isQualifier && !isNFT && !isChannel;

  /// returns the parent symbol of this sub asset or null if it is not a sub
  String? get parentSymbol {
    switch (symbolType) {
      case SymbolType.sub:
        final List<String> splits = symbol.split('/');
        return splits.sublist(0, splits.length - 1).join('/');
      case SymbolType.subAdmin:
        final List<String> splits = symbol.split('/');
        return splits.sublist(0, splits.length - 1).join('/');
      case SymbolType.qualifierSub:
        final List<String> splits = symbol.split('/#');
        return splits.sublist(0, splits.length - 1).join('/#');
      case SymbolType.unique:
        final List<String> splits = symbol.split('#');
        return splits.sublist(0, splits.length - 1).join('#');
      case SymbolType.channel:
        final List<String> splits = symbol.split('~');
        return splits.sublist(0, splits.length - 1).join('~');
      default:
        return null;
    }
  }

  /// returns the sub symbol of this asset or null if it is not a sub
  String? get shortName {
    switch (symbolType) {
      case SymbolType.sub:
        final List<String> splits = symbol.split('/');
        return splits[splits.length - 1];
      case SymbolType.subAdmin:
        final List<String> splits = symbol.split('/');
        return splits[splits.length - 1];
      case SymbolType.qualifierSub:
        final List<String> splits = symbol.split('/#');
        return splits[splits.length - 1];
      case SymbolType.unique:
        final List<String> splits = symbol.split('#');
        return splits[splits.length - 1];
      case SymbolType.channel:
        final List<String> splits = symbol.split('~');
        return splits[splits.length - 1];
      default:
        return null;
    }
  }

  SymbolType get symbolType {
    if (symbol.startsWith('#') && symbol.contains('/')) {
      return SymbolType.qualifierSub;
    }
    if (symbol.startsWith('#')) {
      return SymbolType.qualifier;
    }
    if (symbol.startsWith(r'$')) {
      return SymbolType.restricted;
    }
    if (symbol.contains('#')) {
      return SymbolType.unique;
    }
    if (symbol.contains('~')) {
      return SymbolType.channel;
    }
    if (symbol.contains('/') && symbol.endsWith('!')) {
      return SymbolType.subAdmin;
    }
    if (symbol.contains('/')) {
      return SymbolType.sub;
    }
    if (symbol.endsWith('!')) {
      return SymbolType.admin;
    }
    return SymbolType.main;
  }

  String get symbolTypeName =>
      symbolType.name.toCapitalizedWord().replaceAll('Unique', 'NFT');

  String get baseSymbol => symbol.startsWith('#') || symbol.startsWith(r'$')
      ? symbol.substring(1, symbol.length)
      : symbol.endsWith('!')
          ? symbol.substring(0, symbol.length - 1)
          : symbol;
  String get baseSubSymbol => symbol.startsWith('#') || symbol.startsWith(r'$')
      ? symbol.substring(1, symbol.length)
      : symbol.endsWith('!')
          ? symbol.substring(0, symbol.length - 1)
          : symbol.replaceAll('#', '/');

  bool get isAdmin =>
      symbolType == SymbolType.admin || symbolType == SymbolType.subAdmin;
  bool get isSubAdmin => symbolType == SymbolType.subAdmin;
  //bool get isQualifierSub => symbolType == SymbolType.qualifierSub; // not necessary
  bool get isQualifier =>
      symbolType == SymbolType.qualifier ||
      symbolType == SymbolType.qualifierSub;
  bool get isAnySub =>
      symbolType == SymbolType.qualifierSub ||
      symbolType == SymbolType.subAdmin ||
      symbolType == SymbolType.sub ||
      symbolType == SymbolType.unique ||
      symbolType == SymbolType.channel;
  bool get isSub => symbolType == SymbolType.sub;
  bool get isRestricted => symbolType == SymbolType.restricted;
  bool get isMain => symbolType == SymbolType.main;
  bool get isNFT => symbolType == SymbolType.unique;
  bool get isChannel => symbolType == SymbolType.unique;

  String? get toMainSymbol => baseSymbol;
  String? get toAdminSymbol => '$baseSymbol!';
  String? get toRestrictedSymbol => '\$$baseSymbol';
  String? get toRestrictedAdminSymbol => '\$$baseSymbol!';
  String? get toNftSymbol => '$baseSymbol'; // # ?
  String? get toChannelSymbol => '$baseSymbol'; //~ ?
  String? get toSubSymbol => '$baseSymbol'; // / ?
  String? get toSubAdminSymbol => '$baseSymbol!';
  String? get toQualifierSymbol => '#$baseSymbol';
  String? get toQualifierSubSymbol => '#$baseSymbol';

  String get first => symbol.split('/').first;
  String get head => symbol.contains('/')
      ? symbol.split('/').sublist(0, symbol.split('/').length - 1).join('/')
      : symbol;
  String get tail => symbol.contains('/')
      ? symbol.split('/').sublist(1, symbol.split('/').length).join('/')
      : symbol;
  String get last => symbol.split('/').last.split('~').last.split('#').last;
  String get notLast => symbol.substring(0, symbol.length - last.length);
}

class SymbolEVR extends Symbol {
  SymbolEVR(symbol, chain, net) : super(symbol, chain: chain, net: net);
  static const String coinSymbol = 'EVR';
  // put differences or additions here, and add to base as overrideable method
}

class SymbolRVN extends Symbol {
  SymbolRVN(symbol, chain, net) : super(symbol, chain: chain, net: net);
  static const String coinSymbol = 'RVN';

  // put differences or additions here, and add to base as overrideable method
}

/// this enum has all RVN and EVR SymbolTypes. We had to do this because dart
/// doesn't allow enum inheritance like it does for classes.
enum SymbolType {
  // RVN & EVR
  main,
  admin,
  restricted,
  unique,
  channel,
  sub,
  subAdmin,
  qualifier,
  qualifierSub,
  // EVR only
  // RVN only
}

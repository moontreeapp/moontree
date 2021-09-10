import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'history.keys.dart';

class HistoryReservoir extends Reservoir<_TxHashKey, History> {
  late IndexMultiple<_AccountKey, History> byAccount;
  late IndexMultiple<_WalletKey, History> byWallet;
  late IndexMultiple<_ScripthashKey, History> byScripthash;
  late IndexMultiple<_SecurityKey, History> bySecurity;

  HistoryReservoir() : super(_TxHashKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byScripthash = addIndexMultiple('scripthash', _ScripthashKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
  }

  /// makeshiftIndicies //////////////////////////////////////////////////////
  //  print('sumBalances');
  //  print(accountId);
  //  print(histories.byAccount.getAll(accountId)); // not up to date:
  //  /*
  //  after having moved all wallets into account 0:
  //  I/flutter ( 9394): sumBalances
  //  I/flutter ( 9394): 1
  //  I/flutter ( 9394): [History(scripthash: 45e3a2b1c13feea95ce66c16b5dd979f36165fc76e0d5997ddc8455d0cb085b2, hash: abc1, height: 0, position: -1, value: 0, security: Security(RVN, SecurityType.Crypto), memo: , note: ), History(scripthash: 45e3a2b1c13feea95ce66c16b5dd979f36165fc76e0d5997ddc8455d0cb085b2, hash: abc2, height: 0, position: 0, value: 1000000000, security: Security(RVN, SecurityType.Crypto), memo: , note: ), History(scripthash: 45e3a2b1c13feea95ce66c16b5dd979f36165fc76e0d5997ddc8455d0cb085b2, hash: abc3, height: 0, position: 0, value: 5000000000, security: Security(Magic Musk, SecurityType.RavenAsset), memo: , note: )]
  //  I/flutter ( 9394): sumBalances
  //  I/flutter ( 9394): 0
  //  I/flutter ( 9394): []
  //  */
  //  print(histories.data.where((history) =>
  //      history.address!.wallet!.accountId ==
  //      accountId)); // works

  List<History> byAccountMakeshift(String accountId) => histories.data
      .where((history) => history.address!.wallet!.accountId == accountId)
      .toList();

  List<History> byWalletMakeshift(String walletId) => histories.data
      .where((history) => history.address!.walletId == walletId)
      .toList();

  List<History> byScripthashMakeshift(String scripthash) => histories.data
      .where((history) => history.address!.scripthash == scripthash)
      .toList();

  List<History> bySecurityMakeshift(Security security) =>
      histories.data.where((history) => history.security == security).toList();

  /// makeshiftIndicies ///////////////////////////////////////////////////////

  static Iterable<History> whereFiltered({
    Iterable<History>? given,
    String? accountId,
    String? walletId,
    String? scripthash,
    String? address,
    bool? confirmed,
    Security? security,
    int? height,
    String? hash,
  }) =>
      (given ?? histories.data).where((History history) =>
          history.confirmed && // not in mempool
          (accountId != null
              ? history.address!.wallet!.accountId == accountId
              : true) &&
          (walletId != null ? history.address!.walletId == walletId : true) &&
          (address != null ? history.address!.address == address : true) &&
          (scripthash != null ? history.scripthash == scripthash : true) &&
          (confirmed != null ? history.confirmed == confirmed : true) &&
          (security != null ? history.security == security : true) &&
          (height != null ? history.height == height : true) &&
          (hash != null ? history.hash == hash : true));

  static Iterable<History> whereTransaction(
          {Iterable<History>? given, Security? security}) =>
      (given ?? histories).where((history) =>
          history.confirmed && // not in mempool
          (security != null ? history.security == security : true));

  static Iterable<History> whereUnspent(
          {Iterable<History>? given, Security? security}) =>
      (given ?? histories).where((history) =>
          history.value > 0 && // unspent
          history.confirmed && // not in mempool
          (security != null ? history.security == security : true));

  static Iterable<History> whereUnconfirmed(
          {Iterable<History>? given, Security? security}) =>
      (given ?? histories).where((history) =>
          history.value > 0 && // unspent
          !history.confirmed && // in mempool
          (security != null ? history.security == security : true));

  /// remove logic ////////////////////////////////////////////////////////////

  void removeHistories(String scripthash) {
    return byScripthash
        .getAll(scripthash)
        .forEach((history) => remove(history));
  }
}

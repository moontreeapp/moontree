import 'dart:math';

import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';

import 'package:ravencoin_back/services/wallet/constants.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

part 'wallet.keys.dart';

class WalletProclaim extends Proclaim<_IdKey, Wallet> {
  // final CipherRegistry cipherRegistry;
  late IndexMultiple<_WalletTypeKey, Wallet> byWalletType;
  late IndexMultiple<_NameKey, Wallet> byName;

  WalletProclaim() : super(_IdKey()) {
    byWalletType = addIndexMultiple('walletType', _WalletTypeKey());
    byName = addIndexMultiple('name', _NameKey());
  }

  Set<String> get ids => records.map((e) => e.id).toSet();
  List<Wallet> get ordered => order(records);

  List<Wallet> order(Iterable<Wallet> wallets) =>
      wallets.sorted((a, b) => a.name.compareTo(b.name));

  List<LeaderWallet> preferredFristLeaders(LeaderWallet preferred) =>
      byWalletType
          .getAll(WalletType.leader)
          .where((wallet) => wallet as LeaderWallet == preferred)
          .map((wallet) => wallet as LeaderWallet)
          .toList() +
      byWalletType
          .getAll(WalletType.leader)
          .where((wallet) => wallet as LeaderWallet != preferred)
          .map((wallet) => wallet as LeaderWallet)
          .toList();

  List<SingleWallet> preferredFristSingles(SingleWallet preferred) =>
      byWalletType
          .getAll(WalletType.single)
          .where((wallet) => wallet as SingleWallet == preferred)
          .map((wallet) => wallet as SingleWallet)
          .toList() +
      byWalletType
          .getAll(WalletType.single)
          .where((wallet) => wallet as SingleWallet != preferred)
          .map((wallet) => wallet as SingleWallet)
          .toList();

  List<LeaderWallet> get leaders => byWalletType
      .getAll(WalletType.leader)
      .map((wallet) => wallet as LeaderWallet)
      .toList();

  List<SingleWallet> get singles => byWalletType
      .getAll(WalletType.single)
      .map((wallet) => wallet as SingleWallet)
      .toList();

  /// returns preferred or first or null wallet
  Wallet? getBestWallet() =>
      primaryIndex.getOne(pros.settings.primaryIndex
          .getOne(SettingName.wallet_preferred)
          ?.value) ??
      primaryIndex.getOne(pros.settings.primaryIndex
          .getOne(SettingName.wallet_current)
          ?.value) ??
      records.firstOrNull;

  String get nextWalletName {
    final taken = records.where((e) {
      final x = e.name.split(' ');
      return x.length == 2 && x.first == 'Wallet' && x.last.isInt;
    }).map((e) => int.parse(e.name.split(' ').last));
    if (taken.isEmpty) {
      return 'Wallet 1';
    }
    return 'Wallet ${(taken.reduce(max) + 1).toString()}';
  }

  Wallet get currentWallet => primaryIndex.getOne(
      pros.settings.primaryIndex.getOne(SettingName.wallet_current)?.value)!;

  String get currentWalletName => currentWallet.name;

  //List<AssetHolding>? get holdings => utils.assetHoldings(balances);
  ////services.download.unspents
  //          //    .unspentBalancesByWalletId[Current.walletId] ??
  //          //[]
}

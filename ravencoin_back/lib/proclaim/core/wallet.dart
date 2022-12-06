import 'dart:math';
import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';

part 'wallet.keys.dart';

class WalletProclaim extends Proclaim<_IdKey, Wallet> {
  // final CipherRegistry cipherRegistry;
  late IndexMultiple<_WalletTypeKey, Wallet> byWalletType;
  late IndexMultiple<_NameKey, Wallet> byName;

  WalletProclaim() : super(_IdKey()) {
    byWalletType = addIndexMultiple('walletType', _WalletTypeKey());
    byName = addIndexMultiple('name', _NameKey());
  }

  Set<String> get ids => records.map((Wallet e) => e.id).toSet();
  List<Wallet> get ordered => order(records);

  List<Wallet> order(Iterable<Wallet> wallets) =>
      wallets.sorted((Wallet a, Wallet b) => a.name.compareTo(b.name));

  List<LeaderWallet> preferredFristLeaders(LeaderWallet preferred) =>
      byWalletType
          .getAll(WalletType.leader)
          .where((Wallet wallet) => wallet as LeaderWallet == preferred)
          .map((Wallet wallet) => wallet as LeaderWallet)
          .toList() +
      byWalletType
          .getAll(WalletType.leader)
          .where((Wallet wallet) => wallet as LeaderWallet != preferred)
          .map((Wallet wallet) => wallet as LeaderWallet)
          .toList();

  List<SingleWallet> preferredFristSingles(SingleWallet preferred) =>
      byWalletType
          .getAll(WalletType.single)
          .where((Wallet wallet) => wallet as SingleWallet == preferred)
          .map((Wallet wallet) => wallet as SingleWallet)
          .toList() +
      byWalletType
          .getAll(WalletType.single)
          .where((Wallet wallet) => wallet as SingleWallet != preferred)
          .map((Wallet wallet) => wallet as SingleWallet)
          .toList();

  List<LeaderWallet> get leaders => byWalletType
      .getAll(WalletType.leader)
      .map((Wallet wallet) => wallet as LeaderWallet)
      .toList();

  List<SingleWallet> get singles => byWalletType
      .getAll(WalletType.single)
      .map((Wallet wallet) => wallet as SingleWallet)
      .toList();

  /// returns preferred or first or null wallet
  Wallet? getBestWallet() =>
      primaryIndex.getOne(pros.settings.primaryIndex
          .getOne(SettingName.wallet_preferred)
          ?.value as String) ??
      primaryIndex.getOne(pros.settings.primaryIndex
          .getOne(SettingName.wallet_current)
          ?.value as String) ??
      records.firstOrNull;

  String get nextWalletName {
    final Iterable<int> taken = records.where((Wallet e) {
      final List<String> x = e.name.split(' ');
      return x.length == 2 && x.first == 'Wallet' && x.last.isInt;
    }).map((Wallet e) => int.parse(e.name.split(' ').last));
    if (taken.isEmpty) {
      return 'Wallet 1';
    }
    return 'Wallet ${(taken.reduce(max) + 1).toString()}';
  }

  Wallet get currentWallet => primaryIndex.getOne(pros.settings.primaryIndex
      .getOne(SettingName.wallet_current)
      ?.value as String?)!;

  String get currentWalletName => currentWallet.name;

  //List<AssetHolding>? get holdings => utils.assetHoldings(balances);
  ////services.download.unspents
  //          //    .unspentBalancesByWalletId[Current.walletId] ??
  //          //[]
}

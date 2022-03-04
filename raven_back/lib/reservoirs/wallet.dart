import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/records/records.dart';

import 'package:raven_back/raven_back.dart';

part 'wallet.keys.dart';

class WalletReservoir extends Reservoir<_IdKey, Wallet> {
  // final CipherRegistry cipherRegistry;
  late IndexMultiple<_WalletTypeKey, Wallet> byWalletType;

  WalletReservoir() : super(_IdKey()) {
    byWalletType = addIndexMultiple('walletType', _WalletTypeKey());
  }

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
      primaryIndex.getOne(res.settings.primaryIndex
          .getOne(SettingName.Wallet_Preferred)
          ?.value) ??
      primaryIndex.getOne(res.settings.primaryIndex
          .getOne(SettingName.Wallet_Current)
          ?.value) ??
      data.firstOrNull;

  String get nextWalletName => (data.length + 1).toString();

  String get currentWalletName => primaryIndex
      .getOne(
          res.settings.primaryIndex.getOne(SettingName.Wallet_Current)?.value)!
      .name;
}

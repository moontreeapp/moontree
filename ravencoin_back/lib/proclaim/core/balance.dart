import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:proclaim/proclaim.dart';

part 'balance.keys.dart';

class BalanceProclaim extends Proclaim<_IdKey, Balance> {
  late IndexMultiple<_WalletKey, Balance> byWallet;
  late IndexMultiple<_SecurityKey, Balance> bySecurity;

  BalanceProclaim() : super(_IdKey()) {
    byWallet = addIndexMultiple('wallet', _WalletKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
  }

  Balance getOrZero(String walletId, {required Security security}) =>
      primaryIndex.getOne(walletId, security) ??
      Balance(
        walletId: walletId,
        security: security,
        confirmed: 0,
        unconfirmed: 0,
      );

  Future removeAllByIds(Set<String> walletIds) async =>
      await removeAll(records.where((b) => walletIds.contains(b.walletId)));
}

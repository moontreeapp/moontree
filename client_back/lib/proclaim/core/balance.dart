import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/records/records.dart';

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

  Future<List<Change<dynamic>>> removeAllByIds(Set<String> walletIds) async =>
      removeAll(records.where((Balance b) => walletIds.contains(b.walletId)));
}

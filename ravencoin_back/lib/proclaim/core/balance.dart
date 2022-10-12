import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:proclaim/proclaim.dart';

part 'balance.keys.dart';

class BalanceProclaim extends Proclaim<_WalletSecurityKey, Balance> {
  late IndexMultiple<_WalletKey, Balance> byWallet;
  late IndexMultiple<_SecurityKey, Balance> bySecurity;
  late IndexMultiple<_WalletSecurityKey, Balance> byWalletSecurity;
  late IndexMultiple<_WalletChainKey, Balance> byWalletChain;
  late IndexMultiple<_SecurityChainKey, Balance> bySecurityChain;
  late IndexMultiple<_WalletSecurityChainKey, Balance> byWalletSecurityChain;

  BalanceProclaim() : super(_WalletSecurityKey()) {
    byWallet = addIndexMultiple('wallet', _WalletKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
    byWalletSecurity = addIndexMultiple('walletSecurity', _WalletSecurityKey());
    byWalletChain = addIndexMultiple('walletChain', _WalletChainKey());
    bySecurityChain = addIndexMultiple('securityChain', _SecurityChainKey());
    byWalletSecurityChain =
        addIndexMultiple('walletSecurityChain', _WalletSecurityChainKey());
  }

  Balance getOrZero(
    String walletId, {
    required Security security,
    required Chain chain,
    required Net net,
  }) =>
      primaryIndex.getOne(walletId, security) ??
      Balance(
        walletId: walletId,
        security: security,
        confirmed: 0,
        unconfirmed: 0,
        chain: chain,
        net: net,
      );

  Future removeAllByIds(Set<String> walletIds) async =>
      await removeAll(records.where((b) => walletIds.contains(b.walletId)));
}

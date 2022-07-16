import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:proclaim/proclaim.dart';

part 'balance.keys.dart';

class BalanceProclaim extends Proclaim<_WalletSecurityKey, Balance> {
  late IndexMultiple<_WalletKey, Balance> byWallet;
  late IndexMultiple<_SecurityKey, Balance> bySecurity;
  late IndexMultiple<_WalletSecurityKey, Balance> byWalletSecurity;

  BalanceProclaim() : super(_WalletSecurityKey()) {
    byWallet = addIndexMultiple('wallet', _WalletKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
    byWalletSecurity = addIndexMultiple('walletSecurity', _WalletSecurityKey());
  }

  Balance getOrZero(String walletId, {required Security security}) =>
      primaryIndex.getOne(walletId, security) ??
      Balance(
        walletId: walletId,
        security: security,
        confirmed: 0,
        unconfirmed: 0,
      );
}

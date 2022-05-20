import 'package:collection/collection.dart';
import 'package:raven_back/records/records.dart';
import 'package:reservoir/reservoir.dart';

part 'balance.keys.dart';

class BalanceReservoir extends Reservoir<_WalletSecurityKey, Balance> {
  late IndexMultiple<_WalletKey, Balance> byWallet;
  late IndexMultiple<_SecurityKey, Balance> bySecurity;
  late IndexMultiple<_WalletSecurityKey, Balance> byWalletSecurity;

  BalanceReservoir() : super(_WalletSecurityKey()) {
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

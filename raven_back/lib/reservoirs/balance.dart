import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:raven/records/security.dart';
import 'package:reservoir/reservoir.dart';

part 'balance.keys.dart';

class BalanceReservoir extends Reservoir<_WalletSecurityKey, Balance> {
  late IndexMultiple<_WalletKey, Balance> byWallet;
  //late IndexMultiple<_AccountKey, Balance> byAccount;

  BalanceReservoir() : super(_WalletSecurityKey()) {
    byWallet = addIndexMultiple('account', _WalletKey());
    //byAccount = addIndexMultiple('account', _AccountKey());
  }

  Balance getOrZero(String walletId, {Security security = RVN}) =>
      primaryIndex.getOne(walletId, security) ??
      Balance(
        walletId: walletId,
        security: security,
        confirmed: 0,
        unconfirmed: 0,
      );
}

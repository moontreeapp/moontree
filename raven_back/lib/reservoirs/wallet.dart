import 'package:raven/records.dart';
import 'package:reservoir/reservoir.dart';

class WalletReservoir extends Reservoir<String, Wallet> {
  late IndexMultiple byAccount;

  WalletReservoir([source])
      : super(source ?? HiveSource('wallets'), (wallet) => wallet.id) {
    byAccount = addIndexMultiple('account', (wallet) => wallet.accountId);
  }
}

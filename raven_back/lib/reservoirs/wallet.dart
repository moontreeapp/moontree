import 'package:raven/records.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class WalletReservoir extends Reservoir<String, Wallet> {
  late MultipleIndex byAccount;

  WalletReservoir([source]) : super(source ?? HiveSource('wallets')) {
    byAccount = addMultipleIndex('account', (wallet) => wallet.accountId);
  }
}

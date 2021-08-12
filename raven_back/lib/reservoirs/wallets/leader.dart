import 'package:raven/records.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class LeaderWalletReservoir extends Reservoir<String, LeaderWallet> {
  late MultipleIndex byAccount;

  LeaderWalletReservoir([source]) : super(source ?? HiveSource('leaders')) {
    byAccount = addMultipleIndex('account', (leader) => leader.accountId);
  }
}

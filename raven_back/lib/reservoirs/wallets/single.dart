import 'package:raven/records.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class SingleWalletReservoir extends Reservoir<String, SingleWallet> {
  late MultipleIndex byAccount;

  SingleWalletReservoir([source]) : super(source ?? HiveSource('singles')) {
    byAccount = addMultipleIndex('account', (single) => single.accountId);
  }
}

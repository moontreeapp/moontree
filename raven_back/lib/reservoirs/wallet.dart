import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';

part 'wallet.keys.dart';

class WalletReservoir extends Reservoir<_IdKey, Wallet> {
  late IndexMultiple<_AccountKey, Wallet> byAccount;

  WalletReservoir() : super(_IdKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
  }
}

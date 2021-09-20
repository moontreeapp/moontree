import 'package:collection/collection.dart';
import 'package:raven/security/security.dart';
import 'package:reservoir/reservoir.dart';

import 'package:raven/records/records.dart';

part 'wallet.keys.dart';

class WalletReservoir extends Reservoir<_IdKey, Wallet> {
  final CipherRegistry cipherRegistry;
  late IndexMultiple<_AccountKey, Wallet> byAccount;

  WalletReservoir(this.cipherRegistry) : super(_IdKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
  }
}

import 'package:reservoir/reservoir.dart';
import 'package:raven/records.dart';

part 'account.keys.dart';

class AccountReservoir extends Reservoir<_IdKey, Account> {
  AccountReservoir([source])
      : super(source ?? HiveSource('accounts'), _IdKey());
}

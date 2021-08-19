import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/records.dart';

class AccountReservoir extends Reservoir<String, Account> {
  AccountReservoir([source])
      : super(source ?? HiveSource('accounts'), (account) => account.id);
}

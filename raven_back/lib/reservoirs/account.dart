import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/records.dart';

class AccountReservoir extends Reservoir<String, Account> {
  AccountReservoir() : super(HiveSource('accounts')) {
    addPrimaryIndex((account) => account.id);
  }
}
